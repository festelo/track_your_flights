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

class GetRangeDto {
  @IsDateString()
  public startDate: string
  @IsDateString()
  public endDate: string
  public ident: string
  public originItea?: string
  public destItea?: string
}

class GetRangeDtoStart extends GetRangeDto {
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
  
  private verifyRangeDate(startDate: moment.Moment, endDate: moment.Moment) {
    const range = endDate.diff(startDate, 'h')
    if (startDate.isSameOrAfter(endDate)) {
      throw new BadRequestException('End date must be after start date')
    }
    if (range > 24) {
      throw new BadRequestException('24 hours range max')
    }
  }

  @Post('get/range')
  async getRangeStart(@Request() req, @Body() query: GetRangeDtoStart) {
    const startDate = moment(query.startDate)
    const endDate = moment(query.endDate)
    this.verifyRangeDate(startDate, endDate);

    return this.flightsService.getRangeStart(req.user.id, {...query, startDate, endDate});
  }

  @Get('get/range')
  async getRangeStatus(@Query() query: GetRangeDto) {
    const startDate = moment(query.startDate)
    const endDate = moment(query.endDate)
    this.verifyRangeDate(startDate, endDate);

    return this.flightsService.getRangeStatus({...query, startDate, endDate});
  }

  @Get('get/range/list')
  async getRangeList(@Request() req) {
    return this.flightsService.getByUserId(req.user.id);
  }
  

  @Delete('get/range')
  async getRangeStop(@Query() query: GetRangeDto) {
    const startDate = moment(query.startDate)
    const endDate = moment(query.endDate)
    this.verifyRangeDate(startDate, endDate);

    return this.flightsService.getRangeStop({...query, startDate, endDate});
  }
}
