import { Injectable, Logger, UseGuards } from '@nestjs/common';
import {
  MessageBody,
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Subscription } from 'rxjs';
import { Server } from 'socket.io';
import { AuthWsGuard, LocalAuthWsGuard } from 'src/auth/auth-ws.guard';
import { Public } from 'src/auth/auth.decorator';
import { FlightsConsumer, FlightSearchEvent } from './flights.consumer';
import { FlightsService } from './flights.service';
import { FlightSearchDbRepository } from './repositories/flight-search-db-repository';

type OutMessage = {
  id?: string,
  channel?: string,
  data?: any,
}

type InMessage = {
  id?: string,
  [key: string]: any,
}

@WebSocketGateway(3001, { transports: ['websocket'] })
@UseGuards(AuthWsGuard)
@Injectable()
export class FlightsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  constructor(
    private consumer: FlightsConsumer, 
    private flightsService: FlightsService,
  ) { 
    this.subscription = this.consumer.observable.subscribe((e) => this.onFlightSearchEvent(e))
  }

  private logger: Logger = new Logger('FlightsGateway');
  private subscription: Subscription;

  readonly idToClient: Record<string, WebSocket> = {}

  @WebSocketServer()
  server: Server;

  handleConnection(client: WebSocket) {
    this.logger.log(`Client connected: ${client}`);
  }
  
  @SubscribeMessage('auth')
  @Public()
  @UseGuards(LocalAuthWsGuard)
  auth(@MessageBody() req: InMessage): OutMessage {
    return {
      id: req.id,
      data: 'ok',
    }
  }

  @SubscribeMessage('subscribe')
  subscribe(@ConnectedSocket() client: any, @MessageBody() req: InMessage): OutMessage {
    this.idToClient[client.user.id] = client;
    return {
      id: req.id,
      data: 'ok',
    }
  }

  async onFlightSearchEvent(e: FlightSearchEvent) {
    const userSearches = await this.flightsService.getBySearchId(e.id)
    for (const u of userSearches) {
      if (this.idToClient[u.userId]) {
        this.idToClient[u.userId].send(JSON.stringify({
          channel: 'flights-search',
          data: e
        } as OutMessage));
      }
    }

  }

  handleDisconnect(client: any) {
    delete this.idToClient[client.user.id];
  }
}
