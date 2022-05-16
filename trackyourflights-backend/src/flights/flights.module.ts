import { Module } from '@nestjs/common';
import { FlightsService } from './flights.service';
import { FlightsController } from './flights.controller';
import { HttpModule } from '@nestjs/axios';

@Module({
  providers: [FlightsService],
  controllers: [FlightsController],
  imports: [HttpModule]
})
export class FlightsModule {}
