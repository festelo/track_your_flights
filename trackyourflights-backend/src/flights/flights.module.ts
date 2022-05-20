import { Module } from '@nestjs/common';
import { FlightsService } from './flights.service';
import { FlightsController } from './flights.controller';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Flight } from './flights.entities';
import { FlightAwareRepository } from './flightaware-repository';
import { FlightAwareAdvancedRepository } from './flightaware-advanced-repository';

@Module({
  imports: [
    TypeOrmModule.forFeature([Flight]), 
    HttpModule,
  ],
  providers: [ FlightsService ],
  controllers: [FlightsController],
  exports: [TypeOrmModule]
})
export class FlightsModule {}
