import { Module } from '@nestjs/common';
import { TrackService } from './track.service';
import { TrackController } from './track.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserFlightEntity } from 'src/history/history.entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserFlightEntity]),
  ],
  providers: [TrackService],
  controllers: [TrackController],
})
export class TrackModule {}
