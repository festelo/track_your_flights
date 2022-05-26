import { BadRequestException, Controller, Get, Query } from '@nestjs/common';
import { IsDateString } from 'class-validator';
import { FlightsService } from './flights.service';
import * as moment from 'moment';

class GetDto {
  @IsDateString()
  public date: string
  public ident: string
  public originItea?: string
  public destItea?: string
  public checkTime: string
}

class ParseTimeDto {
  @IsDateString()
  public startDate: string
  public ident: string
  public originItea?: string
  public destItea?: string
}

@Controller('flights')
export class FlightsController {
  constructor(private flightsService: FlightsService) {}

  @Get('search')
  async search(@Query('q') q: string) {
    return this.flightsService.searchFlights(q);
  }


  @Get('get')
  async get(@Query() query: GetDto) {
    return this.flightsService.getFlight(query.ident, moment(query.date), query.originItea, query.destItea, query.checkTime == 'true');
  }

  @Get('get/flightaware')
  async getByFlightaware(@Query('link') link: string) {
    const linkRegex = /^(?:(?:https:\/\/)?[\w]*.?flightaware.com)?(\/live\/.+)$/
    const match = link.match(linkRegex);

    if (!match) {
      throw new BadRequestException('Bad link')
    }
    return this.flightsService.getFlightByFlightaware(match[1]);
  }
  
  @Get('parse-times')
  async parseTime(@Query() query: ParseTimeDto) {
    return this.flightsService.parseAllTimes(query.ident, moment(query.startDate), query.originItea, query.destItea);
  }
  
}
