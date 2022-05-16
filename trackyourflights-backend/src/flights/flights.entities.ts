export interface FlightInfo {
  permaLink: string;
  cancelled: boolean;
  flightStatus: string;
  origin: Waypoint;
  destination: Waypoint;
  gateArrivalTimes: TimeSet;
  gateDepartureTimes: TimeSet;
  landingTimes: TimeSet;
  takeoffTimes: TimeSet;
  aircraft: JetInfo;
}

export interface Waypoint {
  TZ: string;
  iata: string;
  airport: string;
  city: string;
}

export interface TimeSet {
  actual: number;
  estimated: number;
  scheduled: number;
}

export interface JetInfo {
  friendlyType: string;
  typeFull: string;
  type: string;
}