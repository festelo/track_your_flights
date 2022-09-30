import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { lastValueFrom } from 'rxjs';
import { flightAwareUserAgent } from 'src/configuration/const-configuration';
import { dateFromEpoch } from 'src/utils';

@Injectable()
export class FlightAwareAirportRepository {
  constructor(
    private httpService: HttpService,
  ) {}

  async search(q: string) {
    const uri = new URL('https://flightaware.com/ajax/ignoreall/omnisearch/airport.rvt');
    uri.searchParams.append('searchterm', q);
    const res = await lastValueFrom(this.httpService.get(uri.toString(), {
      headers: { 
        'X-Locale': 'en_US',
        ...flightAwareUserAgent,
      }
    }));
    const data = res.data.data as [{
      description: string,
      iata: string,
      icao: string,
    }];
    return data.map((e) => ({
      description: e.description,
      iata: e.iata,
      icao: e.icao,
    }))
  }
}