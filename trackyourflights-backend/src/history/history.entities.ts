import { IsNotEmpty, IsNumber } from "class-validator";
import { Flight, UserFlightSearch } from "src/flights/flights.entities";
import { Column, Entity, JoinColumn, ManyToOne, OneToMany, OneToOne, PrimaryGeneratedColumn } from "typeorm";

export class Price {
  @Column()
  @IsNumber()
  amount: number;

  @Column()
  @IsNotEmpty()
  currency: string;
}

@Entity()
export class Order {
  constructor(entity: Required<Order> |  {id: string}) {
      Object.assign(this, entity);
  }

  @PrimaryGeneratedColumn()
  id?: string;

  @Column()
  userId: string;

  @Column(() => Price)
  price: Price;

  @Column()
  orderedAt: Date;

  @Column({
    nullable: true,
  })
  comment?: string;


  @Column({
    nullable: true,
  })
  link?: string;


  @Column({
    nullable: true,
  })
  seller?: string;

  @OneToMany(() => OrderFlight, (flight) => flight.order)
  flights: Array<OrderFlight>;
}

@Entity()
export class OrderFlight {
  constructor(entity: Required<OrderFlight>) {
     Object.assign(this, entity);
  }

  @PrimaryGeneratedColumn()
  id?: string;

  @ManyToOne(() => Order, (order) => order.flights)
  order: Order;

  @OneToOne(() => Flight, {nullable: true})
  @JoinColumn()
  flight?: Flight;


  @OneToOne(() => UserFlightSearch, {nullable: true})
  @JoinColumn()
  flightSearch?: UserFlightSearch;

  @Column()
  personsCount: number;
}