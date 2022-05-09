
import { Type } from 'class-transformer';
import { IsNotEmpty, ArrayNotEmpty, ValidateNested } from 'class-validator';

export class OrderDto {
  @IsNotEmpty()
  id: string;

  @ArrayNotEmpty()
  @ValidateNested()
  @Type(() => FlightDto)
  flights: FlightDto[];

  [x: string | number | symbol]: unknown;
}

export class FlightDto {
  @IsNotEmpty()
  id: string;
  [x: string | number | symbol]: unknown;
}