import { Body, Controller, Get, NotFoundException, Post, Request } from '@nestjs/common';
import { HistoryService } from './history.service';
import { OrderDto, UpdateOrderFlightDto } from './history.dto';
import { Order, OrderFlight } from './history.entities';
import { Flight, UserFlightSearch } from 'src/flights/flights.entities';

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
      seller: body.seller,
      link: body.link,
      comment: body.comment,
    });

    const flights = body.flights.map((e) => new OrderFlight({
      id: null,
      flight: e.flightId == null ? null : new Flight({
        id: e.flightId,
      }),
      flightSearch: e.searchId == null ? null : new UserFlightSearch({
        id: e.searchId
      }),
      order: order,
      personsCount: e.personsCount
    }));

    order.flights = flights;

    return this.historyService.add(order);
  }

  @Post('update-flight')
  async updateFlight(@Body() body: UpdateOrderFlightDto) {
    const flight = new OrderFlight({
      id: body.oldFlightId,
      flight: body.flight.flightId == null ? null : new Flight({
        id: body.flight.flightId,
      }),
      flightSearch: body.flight.searchId == null ? null : new UserFlightSearch({
        id: body.flight.searchId
      }),
      order: new Order({
        id: body.orderId,
      }),
      personsCount: body.flight.personsCount
    });
    const res = await this.historyService.updateOrderFlight(flight)
    if (!res) throw new NotFoundException();
  }

  @Get('get')
  async get(@Request() req) {
    return this.historyService.getAll(req.user.id);
  }
}