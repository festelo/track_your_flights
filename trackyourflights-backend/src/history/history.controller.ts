import { Body, Controller, Get, Post, Request } from '@nestjs/common';
import { HistoryService } from './history.service';
import { HistoryEntity } from './history.entities';
import { OrderDto } from './history.dto';

@Controller('/history')
export class HistoryController {
  constructor(private historyService: HistoryService) {}
  
  @Post('add')
  async add(@Request() req, @Body() order: OrderDto) {
    return this.historyService.add(
      new HistoryEntity({
          id: undefined,
          json: order,
          userId: req.user.id,
      }), 
      req.user.id, 
      order.flights.map((e) => e.id),
    );
  }

  @Get('get')
  async get(@Request() req) {
    return this.historyService.getAll(req.user.id);
  }
}