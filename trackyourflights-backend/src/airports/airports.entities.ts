import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class Airport {
  constructor(entity: Required<Airport> |  {id: string}) {
     Object.assign(this, entity);
  }

  @PrimaryGeneratedColumn()
  id?: string;

  @Column()
  icao: string

  @Column()
  iata: string

  @Column()
  searchId: string

  @Column()
  ident: string;
  
  @Column()
  aproxDate: Date;
  
  @Column({
    default: 720
  })
  minutesRange: number;

  @Column({
    nullable: true,
  })
  originItea: string;

  @Column({
    nullable: true,
  })
  destItea: string;
}