import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { lastValueFrom } from 'rxjs';
import { FlightApiDto } from 'src/flights/flights.models';
import { FlightInfo } from 'src/flights/flights.entities';

@Injectable()
export class FlightsService {
  constructor(private httpService: HttpService) {}


  async searchFlights(q: string) {
    const uri = new URL('https://flightaware.com/ajax/ignoreall/omnisearch/flight.rvt');
    uri.searchParams.append('searchterm', q);
    const res = await lastValueFrom(this.httpService.get(uri.toString(), {
      headers: { 'X-Locale': 'en_US' }
    }));
    const data = res.data.data as [{
      description: string,
      ident: string,
    }];
    return data.map((e) => ({
      description: e.description,
      ident: e.ident,
    }))
  }


  async getFlight(ident: string, date: Date) {
    const uri = new URL('https://flightxml.flightaware.com/mapi/v13/TrackIdent');
    
    uri.searchParams.append('ident', ident);
    uri.searchParams.append('skipActivityUpdate', 'true');
    uri.searchParams.append('howMany', '100');
    uri.searchParams.append('howMany', '100');

    const res = await lastValueFrom(this.httpService.get(uri.toString(), {
      headers: { 'X-Locale': 'en_US' }
    }));

    if (!res.data.TrackIdentResult) return [];
    
    const flights = res.data.TrackIdentResult.flights as [FlightApiDto]

    const mappedFlights = flights.map((e) => ({
      permaLink: e.flight_history_link,
      cancelled: false,
      aircraft: {
        friendlyType: e.display_aircrafttype,
        typeFull: e.full_aircrafttype,
        type: e.aircrafttype,
      },
      destination: {
        TZ: e.actualarrivaltime.tz,
        airport: e.display_destination.airport_name,
        city: e.display_destination.city,
        iata: e.display_destination.alternate_ident,
      },
      origin: {
        TZ: e.actualdeparturetime.tz,
        airport: e.display_origin.airport_name,
        city: e.display_origin.city,
        iata: e.display_origin.alternate_ident,
      },
      flightStatus: e.status,
      takeoffTimes: {
        scheduled: e.filed_departuretime?.epoch,
        estimated: e.estimateddeparturetime?.epoch,
        actual: e.actualdeparturetime?.epoch,
      },
      landingTimes: {
        scheduled: e.filed_arrivaltime?.epoch,
        estimated: e.estimatedarrivaltime?.epoch,
        actual: e.actualarrivaltime?.epoch,
      },
      gateDepartureTimes: {
        scheduled: e.sch_block_out?.epoch,
        estimated: e.est_block_out?.epoch,
        actual: e.act_block_out?.epoch,
      },
      gateArrivalTimes: {
        scheduled: e.sch_block_in?.epoch,
        estimated: e.est_block_in?.epoch,
        actual: e.act_block_in?.epoch,
      },
    }) as FlightInfo)
    
    return mappedFlights.filter((e) => {
      const flightDate = new Date(e.takeoffTimes.scheduled * 1000);
      return date.getUTCDate() == flightDate.getUTCDate() && 
        date.getUTCMonth() == flightDate.getUTCMonth() &&
        date.getUTCFullYear() == flightDate.getUTCFullYear();
    });
  }
}
