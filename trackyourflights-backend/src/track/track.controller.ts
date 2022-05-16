import { Body, Controller, Get, Post, Query, Response, Request, StreamableFile, BadRequestException } from '@nestjs/common';
import { SetupDto } from './track.dto';
import { TrackService } from './track.service';

@Controller('/track')
export class TrackController {
  constructor(private trackService: TrackService) {}
  
  @Post('setup')
  async setup(@Body() req: SetupDto) {
    if(!this.trackService.validateLink(req.permaLink)) {
      throw new BadRequestException()
    }
    await this.trackService.saveGeojsonForFlight(req.flightId, req.permaLink);
  }

  @Get('get')
  async get(@Query('flightId') flightId: string, @Response({ passthrough: true }) res) {
    const stream = this.trackService.getGeojson(flightId);
    res.set({
      'Content-Type': 'application/json',
    });
    return new StreamableFile(stream);
  }


  @Get('get-all')
  async getAll(@Request() req, @Response({ passthrough: true }) res) {
    const stream = await this.trackService.getUsersGeojsons(req.user.id);
    res.set({
      'Content-Type': 'application/json',
    });
    return new StreamableFile(stream);
  }
}