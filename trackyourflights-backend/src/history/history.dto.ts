
import { Type } from 'class-transformer';
import { ArrayNotEmpty, IsDate, IsNotEmpty, IsString, Min, ValidateIf, ValidateNested } from 'class-validator';
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

  comment?: string;
  link?: string;
  seller?: string;
}

export class OrderFlightDto {
  
  @ValidateIf((o) => !o.searchId || o.flightId)
  flightId?: string

  @ValidateIf((o) => !o.flightId || o.searchId)
  searchId?: string
  
  @Min(1)
  personsCount: number;
}

export class UpdateOrderFlightDto {
  @IsString()
  @IsNotEmpty()
  orderId: string;

  @IsString()
  @IsNotEmpty()
  oldFlightId: string;
  
  @Type(() => OrderFlightDto)
  @ValidateNested()
  flight: OrderFlightDto;
}