import { Body, Controller, Get, Post, Query, Response, Request, StreamableFile } from '@nestjs/common';
import { SaveKmlDto } from './track.dto';
import { TrackService } from './track.service';

@Controller('/track')
export class TrackController {
  constructor(private trackService: TrackService) {}
  
  @Post('save-kml')
  async saveKml(@Body() req: SaveKmlDto) {
    await this.trackService.saveKMLasGeojson(req.flightId, req.kml);
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