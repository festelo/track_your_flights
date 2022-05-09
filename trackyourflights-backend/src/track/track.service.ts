import { BadRequestException, Injectable } from '@nestjs/common';
import * as tj from '@mapbox/togeojson';
import * as geojsonMerge from '@mapbox/geojson-merge';
import { writeFile, checkIfFileOrDirectoryExists } from './storage.helper';
import * as paths from 'src/paths';
import * as path from "path"
import { DOMParser } from 'xmldom';
import { createReadStream } from 'fs';
import { InjectRepository } from '@nestjs/typeorm';
import { UserFlightEntity } from 'src/history/history.entities';
import { Repository } from 'typeorm';

@Injectable()
export class TrackService {
  constructor(
    @InjectRepository(UserFlightEntity)
    private userFlightsRepository: Repository<UserFlightEntity>,
  ) {}

  public async saveKMLasGeojson(flightId: string, kml: string) {
    const parsedKml = new DOMParser().parseFromString(kml);
    const geojson = tj.kml(parsedKml);
    await this.saveGeojson(flightId, geojson);
  }

  private async saveGeojson(flightId: string, kml: any) {
    await writeFile(this.resolvePath(flightId, { checkForExistance: false }), JSON.stringify(kml) )
  }

  private resolvePath(flightId: string, params : {checkForExistance: boolean} = { checkForExistance: true}) { 
    flightId = flightId.replace('/', '_').replace('\\', '_');
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
    const flightEntities = await this.userFlightsRepository.findBy({
      userId: userId,
    })
    return geojsonMerge.mergeFeatureCollectionStream(
      flightEntities.map((e) => this.resolvePath(e.flightId))
    ) 
  }
}
