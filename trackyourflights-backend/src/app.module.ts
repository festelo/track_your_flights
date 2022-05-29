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
    BullModule.forRoot({ 
      redis: {
        username: 'default',
        password: 'redispw',
        host: 'localhost',
        port: 55000,
      }
    }),
  ],
})
export class AppModule {}
