import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { Moment } from 'moment';
import { FlightAwareAirportRepository } from './flightaware-airport-repository';

type GetRangeParams = {
  ident: string, startDate: Moment, endDate: Moment, originItea?: string, destItea?: string
}

@Injectable()
export class AirportsService {
  constructor(
    private flightAwareAirportRepository: FlightAwareAirportRepository,
  ) {}

  async searchAirports(q: string) { 
    return await this.flightAwareAirportRepository.search(q);
  }
}
