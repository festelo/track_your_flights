import { Injectable } from '@nestjs/common';
import { ConfigurationService } from 'src/configuration/configuration.service';
import { Role } from 'src/role/role.enum';
import { User } from './user';

@Injectable()
export class UsersService {
  constructor(private configuration: ConfigurationService) {}

  async findByUsername(username: string): Promise<User | undefined> {
    return this.configuration.users().find(u => u.username == username);
  }
}
