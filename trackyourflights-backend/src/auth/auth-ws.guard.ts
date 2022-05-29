import { CanActivate, ExecutionContext, Injectable } from "@nestjs/common";
import { ConfigurationService } from "src/configuration/configuration.service";
import { UsersService } from "src/users/users.service";
import * as jwt from 'jsonwebtoken'
import { PUBLIC_KEY } from "./auth.decorator";
import { Reflector } from "@nestjs/core";
import { Socket } from "socket.io";
import { JwtStrategy } from "./jwt.strategy";

@Injectable()
export class AuthWsGuard implements CanActivate {

  constructor(
    private reflector: Reflector,
  ) {
  }

  async canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      return true;
    }

    const authenticated = context.switchToWs().getClient().user != null;

    if (!authenticated) {
      const client = context.switchToWs().getClient() as WebSocket
      client.send('authentication failed')
    }

    return authenticated;
  }
}

@Injectable()
export class LocalAuthWsGuard implements CanActivate {

  constructor(
    private jwtStrategy: JwtStrategy,
    private configurationService: ConfigurationService,
  ) {
  }

  async canActivate(context: ExecutionContext) {
    const data = context.switchToWs().getData();
    if (data.token == null) return false;
    const bearerToken = data.token;
    try {
      const decoded = jwt.verify(bearerToken, this.configurationService.secrets().jwtSecret) as any
      const user = await this.jwtStrategy.validate(decoded);
      context.switchToWs().getClient().user = user;
      return user != null;
    } catch (ex) {
      const client = context.switchToWs().getClient() as WebSocket
      client.send('authentication failed')
      return false;
    }
  }
}