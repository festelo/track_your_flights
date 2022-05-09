import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { HistoryController } from './history.controller';
import { HistoryService } from './history.service';
import { HistoryEntity, UserFlightEntity } from './history.entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([HistoryEntity]), 
    TypeOrmModule.forFeature([UserFlightEntity]),
  ],
  providers: [HistoryService],
  controllers: [HistoryController],
  exports: [TypeOrmModule]
})
export class HistoryModule {}
