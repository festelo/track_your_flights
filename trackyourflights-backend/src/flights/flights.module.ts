import { Module } from '@nestjs/common';
import { FlightsService } from './flights.service';
import { FlightsController } from './flights.controller';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Flight, UserFlightSearch } from './flights.entities';
import { FlightAwareRepository } from './repositories/flightaware-repository';
import { FlightAwareAdvancedRepository } from './repositories/flightaware-advanced-repository';
import { BullModule } from '@nestjs/bull';
import { FlightsConsumer } from './flights.consumer';
import { FlightsDbRepository } from'./repositories/flights-db-repository'
import { FlightsGateway } from './flights.gateway';
import { AuthModule } from 'src/auth/auth.module';
import { FlightSearchDbRepository } from './repositories/flight-search-db-repository';

@Module({
  imports: [
    TypeOrmModule.forFeature([Flight, UserFlightSearch]), 
    HttpModule,
    BullModule.registerQueue({
      name: 'flights',
    }),
    AuthModule,
  ],
  providers: [ 
    FlightsService, 
    FlightsConsumer, 
    FlightsDbRepository,
    FlightSearchDbRepository,
    FlightAwareAdvancedRepository, 
    FlightAwareRepository,
    FlightsGateway,
  ],
  controllers: [FlightsController],
  exports: [TypeOrmModule]
})
export class FlightsModule {}
