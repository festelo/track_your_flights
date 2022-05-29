import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Moment } from "moment";
import { Between, Repository } from "typeorm";
import { Flight } from "../flights.entities";

@Injectable()
export class FlightsDbRepository {
  constructor(
    @InjectRepository(Flight)
    private flightsRepository: Repository<Flight>,
  ) {}

  async save(flights: Flight[]) {
    if (flights.length == 0) return;

    const flightsMap: Record<string, Record<string, Flight>> = {};

    const paramsPlaceholders = [];
    for (let counter = 0, i = 0; i < flights.length; i++, counter += 2) {
      paramsPlaceholders.push(`(:p${counter}, :p${counter + 1})`)
      
      flightsMap[flights[i].ident] ??= {}
      flightsMap[flights[i].ident][flights[i].indexingDate.toISOString()] = flights[i]
    }

    const paramsPlaceholdersString = paramsPlaceholders.join(',')

    const paramsArray = flights.flatMap((e) => ([e.ident, e.indexingDate ]))
    const paramsObj = {}
    for (let i = 0; i < paramsArray.length; i++) {
      paramsObj['p' + i] = paramsArray[i];
    }


    const databaseFlights = await this.flightsRepository
      .createQueryBuilder()
      .where(
        `(ident, indexingDate) in ( VALUES ${paramsPlaceholdersString})`, 
        paramsObj
      )
      .getMany()

    for (const flight of databaseFlights) {
      const flightToUpdate = flightsMap[flight.ident] && flightsMap[flight.ident][flight.indexingDate.toISOString()];
      if (!flightToUpdate) continue;
      flightToUpdate.id = flight.id;
    }

    await this.flightsRepository.save(flights);
  }



  async get(ident: string, date?: Moment, originItea?: string, destItea?: string, checkTime: boolean = false) {
    return await this.flightsRepository.find({
      where: {
        ident: ident,
        indexingDate: date ? Between(
          checkTime 
            ? date.startOf('minute').toDate()
            : date.startOf('day').toDate(),
          checkTime 
            ? date.endOf('minute').toDate()
            : date.endOf('day').toDate(),
        ) : undefined,
        origin: originItea ? {
          iata: originItea
        } : undefined,
        destination: destItea ? {
          iata: destItea
        } : undefined,
      }
    })
  }

  async getByFlightawareLink(flightAwareLink: string) {
    return await this.flightsRepository.find({
      where: {
        flightAwarePermaLink: flightAwareLink,
      }
    })
  }
}