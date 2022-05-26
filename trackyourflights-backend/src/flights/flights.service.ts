import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { Flight } from 'src/flights/flights.entities';
import { InjectRepository } from '@nestjs/typeorm';
import { Between, Repository } from 'typeorm';
import { Moment } from 'moment';
import { FlightAwareRepository } from './flightaware-repository';
import { FlightAwareAdvancedRepository } from './flightaware-advanced-repository';

@Injectable()
export class FlightsService {
  constructor(
    private httpService: HttpService,
    @InjectRepository(Flight)
    private flightsRepository: Repository<Flight>,
  ) {}

  private flightAwareRepository = new FlightAwareRepository(this.httpService);
  private flightAwareAdvancedRepository = new FlightAwareAdvancedRepository(this.httpService);

  async searchFlights(q: string) { 
    return await this.flightAwareRepository.search(q);
  }

  private async saveFlightsToDb(flights: Flight[]) {
    if (flights.length == 0) return;

    const flightsMap: Record<string, Record<string, Flight>> = {};

    const paramsPlaceholders = [];
    for (let counter = 0, i = 0; i < flights.length; i++, counter += 2) {
      paramsPlaceholders.push(`(:p${counter}, :p${counter + 1})`)
      
      flightsMap[flights[i].ident] ??= {}
      flightsMap[flights[i].ident][flights[i].indexingDate.toISOString()] = flights[i]
    }

    const paramsPlaceholdersString = paramsPlaceholders.join(',')

    const paramsArray = flights.flatMap((e) => ([e.ident, e.indexingDate ]))
    const paramsObj = {}
    for (let i = 0; i < paramsArray.length; i++) {
      paramsObj['p' + i] = paramsArray[i];
    }


    const databaseFlights = await this.flightsRepository
      .createQueryBuilder()
      .where(
        `(ident, indexingDate) in ( VALUES ${paramsPlaceholdersString})`, 
        paramsObj
      )
      .getMany()

    for (const flight of databaseFlights) {
      const flightToUpdate = flightsMap[flight.ident] && flightsMap[flight.ident][flight.indexingDate.toISOString()];
      if (!flightToUpdate) continue;
      flightToUpdate.id = flight.id;
    }

    await this.flightsRepository.save(flights);
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
    await this.saveFlightsToDb(flights);
    return flights;
  }

  async getFlightBasic(ident: string, date?: Moment, checkTime: boolean = false) {
    const flights = await this.flightAwareRepository.get(ident)
    await this.saveFlightsToDb(flights);
    
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

  async getFlightCached(ident: string, date?: Moment, originItea?: string, destItea?: string, checkTime: boolean = false) {
    return await this.flightsRepository.find({
      where: {
        ident: ident,
        indexingDate: date ? Between(
          checkTime 
            ? date.startOf('minute').toDate()
            : date.startOf('day').toDate(),
          checkTime 
            ? date.endOf('minute').toDate()
            : date.endOf('day').toDate(),
        ) : undefined,
        origin: originItea ? {
          iata: originItea
        } : undefined,
        destination: destItea ? {
          iata: destItea
        } : undefined,
      }
    })
  }

  async getFlightCachedByFlightawareLink(flightAwareLink: string) {
    return await this.flightsRepository.find({
      where: {
        flightAwarePermaLink: flightAwareLink,
      }
    })
  }

  async getFlight(ident: string, dateTime: Moment, originItea?: string, destItea?: string, checkTime: boolean = false) {
    let res = await this.getFlightCached(ident, dateTime, originItea, destItea, checkTime);
    if (res.length == 0) {
      res = await this.getFlightBasic(ident, dateTime.clone(), checkTime);
    } if (res.length == 0) {
      res = await this.getFlightAdvanced({ident, dateTime: dateTime.clone(), originItea, destItea});
    }
    return res;
  }

  async getFlightByFlightaware(flightAwareLink: string) {
    let res = await this.getFlightCachedByFlightawareLink(flightAwareLink);
    if (res.length == 0) {
      res = await this.getFlightAdvanced(flightAwareLink);
    }
    return res;
  }

  async parseAllTimes(ident: string, dateTime: Moment, originItea?: string, destItea?: string) {
    while (true) {
      try {
        console.log(dateTime.toISOString(false))
        const exists = await this.flightAwareAdvancedRepository.checkExistance({ dateTime: dateTime.clone(), routeInfo: { ident, originItea: originItea, destItea: destItea}});
        if (exists) {
          return await this.flightAwareAdvancedRepository.get({ dateTime: dateTime.clone(), routeInfo: { ident, originItea: originItea, destItea: destItea}});
        }
        dateTime.add(1, 'minute')
        if (dateTime.hours() == 0 && dateTime.minutes() == 0) {
          break;
        }
      } catch (e) {
        console.log(e);
      }
    }
    return [];
  }
}
