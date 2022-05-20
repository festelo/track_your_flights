import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, OrderFlight } from './history.entities';

@Injectable()
export class HistoryService {
  constructor(
    @InjectRepository(Order)
    private ordersRepository: Repository<Order>,
    @InjectRepository(OrderFlight)
    private flightsRepository: Repository<OrderFlight>,
  ) {}

  async add(entity: Order) {
    await this.ordersRepository.save(entity);
    for (const flight of entity.flights) {
      await this.flightsRepository.save(flight);
    }
  }

  async getAll(userId: string) {
    return await this.ordersRepository.find({ 
      where: { userId } ,
      relations: {
        flights: {
          flight: true,
        },
      }
    })
  }
}
