import { Module } from '@nestjs/common';
import { TrackService } from './track.service';
import { TrackController } from './track.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Order, OrderFlight } from 'src/history/history.entities';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [
    TypeOrmModule.forFeature([Order, OrderFlight]),
    HttpModule,
  ],
  providers: [TrackService],
  controllers: [TrackController],
})
export class TrackModule {}
