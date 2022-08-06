import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { root } from './paths';
import { HistoryModule } from './history/history.module';
import { TrackModule } from './track/track.module';
import { RolesModule } from './role/roles.module';
import { ConfigurationModule } from './configuration/configuration.module';
import { FlightsModule } from './flights/flights.module';
import { BullModule } from '@nestjs/bull';
import { AirportsModule } from './airports/airports.module';
import { ConfigurationService } from './configuration/configuration.service';

@Module({
  imports: [
    ConfigurationModule,
    AuthModule, 
    UsersModule, 
    HistoryModule,
    TrackModule,
    RolesModule,
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: `${root}/data/db.sqlite`,
      synchronize: true,
      autoLoadEntities: true,
    }), 
    HistoryModule, 
    FlightsModule,
    AirportsModule,
    BullModule.forRootAsync({
      useFactory: (configService: ConfigurationService) => ({
        redis: configService.redis(),
      }),
      inject: [ConfigurationService],
      imports: [ConfigurationModule]

    }),
  ],
})
export class AppModule {}
