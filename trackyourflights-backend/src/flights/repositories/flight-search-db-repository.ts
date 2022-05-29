import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Moment } from "moment";
import { Between, Repository } from "typeorm";
import { Flight, UserFlightSearch } from "../flights.entities";

@Injectable()
export class FlightSearchDbRepository {
  constructor(
    @InjectRepository(UserFlightSearch)
    private flightsRepository: Repository<UserFlightSearch>,
  ) {}

  async save(search: UserFlightSearch) {
    const res = await this.flightsRepository.findOne({
      where: {
        searchId: search.searchId,
        userId: search.userId
      }
    })
    if (res == null) {
      await this.flightsRepository.save(search);
    }
  }



  async getBySearchId(searchId: string) {
    return await this.flightsRepository.find({
      where: {
        searchId,
      }
    })
  }

  async getByUserId(userId: string) {
    return await this.flightsRepository.find({
      where: {
        userId,
      }
    })
  }
}