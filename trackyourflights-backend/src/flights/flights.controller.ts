import { Controller, Get, Query } from '@nestjs/common';
import { IsDate, IsDateString } from 'class-validator';
import { FlightsService } from './flights.service';

class GetDto {
  @IsDate()
  public date: Date
  public ident: string
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
    return this.flightsService.getFlight(query.ident, query.date);
  }
}
