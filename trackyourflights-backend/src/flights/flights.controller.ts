import { Controller, Get, Query } from '@nestjs/common';
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
  
  @Get('parse-times')
  async parseTime(@Query() query: ParseTimeDto) {
    return this.flightsService.parseAllTimes(query.ident, moment(query.startDate), query.originItea, query.destItea);
  }
  
}
