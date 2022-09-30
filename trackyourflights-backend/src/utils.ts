import 'moment-timezone'

export function dateFromEpoch(date?: number) {
  return date == null ? null : new Date(date * 1000);
}