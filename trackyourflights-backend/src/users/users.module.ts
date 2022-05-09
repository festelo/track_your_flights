import { Module } from '@nestjs/common';
import { ConfigurationModule } from 'src/configuration/configuration.module';
import { UsersService } from './users.service';

@Module({
  providers: [UsersService],
  imports: [ConfigurationModule],
  exports: [UsersService],
})
export class UsersModule {}
