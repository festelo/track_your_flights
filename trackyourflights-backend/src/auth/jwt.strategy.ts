import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable } from '@nestjs/common';
import { AuthPayload } from './auth-payload';
import { ConfigurationService } from 'src/configuration/configuration.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configuration: ConfigurationService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configuration.secrets().jwtSecret,
    });
  }

  async validate(payload: AuthPayload) {
    return {
      id: payload.sub,
      roles: payload.roles,
    }
  }
}