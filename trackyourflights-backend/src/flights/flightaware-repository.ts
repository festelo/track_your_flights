import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { lastValueFrom } from 'rxjs';
import { FlightApiDto } from './flights.models';
import { Flight } from './flights.entities';
import { dateFromEpoch } from 'src/utils';
import { getPathFromHistoryLink } from './flightaware-uri-utils';

@Injectable()
export class FlightAwareRepository {
  constructor(
    private httpService: HttpService,
  ) {}

  async search(q: string) {
    const uri = new URL('https://flightaware.com/ajax/ignoreall/omnisearch/flight.rvt');
    uri.searchParams.append('searchterm', q);
    const res = await lastValueFrom(this.httpService.get(uri.toString(), {
      headers: { 'X-Locale': 'en_US' }
    }));
    const data = res.data.data as [{
      description: string,
      ident: string,
    }];
    data.sort((a, b) => {
      if (a.description == 'Unknown Owner') {
        return 1;
      }
      if (b.description == 'Unknown Owner') {
        return -1;
      }
      return 0;
    })
    return data.map((e) => ({
      description: e.description,
      ident: e.ident,
    }))
  }

  async get(ident: string) {

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

    const mappedFlights = flights.map((e) => {
      const indexingDate = new Date(e.filed_departuretime.epoch * 1000);
      const path = getPathFromHistoryLink(e.flight_history_link)
      return new Flight({
        id: null,
        flightAwarePermaLink: e.flight_history_link,
        cancelled: false,
        ident: ident,
        indexingDate: indexingDate,
        aircraft: {
          friendlyType: e.display_aircrafttype,
          typeFull: e.full_aircrafttype,
          type: e.aircrafttype,
        },
        destination: {
          TZ: e.actualarrivaltime.tz ?? e.filed_arrivaltime.tz ?? e.estimatedarrivaltime.tz,
          airport: e.display_destination.airport_name,
          city: e.display_destination.city,
          iata: path?.dest,
        },
        origin: {
          TZ: e.actualdeparturetime.tz ?? e.filed_departuretime.tz ?? e.estimateddeparturetime.tz,
          airport: e.display_origin.airport_name,
          city: e.display_origin.city,
          iata: path?.origin,
        },
        flightStatus: e.status,
        takeoffTimes: {
          scheduled: dateFromEpoch(e.filed_departuretime?.epoch),
          estimated: dateFromEpoch(e.estimateddeparturetime?.epoch),
          actual: dateFromEpoch(e.actualdeparturetime?.epoch),
        },
        landingTimes: {
          scheduled: dateFromEpoch(e.filed_arrivaltime?.epoch),
          estimated: dateFromEpoch(e.estimatedarrivaltime?.epoch),
          actual: dateFromEpoch(e.actualarrivaltime?.epoch),
        },
        gateDepartureTimes: {
          scheduled: dateFromEpoch(e.sch_block_out?.epoch),
          estimated: dateFromEpoch(e.est_block_out?.epoch),
          actual: dateFromEpoch(e.act_block_out?.epoch),
        },
        gateArrivalTimes: {
          scheduled: dateFromEpoch(e.sch_block_in?.epoch),
          estimated: dateFromEpoch(e.est_block_in?.epoch),
          actual: dateFromEpoch(e.act_block_in?.epoch),
        },
      }
    )});

    return mappedFlights;
  }
}