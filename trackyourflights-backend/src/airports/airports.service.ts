import { Injectable } from '@nestjs/common';
import { FlightAwareAirportRepository } from './flightaware-airport-repository';

@Injectable()
export class AirportsService {
  constructor(
    private flightAwareAirportRepository: FlightAwareAirportRepository,
  ) {}

  async searchAirports(q: string) { 
    return await this.flightAwareAirportRepository.search(q);
  }
}
