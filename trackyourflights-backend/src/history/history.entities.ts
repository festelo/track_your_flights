import { Column, Entity, PrimaryColumn, PrimaryGeneratedColumn } from "typeorm";
import { Type } from 'class-transformer';
import { IsNotEmpty, ArrayNotEmpty, ValidateNested } from 'class-validator';

@Entity()
export class HistoryEntity {
  constructor(entity: Required<HistoryEntity>) {
     Object.assign(this, entity);
  }

  @PrimaryGeneratedColumn()
  id?: string;

  @Column('simple-json')
  json: any;

  @Column()
  userId: string;
}

@Entity()
export class UserFlightEntity {
  constructor(entity: Required<UserFlightEntity>) {
     Object.assign(this, entity);
  }

  @PrimaryGeneratedColumn()
  id?: string;

  @Column()
  flightId: string;

  @Column()
  userId: string;
}
