
import { IsNotEmpty, ArrayNotEmpty, ValidateNested } from 'class-validator';

export class SetupDto {
  @IsNotEmpty()
  flightId: string;

  @IsNotEmpty()
  permaLink: string;
}
