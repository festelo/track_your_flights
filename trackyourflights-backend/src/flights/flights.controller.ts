import { BadRequestException, Body, Controller, Delete, Get, Post, Query, Request } from '@nestjs/common';
import { IsBoolean, IsDateString } from 'class-validator';
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

class StartRangeSearchDto {
  @IsDateString()
  public aproxDate: string
  public ident: string
  public originItea?: string
  public destItea?: string
  @IsBoolean()
  public restart: boolean
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

  @Post('get/range')
  async getRangeStart(@Request() req, @Body() query: StartRangeSearchDto) {
    const aproxDate = moment(query.aproxDate)

    return this.flightsService.getRangeStart(req.user.id, {...query, aproxDate, minutesRange: 720});
  }

  @Get('get/range')
  async getRangeStatus(@Query('id') id: string) {
    return this.flightsService.getRangeStatus(id);
  }

  @Get('get/range/list')
  async getRangeList(@Request() req) {
    return this.flightsService.getByUserId(req.user.id);
  }

  @Get('get/range/retry')
  async getRangeRetry(@Query('id') id: string) {
    return this.flightsService.getByRangeRetry(id);
  }
  

  @Get('get/range/stop')
  async getRangeStop(@Query('id') id: string) {
    return this.flightsService.getRangeStop(id);
  }
}
