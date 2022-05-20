
import { Type } from 'class-transformer';
import { ArrayNotEmpty, IsDate, IsNotEmpty, IsString, Min, ValidateNested } from 'class-validator';
import { Price } from './history.entities';

export class OrderDto {
  @Type(() => Price)
  @ValidateNested()
  @IsNotEmpty()
  price: Price;

  @IsDate()
  orderedAt: Date;
  
  @ArrayNotEmpty()
  @Type(() => OrderFlightDto)
  @ValidateNested()
  flights: OrderFlightDto[];
}

export class OrderFlightDto {
  @IsNotEmpty()
  @IsString()
  flightId: string
  
  @Min(1)
  personsCount: number;
}