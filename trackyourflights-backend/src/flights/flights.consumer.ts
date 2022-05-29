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
  startDate: Moment;
  endDate: Moment;
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
  data: any
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
    job.data.endDate = moment(job.data.endDate)
    job.data.startDate = moment(job.data.startDate)
    const dateTime = job.data.startDate
    let errorCounter = 0;
    while (true) {
      job = await job.queue.getJob(job.id)
      if (job.data.cancelled ) {
        throw new Error('cancelled')
      }
      
      try {
        job.progress(dateTime);
        const exists = await this.flightAwareAdvancedRepository.checkExistance({ 
          dateTime: dateTime.clone(), 
          routeInfo: { ...job.data }
        });
        if (exists) {
          const flight = await this.flightAwareAdvancedRepository.get({ 
            dateTime: dateTime.clone(), 
            routeInfo: { ...job.data }
          });
          this.flightsDbRepository.save(flight)
          return flight
        }
        dateTime.add(1, 'minute')
        errorCounter = 0;
        if (dateTime.isSameOrAfter(job.data.endDate)) {
          break;
        }
      } catch (e) {
        console.log(e);
        errorCounter++
        if (errorCounter >= 10) {
          throw e;
        }
      }
    }
    return [];
  }

}