import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as paths from 'src/paths';
import { AppConfiguration, SecretsConfiguration, UsersConfiguration } from './configuration.models';

@Injectable()
export class ConfigurationService {

  private secretsCached?: SecretsConfiguration;
  private usersCached?: UsersConfiguration;
  private configurationCached?: AppConfiguration;

  private load() {
    this.secretsCached = JSON.parse(
      fs.readFileSync(paths.secrets, 'utf8'),
    ) as SecretsConfiguration;

    this.usersCached = JSON.parse(
      fs.readFileSync(paths.users, 'utf8'),
    ) as UsersConfiguration;

    this.configurationCached = JSON.parse(
      fs.readFileSync(paths.configuration, 'utf8'),
    ) as AppConfiguration;
    
  }

  public secrets() {
    if (!this.secretsCached) {
      this.load();
    }
    return this.secretsCached;
  }

  public users() {
    if (!this.usersCached) {
      this.load();
    }
    return this.usersCached;
  }

  public configuration() {
    if (!this.configurationCached) {
      this.load();
    }
    return this.configurationCached;
  }
}
