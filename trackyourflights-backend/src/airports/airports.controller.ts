import { Controller, Get, Query } from '@nestjs/common';

import { AirportsService } from './airports.service';


@Controller('airports')
export class AirportsController {
  constructor(private airportsService: AirportsService) {}

  @Get('search')
  async search(@Query('q') q: string) {
    return this.airportsService.searchAirports(q);
  }
}
