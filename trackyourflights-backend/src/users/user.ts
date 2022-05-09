import { Role } from "src/role/role.enum";

export class User {
  constructor (public id: string, public username: string, public password: string, public roles: Role[]) {}
}