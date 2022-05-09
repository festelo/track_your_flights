import { User } from "src/users/user"

export interface UsersConfiguration extends Array<User>{}

export interface SecretsConfiguration {
  jwtSecret: string
}