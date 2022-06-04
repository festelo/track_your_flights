import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HistoryController } from './history.controller';
import { HistoryService } from './history.service';
import { Order, OrderFlight } from './history.entities';
import { TrackModule } from 'src/track/track.module';
import { BullModule } from '@nestjs/bull';

@Module({
  imports: [
    TypeOrmModule.forFeature([Order]), 
    TypeOrmModule.forFeature([OrderFlight]),
    TrackModule,
    BullModule.registerQueue({
      name: 'flights',
    }),
  ],
  providers: [HistoryService],
  controllers: [HistoryController],
  exports: [TypeOrmModule]
})
export class HistoryModule {}
