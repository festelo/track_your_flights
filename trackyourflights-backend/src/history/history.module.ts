import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HistoryController } from './history.controller';
import { HistoryService } from './history.service';
import { Order, OrderFlight } from './history.entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([Order]), 
    TypeOrmModule.forFeature([OrderFlight]),
  ],
  providers: [HistoryService],
  controllers: [HistoryController],
  exports: [TypeOrmModule]
})
export class HistoryModule {}
