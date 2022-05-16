import { Module } from '@nestjs/common';
import { TrackService } from './track.service';
import { TrackController } from './track.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserFlightEntity } from 'src/history/history.entities';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserFlightEntity]),
    HttpModule,
  ],
  providers: [TrackService],
  controllers: [TrackController],
})
export class TrackModule {}
