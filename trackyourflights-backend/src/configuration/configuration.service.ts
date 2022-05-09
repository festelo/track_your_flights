import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as paths from 'src/paths';
import { SecretsConfiguration, UsersConfiguration } from './configuration.models';

@Injectable()
export class ConfigurationService {

  private secretsCached?: SecretsConfiguration;
  private usersCached?: UsersConfiguration;

  private load() {
    this.secretsCached = JSON.parse(
      fs.readFileSync(paths.secrets, 'utf8'),
    ) as SecretsConfiguration;

    this.usersCached = JSON.parse(
      fs.readFileSync(paths.users, 'utf8'),
    ) as UsersConfiguration;
    
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
}
