import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { AirportsController } from './airports.controller';
import { AirportsService } from './airports.service';
import { FlightAwareAirportRepository } from './flightaware-airport-repository';

@Module({
  imports: [
    HttpModule,
  ],
  providers: [ 
    AirportsService, 
    FlightAwareAirportRepository, 
  ],
  controllers: [AirportsController],
})
export class AirportsModule {}
