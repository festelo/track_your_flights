import * as path from "path"

export const root: string = path.resolve(__dirname, "..")
export const tracks: string = path.resolve(__dirname, "..", "tracks")
export const secrets: string = path.resolve(__dirname, "..", "configuration", "secrets.json")
export const users: string = path.resolve(__dirname, "..", "configuration", "users.json")
export const configuration: string = path.resolve(__dirname, "..", "configuration", "configuration.json")
export const redis: string = path.resolve(__dirname, "..", "configuration", "redis.json")