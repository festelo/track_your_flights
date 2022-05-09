
import { IsNotEmpty, ArrayNotEmpty, ValidateNested } from 'class-validator';

export class SaveKmlDto {
  @IsNotEmpty()
  flightId: string;

  @IsNotEmpty()
  kml: string;
}
