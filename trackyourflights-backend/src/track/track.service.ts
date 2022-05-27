import { BadRequestException, Injectable } from '@nestjs/common';
import * as tj from '@mapbox/togeojson';
import * as geojsonMerge from '@mapbox/geojson-merge';
import { writeFile, checkIfFileOrDirectoryExists } from './storage.helper';
import * as paths from 'src/paths';
import * as path from "path"
import { DOMParser } from 'xmldom';
import { createReadStream } from 'fs';
import { InjectRepository } from '@nestjs/typeorm';
import { OrderFlight } from 'src/history/history.entities';
import { Repository } from 'typeorm';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import { Flight } from 'src/flights/flights.entities';

@Injectable()
export class TrackService {
  constructor(
    @InjectRepository(Flight)
    private flightsRepository: Repository<Flight>,
    @InjectRepository(OrderFlight)
    private userFlightsRepository: Repository<OrderFlight>,
    private httpService: HttpService,
  ) {}

  public validateLink(permalink: string) {
    return !!/\/live\/flight\/[\da-zA-Z]+\/history\/[\d]+\/[\d]+Z\/[a-zA-Z]+\/[a-zA-Z]+/g.test(permalink)
  }

  public async saveGeojsonForFlight(flightId: string) {
    const flight = await this.flightsRepository.findOneBy({
      id: flightId
    });
    const kml = await this.getKML(flight.flightAwarePermaLink);
    await this.saveKMLasGeojson(flightId, kml);
  }

  private async getKML(permalink: string) {
    const kmlLink = `https://flightaware.com/${permalink}/google_earth`;
    const kml = await lastValueFrom(this.httpService.get(kmlLink))
    return kml.data.toString()
  }

  private async saveKMLasGeojson(flightId: string, kml: string) {
    const parsedKml = new DOMParser().parseFromString(kml);
    const geojson = tj.kml(parsedKml);
    await this.saveGeojson(flightId, geojson);
  }

  private async saveGeojson(flightId: string, kml: any) {
    await writeFile(this.resolvePath(flightId, { checkForExistance: false }), JSON.stringify(kml) )
  }

  private resolvePath(flightId: string, params : {checkForExistance: boolean} = { checkForExistance: true}) { 
    flightId = flightId.toString().replace('/', '_').replace('\\', '_');
    const resolvedPath = path.resolve(paths.tracks,`${flightId}.geojson`);
    if (params.checkForExistance && !checkIfFileOrDirectoryExists(resolvedPath)) {
      throw new BadRequestException(`Geojson for ${flightId} doesnt exist`);
    }
    return resolvedPath; 
  }

  public getGeojson(flightId: string) { 
    return createReadStream(this.resolvePath(flightId)); 
  }

  public async getUsersGeojsons(userId: string)  { 
    const flightEntities = await this.userFlightsRepository.find({
      where: {
        order: {
          userId: userId,
        }
      },
      relations: {
        flight: true,
      },
    })
    return geojsonMerge.mergeFeatureCollectionStream(
      flightEntities.map((e) => this.resolvePath(e.flight.id))
    ) 
  }
}
