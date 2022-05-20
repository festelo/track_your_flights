import { IsNotEmpty, IsNumber } from "class-validator";
import { Flight } from "src/flights/flights.entities";
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
  constructor(entity: Required<Order>) {
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

  @OneToOne(() => Flight)
  @JoinColumn()
  flight: Flight;

  @Column()
  personsCount: number;
}