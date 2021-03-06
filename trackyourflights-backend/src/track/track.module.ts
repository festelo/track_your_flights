import { Module } from '@nestjs/common';
import { TrackService } from './track.service';
import { TrackController } from './track.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Order, OrderFlight } from 'src/history/history.entities';
import { HttpModule } from '@nestjs/axios';
import { Flight } from 'src/flights/flights.entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([OrderFlight, Flight]),
    HttpModule,
  ],
  providers: [TrackService],
  controllers: [TrackController],
  exports: [TrackService]
})
export class TrackModule {}
