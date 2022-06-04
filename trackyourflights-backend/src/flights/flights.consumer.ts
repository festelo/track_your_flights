import { HttpService } from "@nestjs/axios";
import { OnQueueActive, OnQueueCompleted, OnQueueFailed, OnQueueProgress, Process, Processor } from "@nestjs/bull";
import { Job } from "bull";
import * as moment from "moment";
import { Moment } from "moment";
import { Observable, Subject } from "rxjs";
import { FlightsService } from "./flights.service";
import { FlightAwareAdvancedRepository } from "./repositories/flightaware-advanced-repository";
import { FlightsDbRepository } from "./repositories/flights-db-repository";

export interface FlightJob {
  ident: string;
  aproxDate: Moment;
  minutesRange: number;
  originItea?: string;
  destItea?: string;
  cancelled: boolean;
}

export type FlightSearchEvent = FlightSearchStartedEvent
  | FlightSearchProgressEvent
  | FlightSearchFailedEvent
  | FlightSearchCompletedEvent

export interface FlightSearchStartedEvent {
  id: string;
  status: 'started';
}

export interface FlightSearchProgressEvent {
  id: string;
  status: 'progress';
  data: number
}

export interface FlightSearchFailedEvent {
  id: string;
  status: 'failed';
  error: any
}

export interface FlightSearchCompletedEvent {
  id: string;
  status: 'completed';
  data: any
}

@Processor('flights')
export class FlightsConsumer {
  constructor(
    private flightAwareAdvancedRepository: FlightAwareAdvancedRepository,
    private flightsDbRepository: FlightsDbRepository,
  ) {}

  private readonly subject = new Subject<FlightSearchEvent>()
  readonly observable = this.subject.asObservable()


  @OnQueueActive()
  onActive(job: Job) {
    this.subject.next({ 
      id: job.id.toString(),
      status: 'started'
    })
  }

  @OnQueueProgress()
  onProgress(job: Job, progress: any) {
    this.subject.next({ 
      id: job.id.toString(),
      status: 'progress',
      data: progress,
    })
  }

  @OnQueueCompleted()
  onCompleted(job: Job, result: any) {
    this.subject.next({ 
      id: job.id.toString(),
      status: 'completed',
      data: result,
    })
  }

  @OnQueueFailed()
  onQueueFailed(job: Job, error: any) {
    this.subject.next({ 
      id: job.id.toString(),
      status: 'failed',
      error,
    })
  }
  
  @Process()
  async search(job: Job<FlightJob>) {
    let errorCounter = 0;
    const startMinute = Math.floor((job.progress() ?? 0) * job.data.minutesRange);
    for (let i = startMinute; i < job.data.minutesRange; i++) {
      job = await job.queue.getJob(job.id)
      if (job.data.cancelled ) {
        throw new Error('cancelled')
      }
      job.data.aproxDate = moment(job.data.aproxDate)

      const dateTime = job.data.aproxDate.clone().add(
        i % 2 == 0 
          ? Math.floor(i / 2) 
          : Math.floor((i / 2)) * -1, 
        'minutes'
      )
      
      try {
        await job.progress(Math.floor(i / job.data.minutesRange * 100));
        const exists = await this.flightAwareAdvancedRepository.checkExistance({ 
          dateTime: dateTime.clone(), 
          routeInfo: { ...job.data }
        });
        if (exists) {
          const flights = await this.flightAwareAdvancedRepository.get({ 
            dateTime: dateTime.clone(), 
            routeInfo: { ...job.data }
          });
          if (flights.length != 0) {
            await this.flightsDbRepository.save(flights)
            return flights;
          }
        }
        dateTime.add(1, 'minute')
        errorCounter = 0;
      } catch (e) {
        console.log(e);
        errorCounter++
        if (errorCounter >= 10) {
          throw e;
        }
      }
    }
    if (job.data.cancelled ) {
      throw new Error('cancelled')
    }
    return [];
  }

}