import { Column, Entity, PrimaryColumn, PrimaryGeneratedColumn } from "typeorm";

export class Waypoint {
  @Column({
    nullable: true,
  })
  TZ: string;
  @Column({
    nullable: true,
  })
  iata: string;
  @Column({
    nullable: true,
  })
  airport: string;
  @Column({
    nullable: true,
  })
  city: string;
}

export class TimeSet {
  @Column({
    nullable: true,
  })
  actual?: Date;

  @Column({
    nullable: true,
  })
  estimated?: Date;

  @Column({
    nullable: true,
  })
  scheduled?: Date;
}

export class JetInfo {
  @Column({
    nullable: true,
  })
  friendlyType?: string;

  @Column({
    nullable: true,
  })
  typeFull?: string;

  @Column({
    nullable: true,
  })
  type?: string;
}
@Entity()
export class Flight {
  constructor(entity: Required<Flight> |  {id: string}) {
     Object.assign(this, entity);
  }

  @PrimaryGeneratedColumn()
  id?: string;

  @Column()
  ident: string;

  @Column()
  indexingDate: Date;

  @Column({
    nullable: true,
  })
  flightAwarePermaLink: string;
  
  @Column()
  cancelled: boolean;
  
  @Column()
  flightStatus: string;
  
  @Column(() => Waypoint)
  origin: Waypoint;

  @Column(() => Waypoint)
  destination: Waypoint;

  @Column(() => TimeSet)
  gateArrivalTimes: TimeSet;

  @Column(() => TimeSet)
  gateDepartureTimes: TimeSet;

  @Column(() => TimeSet)
  landingTimes: TimeSet;

  @Column(() => TimeSet)
  takeoffTimes: TimeSet;

  @Column(() => JetInfo)
  aircraft: JetInfo;
}