import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { lastValueFrom } from 'rxjs';
import { Flight } from './flights.entities';
import { AdvancedResponse, FlightRoot } from './flights-advanced.models';
import * as assert from 'assert';
import { dateFromEpoch } from 'src/utils';
import { getIdentFromHistoryLink, getPathFromHistoryLink } from './flightaware-uri-utils';

type GetByParams = {
  historyUrl: string
} | {
  dateTime: moment.Moment,
  routeHistoryUrl: string,
} | {
  ident: string, 
  dateTime: moment.Moment,
  originItea: string,
  destItea: string,
};

interface GetByHistoryUrl {
  historyUrl: string
}

interface GetByRouteInfo {
  dateTime: moment.Moment,
  routeInfo: {
    historyUrlForSomeFlightOfThisRoute: string
  } | {
    ident: string, 
  } | {
    ident: string, 
    originItea: string,
    destItea: string,
  },
}

@Injectable()
export class FlightAwareAdvancedRepository {
  constructor(
    private httpService: HttpService,
  ) {}

  private async getLogPollToken(historyUrl: string) {
    const res = await lastValueFrom(this.httpService.get(historyUrl, {
      headers: { 
        'X-Locale': 'en_US',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'Accept-Language': 'en-GB,en;q=0.9,en-US;q=0.8,ru;q=0.7',
        'Cache-Control': 'max-age=0',
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36 Edg/100.0.1185.50'
      }
    }));
    const regex = /{"TOKEN":"([^"]*)"/;
    const tokenReg = (res.data as string).match(regex);
    const token = tokenReg[1];
    return token;
  }

  private formHistoryUrl(data: GetByRouteInfo) {
    let pathPart = '';
    let ident = '';
    
    if ('ident' in data.routeInfo  && data.routeInfo.ident) {
      ident = data.routeInfo.ident;
    } else if ('historyUrlForSomeFlightOfThisRoute' in data.routeInfo) {
      ident = getIdentFromHistoryLink(data.routeInfo.historyUrlForSomeFlightOfThisRoute);
    }

    if ('destItea' in data.routeInfo && 'originItea' in data.routeInfo && 
      data.routeInfo.destItea &&  data.routeInfo.originItea) {
      pathPart = `/${data.routeInfo.originItea}/${data.routeInfo.destItea}`
    } else if ('historyUrlForSomeFlightOfThisRoute' in data.routeInfo && 
      data.routeInfo.historyUrlForSomeFlightOfThisRoute) {
      const path = getPathFromHistoryLink(data.routeInfo.historyUrlForSomeFlightOfThisRoute);
      if (path != null) {
        pathPart = '/' + path.origin + '/' + path.dest;
      }
    }

    const encodedDate = encodeURIComponent(data.dateTime.utc().format('YYYYMMDD'))
    const encodedTime = encodeURIComponent(data.dateTime.utc().format('HHmm') + 'Z')

    assert(ident != null && encodedDate != null && encodedTime != null);

    let historyUrl = `/live/flight/${ident}/history/${encodedDate}/${encodedTime}${pathPart}`
    if (historyUrl.endsWith('/')) {
      historyUrl = historyUrl.substring(0, historyUrl.length - 1);
    }
    return historyUrl;
  }

  private async getByHistoryUrl(data: GetByHistoryUrl) {
    const logPollToken = await this.getLogPollToken('https://flightaware.com' + data.historyUrl)
    if (!logPollToken) {
      return null;
    }
    const trackPollUrl = new URL('https://flightaware.com/ajax/trackpoll.rvt')
    trackPollUrl.searchParams.append('token', logPollToken)
    const res = await lastValueFrom(this.httpService.get(trackPollUrl.toString(), {
      headers: { 
        'Cookie':
            'w_sid=305cfdef5f41d9988d8ef79370d872f21c31c0aff1c60c314374c7201b5ca3a2',
        'X-Locale': 'en_US',
      }
    }));
    const responseData = res.data as AdvancedResponse;
    if (!responseData.flights) {
      return null;
    }
    const keys = Object.keys(responseData.flights);
    if (keys.every((e: string) => e.includes('INVALID'))) {
      return null;
    }
    return responseData;
  }


  private async getByRouteInfo(data: GetByRouteInfo) {
    const historyUrl = this.formHistoryUrl(data)

    return this.getByHistoryUrl({ historyUrl })
  }

  public async get(data: GetByHistoryUrl | GetByRouteInfo) {
    let res: AdvancedResponse | null;
    if ('historyUrl' in data) {
      res = await this.getByHistoryUrl(data)
    } else {
      res = await this.getByRouteInfo(data)
    }

    if (!res) return [];

    return [...Object.values(res.flights)]
      .map((f) => new Flight({
        id: null,
        aircraft: {
          friendlyType: f.aircraft.friendlyType,
          type: f.aircraft.type,
          typeFull: f.aircraft.friendlyType,
        },
        cancelled: f.cancelled,
        destination: {
          TZ: f.destination.TZ,
          airport: f.destination.friendlyName,
          city: f.destination.friendlyLocation,
          iata: f.destination.icao,
        },
        origin: {
          TZ: f.origin.TZ,
          airport: f.origin.friendlyName,
          city: f.origin.friendlyLocation,
          iata: f.origin.icao,
        },
        flightAwarePermaLink: f.links.permanent,
        flightStatus: f.flightStatus,
        gateArrivalTimes: {
          actual: dateFromEpoch(f.gateArrivalTimes.actual),
          estimated: dateFromEpoch(f.gateArrivalTimes.estimated),
          scheduled: dateFromEpoch(f.gateArrivalTimes.scheduled),
        },
        gateDepartureTimes: {
          actual: dateFromEpoch(f.gateDepartureTimes.actual),
          estimated: dateFromEpoch(f.gateDepartureTimes.estimated),
          scheduled: dateFromEpoch(f.gateDepartureTimes.scheduled),
        },
        landingTimes: {
          actual: dateFromEpoch(f.landingTimes.actual),
          estimated: dateFromEpoch(f.landingTimes.estimated),
          scheduled: dateFromEpoch(f.landingTimes.scheduled),
        },
        takeoffTimes: {
          actual: dateFromEpoch(f.takeoffTimes.actual),
          estimated: dateFromEpoch(f.takeoffTimes.estimated),
          scheduled: dateFromEpoch(f.takeoffTimes.scheduled),
        },
        ident: f.displayIdent,
        indexingDate: dateFromEpoch(f.takeoffTimes.scheduled) || dateFromEpoch(f.takeoffTimes.estimated),
      }));
  }

  private async checkExistanceByHistoryUrl(data: GetByHistoryUrl) {
    const googleEarthUrl = new URL('https://flightaware.com' + data.historyUrl + '/google_earth')
    const res = await lastValueFrom(this.httpService.get(googleEarthUrl.toString(), {
      headers: { 
        'Cookie':
            'w_sid=305cfdef5f41d9988d8ef79370d872f21c31c0aff1c60c314374c7201b5ca3a2',
        'X-Locale': 'en_US',
      },
      validateStatus: (status) => true,
      timeout: 20000
    }));
    const responseData = (res.data as string).trim();
    if (responseData == 'No track log available') return false;
    if (responseData == 'Invalid request') throw new Error('Invalid request');
    return true;
  }

  public async checkExistance(data: GetByHistoryUrl | GetByRouteInfo) {
    let res: boolean;
    if ('historyUrl' in data) {
      res = await this.checkExistanceByHistoryUrl(data)
    } else {
      const historyUrl = this.formHistoryUrl(data)
      res = await this.checkExistanceByHistoryUrl({historyUrl})
    }
    return res;
  }
}