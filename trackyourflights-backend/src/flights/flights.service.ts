import { Injectable } from '@nestjs/common';
import { Flight, UserFlightSearch } from 'src/flights/flights.entities';
import { Moment } from 'moment';
import { FlightAwareRepository } from './repositories/flightaware-repository';
import { FlightAwareAdvancedRepository } from './repositories/flightaware-advanced-repository';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { FlightsDbRepository } from './repositories/flights-db-repository';
import { FlightSearchDbRepository } from './repositories/flight-search-db-repository';

type GetRangeParams = {
  ident: string, aproxDate: Moment, originItea?: string, destItea?: string, minutesRange: 720,
}

@Injectable()
export class FlightsService {
  constructor(
    @InjectQueue('flights') private flightsQueue: Queue,
    private flightsDbRepository: FlightsDbRepository,
    private flightAwareRepository: FlightAwareRepository,
    private flightAwareAdvancedRepository: FlightAwareAdvancedRepository,
    private flightSearchDbRepository: FlightSearchDbRepository,
  ) {}

  async searchFlights(q: string) { 
    return await this.flightAwareRepository.search(q);
  }

  
  async getFlightAdvanced(req: {ident: string, dateTime: Moment, originItea?: string, destItea?: string} | string) {
    let flights: Flight[];
    if (typeof req === 'string' || req instanceof String) {
      const exists = await this.flightAwareAdvancedRepository.checkExistance({
        historyUrl: req as string,
      })
      if (!exists) return [];
      flights = await this.flightAwareAdvancedRepository.get({
        historyUrl: req as string,
      })
    }
    else { 
      const exists = await this.flightAwareAdvancedRepository.checkExistance({
        dateTime: req.dateTime,
        routeInfo: {
          ident: req.ident,
          destItea: req.destItea,
          originItea: req.originItea,
        }
      })
      if (!exists) return [];
      flights = await this.flightAwareAdvancedRepository.get({
        dateTime: req.dateTime,
        routeInfo: {
          ident: req.ident,
          destItea: req.destItea,
          originItea: req.originItea,
        }
      })
    }
    await this.flightsDbRepository.save(flights);
    return flights;
  }

  async getFlightBasic(ident: string, date?: Moment, checkTime: boolean = false) {
    const flights = await this.flightAwareRepository.get(ident)
    await this.flightsDbRepository.save(flights);
    
    return flights.filter((e) => {
      if (!date) return true;
      const flightDate = e.indexingDate;
      const dateDate = date.toDate();
      const datePass = dateDate.getUTCDate() == flightDate.getUTCDate() && 
        dateDate.getUTCMonth() == flightDate.getUTCMonth() &&
        dateDate.getUTCFullYear() == flightDate.getUTCFullYear();
      if (!datePass) return false;
      if (!checkTime) return datePass;
      return datePass && 
        dateDate.getUTCHours() == flightDate.getUTCHours() && 
        dateDate.getUTCMinutes() == flightDate.getUTCMinutes();
    });
  }

  async getFlight(ident: string, dateTime: Moment, originItea?: string, destItea?: string, checkTime: boolean = false) {
    let res = await this.flightsDbRepository.get(ident, dateTime, originItea, destItea, checkTime);
    if (res.length == 0) {
      res = await this.getFlightBasic(ident, dateTime.clone(), checkTime);
    } if (res.length == 0) {
      res = await this.getFlightAdvanced({ident, dateTime: dateTime.clone(), originItea, destItea});
    }
    return res;
  }

  async getFlightByFlightaware(flightAwareLink: string) {
    let res = await this.flightsDbRepository.getByFlightawareLink(flightAwareLink);
    if (res.length == 0) {
      res = await this.getFlightAdvanced(flightAwareLink);
    }
    return res;
  }

  private getRangeJobId = (params: GetRangeParams) => 
    JSON.stringify({
      ident: params.ident,
      aproxDate: params.aproxDate,
      minutesRange: params.minutesRange,
      originItea: params.originItea,
      destItea: params.destItea
    });

  async getRangeStart(userId: string, params: GetRangeParams & {restart: boolean}) {
    let oldJob = await this.flightsQueue.getJob(
      this.getRangeJobId(params));
    if (oldJob != null && oldJob.failedReason != null && params.restart) {
      if (await oldJob.isActive()) {
        await oldJob.update(
          { ...params, cancelled: true }
        )
        await oldJob.finished().catch(() => {})
      }
      await oldJob.remove()
      oldJob = null;
    } else if (oldJob?.failedReason != null) {
      await oldJob.remove()
      oldJob = null;
    }
    const job = await this.flightsQueue.add(
      { ...params },
      { jobId: this.getRangeJobId(params), attempts: 3 },
    );
    const userFlightSearch = new UserFlightSearch({
      searchId: job.id.toString(),
      userId: userId,
      ...params,
      id: null,
    });
    await this.flightSearchDbRepository.save(userFlightSearch);
    return {
      ...userFlightSearch,
      userId: undefined,
      searchId: undefined,
      state: await job.getState(),
      progress: await job.progress(),
      error: job.failedReason, 
      data: job.returnvalue ?? undefined,
      creationStatus: oldJob == null ? 'started new' : 'reused'
    }
  }

  async getRangeStatus(id: string) {
    const search = await this.flightSearchDbRepository.getById(id);
    const job = await this.flightsQueue.getJob(search.searchId);
    if (job == null) return { state: 'not found' };
    const state = await job.getState()
    const progress = await job.progress()
    if (job.failedReason != null) {
      return {
        state,
        progress,
        reason: job.failedReason,
      }
    }
    if (state == 'completed') {
      return {
        state,
        progress,
        data: job.returnvalue ?? undefined,
      }
    }
    return {
      state,
      progress,
    }
  }

  async getRangeStop(id: string) {
    const search = await this.flightSearchDbRepository.getById(id);

    const job = await this.flightsQueue.getJob(search.searchId);

    await job.update(
      { cancelled: true }
    )
  }

  async getByRangeRetry(id: string) {
    const search = await this.flightSearchDbRepository.getById(id);
    const job = await this.flightsQueue.getJob(search.searchId);
    await job.retry()
  }

  async getBySearchId(searchId: string) {
    return await this.flightSearchDbRepository.getByJobId(searchId);
  }

  async getByUserId(userId: string) {
    const searches = await this.flightSearchDbRepository.getByUserId(userId);
    const searchesById = new Map(searches.map((s) => [s.searchId, s]))
    const jobs = await Promise.all(searches.map((s) => this.flightsQueue.getJob(s.searchId)))
    const result = await Promise.all(jobs.map(async (j) => ({
      ...searchesById.get(j.id.toString()),
      searchId: undefined,
      userId: undefined,
      state: await j.getState(),
      progress: await j.progress(),
      data: j.returnvalue ?? undefined,
      error: j.failedReason,
    })))
    return result;
  }
}
