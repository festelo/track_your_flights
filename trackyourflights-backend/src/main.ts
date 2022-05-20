import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigurationService } from './configuration/configuration.service';

import * as moment from "moment";
import "moment-timezone";

async function bootstrap() {
  moment.tz.setDefault('Etc/UTC');

  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigurationService) 
  app.enableCors()
  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    forbidUnknownValues: true,
    skipMissingProperties: false,
    skipNullProperties: false,
    skipUndefinedProperties: false,
    transformOptions: {
      enableImplicitConversion: true,
    },
  }));
  app.setGlobalPrefix(config.configuration().globalPrefix);
  await app.listen(3000);
}
bootstrap();
