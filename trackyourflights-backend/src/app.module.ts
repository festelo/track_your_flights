import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { RolesGuard } from './role/roles.guard';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { JwtAuthGuard } from './auth/jwt-auth.guard';
import { TypeOrmModule } from '@nestjs/typeorm';
import { root } from './paths';
import { HistoryService } from './history/history.service';
import { HistoryModule } from './history/history.module';
import { TrackModule } from './track/track.module';
import { RolesModule } from './role/roles.module';
import { ConfigurationModule } from './configuration/configuration.module';
import { FlightsModule } from './flights/flights.module';

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
  ],
})
export class AppModule {}
