import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { User } from 'src/users/user';
import { UsersService } from 'src/users/users.service';
import { AuthPayload } from './auth-payload';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(username: string, password: string): Promise<any> {
    const user = await this.usersService.findByUsername(username);
    if (user && user.password === password) {
      return user;
    }
    return null;
  }

  async login(user: User) {
    const payload = { sub: user.id, roles: user.roles } as AuthPayload;
    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
