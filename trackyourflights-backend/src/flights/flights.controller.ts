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
}
