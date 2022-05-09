import { Injectable } from '@nestjs/common';
import { InjectConnection, InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { HistoryEntity, UserFlightEntity } from './history.entities';

@Injectable()
export class HistoryService {
  constructor(
    @InjectRepository(HistoryEntity)
    private historyRepository: Repository<HistoryEntity>,
    @InjectRepository(UserFlightEntity)
    private userFlightsRepository: Repository<UserFlightEntity>,
  ) {}

  async add(entity: HistoryEntity, userId: string, flightIds: string[]) {
    await this.historyRepository.save(entity);
    await this.userFlightsRepository.save(
      flightIds.map((flightId) => new UserFlightEntity({
        id: undefined,
        flightId,
        userId,
      }))
    )
  }

  async getAll(userId: string) {
    return await this.historyRepository.findBy({ userId })
  }
}
