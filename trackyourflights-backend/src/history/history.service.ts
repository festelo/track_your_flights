import { InjectQueue } from '@nestjs/bull';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Queue } from 'bull';
import { TrackService } from 'src/track/track.service';
import { Repository } from 'typeorm';
import { Order, OrderFlight } from './history.entities';

@Injectable()
export class HistoryService {
  constructor(
    @InjectQueue('flights') private flightsQueue: Queue,
    @InjectRepository(Order)
    private ordersRepository: Repository<Order>,
    @InjectRepository(OrderFlight)
    private flightsRepository: Repository<OrderFlight>,
    private trackService: TrackService,
  ) {}

  async add(entity: Order) {
    await this.ordersRepository.save(entity);
    for (const flight of entity.flights) {
      await this.flightsRepository.save(flight);
    }
  }

  async updateOrderFlight(flight: OrderFlight) {
    const order = await this.ordersRepository.findOne({
      where: {id: flight.order.id },
      loadRelationIds: true,
    });
    if (order == null) { return false; }
    for (let i = 0; i < order.flights.length; i++) {
      if (order.flights[i] as unknown as string == flight.id) {
        await this.flightsRepository.update(flight.id, flight);
        order.flights[i] = flight;
        return true;
      }
    }
    return false;
  }

  async getAll(userId: string) {
    const ordersInDb = await this.ordersRepository.find({ 
      where: { userId } ,
      relations: {
        flights: {
          flight: true,
          flightSearch: true,
        },
      }
    })

    return Promise.all(ordersInDb.map(async (o) => ({
      ...o,
      flights: await Promise.all(o.flights.map(async (f) => {
        const job = f.flightSearch == null ? null : await this.flightsQueue.getJob(f.flightSearch.searchId);
        return {
          ...f,
          flightSearch: f.flightSearch == null ? null : {
            ...f.flightSearch,
            state: await job.getState(),
            progress: await job.progress(),
            error: job.failedReason,
            data: job.returnvalue,
          },
          trackExists: f.flight?.id ? this.trackService.trackExists(f.flight?.id) : false,
        };
      }))
    })));
  }
}
