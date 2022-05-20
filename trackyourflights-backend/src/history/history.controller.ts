import { Body, Controller, Get, Post, Request } from '@nestjs/common';
import { HistoryService } from './history.service';
import { OrderDto } from './history.dto';
import { Order, OrderFlight } from './history.entities';
import { Flight } from 'src/flights/flights.entities';

@Controller('/history')
export class HistoryController {
  constructor(private historyService: HistoryService) {}
  
  @Post('add')
  async add(@Request() req, @Body() body: OrderDto) {
    const order = new Order({
      id: null,
      orderedAt: body.orderedAt,
      price: body.price,
      userId: req.user.id,
      flights: null,
    });

    const flights = body.flights.map((e) => new OrderFlight({
      id: null,
      flight: new Flight({
        id: e.flightId,
      }),
      order: order,
      personsCount: e.personsCount
    }));

    order.flights = flights;

    return this.historyService.add(order);
  }

  @Get('get')
  async get(@Request() req) {
    return this.historyService.getAll(req.user.id);
  }
}