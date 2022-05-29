import { HttpService } from '@nestjs/axios';
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
  ident: string, startDate: Moment, endDate: Moment, originItea?: string, destItea?: string
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
      flights = await this.flightAwareAdvancedRepository.get({
        historyUrl: req as string,
      })
    }
    else { 
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
      startDate: params.startDate,
      endDate: params.endDate,
      originItea: params.originItea,
      destItea: params.destItea
    });

  async getRangeStart(userId: string, params: GetRangeParams & {restart: boolean}) {
    let oldJob = await this.flightsQueue.getJob(
      this.getRangeJobId(params));
    if (oldJob != null && params.restart) {
      if (await oldJob.isActive()) {
        await oldJob.update(
          { ...params, cancelled: true }
        )
        await oldJob.finished().catch(() => {})
      }
      await oldJob.remove()
      oldJob = null;
    }
    const job = await this.flightsQueue.add(
      { ...params },
      { jobId: this.getRangeJobId(params) },
    );
    await this.flightSearchDbRepository.save(new UserFlightSearch({
      searchId: job.id.toString(),
      userId: userId,
      ...params,
      id: null,
    }))
    return {
      id: job.id,
      status: oldJob == null ? 'created' : 'already created'
    }
  }

  async getRangeStatus(params: GetRangeParams) {
    const job = await this.flightsQueue.getJob(
      this.getRangeJobId(params));
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
        data: job.returnvalue,
      }
    }
    return {
      state,
      progress,
    }
  }

  async getRangeStop(params: GetRangeParams) {
    const job = await this.flightsQueue.getJob(
      this.getRangeJobId(params));

    await job.update(
      { ...params, cancelled: true }
    )
  }

  async getBySearchId(searchId: string) {
    return await this.flightSearchDbRepository.getBySearchId(searchId);
  }

  async getByUserId(userId: string) {
    return await this.flightSearchDbRepository.getByUserId(userId);
  }
}
