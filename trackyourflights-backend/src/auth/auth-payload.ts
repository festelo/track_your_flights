import { Role } from "src/role/role.enum";

export interface AuthPayload { sub: string, roles: Role[] }