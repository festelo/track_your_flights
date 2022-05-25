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

  async getFlightAdvanced(ident: string, dateTime: Moment, originItea?: string, destItea?: string) {
    const flights = await this.flightAwareAdvancedRepository.get({
      dateTime: dateTime,
      routeInfo: {
        ident: ident,
        destItea: destItea,
        originItea: originItea,
      }
    })
    if (flights.length !== 0) {
      await this.flightsRepository.save(flights);
    }
    return flights;
  }

  async getFlightBasic(ident: string, date?: Moment, checkTime: boolean = false) {
    const flights = await this.flightAwareRepository.get(ident)
    await this.flightsRepository.save(flights);
    
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

  async getFlight(ident: string, dateTime: Moment, originItea?: string, destItea?: string, checkTime: boolean = false) {
    let res = await this.getFlightCached(ident, dateTime, originItea, destItea, checkTime);
    if (res.length == 0) {
      res = await this.getFlightBasic(ident, dateTime.clone(), checkTime);
    } if (res.length == 0) {
      res = await this.getFlightAdvanced(ident, dateTime.clone(), originItea, destItea);
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
