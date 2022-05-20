export interface Origin {
  TZ: string;
  isValidAirportCode: boolean;
  altIdent: string;
  iata: string;
  friendlyName: string;
  friendlyLocation: string;
  coord: number[];
  isLatLon: boolean;
  icao: string;
  gate?: any;
  terminal: string;
  delays?: any;
}

export interface Destination {
  TZ: string;
  isValidAirportCode: boolean;
  altIdent: string;
  iata: string;
  friendlyName: string;
  friendlyLocation: string;
  coord: number[];
  isLatLon: boolean;
  icao: string;
  gate?: any;
  terminal?: any;
  delays?: any;
}

export interface TakeoffTimes {
  scheduled: number;
  estimated: number;
  actual: number;
}

export interface LandingTimes {
  scheduled: number;
  estimated: number;
  actual: number;
}

export interface GateDepartureTimes {
  scheduled: number;
  estimated?: number;
  actual?: any;
}

export interface GateArrivalTimes {
  scheduled: number;
  estimated?: any;
  actual?: any;
}

export interface FuelBurn {
  gallons: number;
  pounds: number;
}

export interface FlightPlan {
  speed: number;
  altitude?: any;
  route: string;
  directDistance: number;
  plannedDistance?: any;
  departure: number;
  ete: number;
  fuelBurn: FuelBurn;
}

export interface Links {
  operated: string;
  registration: string;
  permanent: string;
  trackLog: string;
  flightHistory: string;
  buyFlightHistory: string;
  reportInaccuracies: string;
  facebook: string;
  twitter: string;
}

export interface TypeDetails {
  manufacturer: string;
  model: string;
  type: string;
  engCount: string;
  engType: string;
}

export interface Aircraft {
  type: string;
  lifeguard: boolean;
  heavy: boolean;
  tail?: any;
  owner?: any;
  ownerLocation?: any;
  owner_type?: any;
  canMessage: boolean;
  friendlyType: string;
  typeDetails: TypeDetails;
}

export interface PredictedTimes {
  out?: any;
  off?: any;
  on?: any;
  in?: any;
}

export interface Flight {
  origin: Origin;
  destination: Destination;
  aircraftType: string;
  aircraftTypeFriendly: string;
  flightId: string;
  takeoffTimes: TakeoffTimes;
  landingTimes: LandingTimes;
  gateDepartureTimes: GateDepartureTimes;
  gateArrivalTimes: GateArrivalTimes;
  ga: boolean;
  flightStatus: string;
  fpasAvailable: boolean;
  canEdit: boolean;
  cancelled: boolean;
  resultUnknown: boolean;
  diverted: boolean;
  adhoc: boolean;
  fruOverride: boolean;
  timestamp?: any;
  roundedTimestamp?: any;
  permaLink: string;
  taxiIn?: any;
  taxiOut?: any;
  globalIdent: boolean;
  globalFlightFeatures: boolean;
  globalVisualizer: boolean;
  flightPlan: FlightPlan;
  links: Links;
  aircraft: Aircraft;
  displayIdent: string;
  encryptedFlightId: string;
  predictedAvailable: boolean;
  predictedTimes: PredictedTimes;
}

export interface ActivityLog {
  flights: Flight[];
  additionalLogRowsAvailable: boolean;
}

export interface TypeDetails2 {
  manufacturer: string;
  model: string;
  type: string;
  engCount: string;
  engType: string;
}

export interface Aircraft2 {
  type: string;
  lifeguard: boolean;
  heavy: boolean;
  tail?: any;
  owner?: any;
  ownerLocation?: any;
  owner_type?: any;
  canMessage: boolean;
  friendlyType: string;
  typeDetails: TypeDetails2;
}

export interface Airline {
  fullName: string;
  shortName?: any;
  icao: string;
  iata: string;
  callsign: string;
  url: string;
}

export interface AverageDelays {
  departure: number;
  arrival: number;
}

export interface CabinInfo {
  text?: any;
  links?: any;
}

export interface Airline2 {
  fullName: string;
  shortName?: any;
  icao: string;
  iata: string;
  callsign: string;
  url: string;
}

export interface Thumbnail {
  imageUrl: string;
  linkUrl: string;
}

export interface Links2 {
  permanent: string;
  trackLog: string;
  flightHistory: string;
  buyFlightHistory: string;
  reportInaccuracies: string;
  facebook: string;
  twitter: string;
}

export interface CodeShare {
  ident: string;
  displayIdent: string;
  iataIdent: string;
  airline: Airline2;
  friendlyIdent: string;
  thumbnail: Thumbnail;
  links: Links2;
}

export interface Destination2 {
  TZ: string;
  isValidAirportCode: boolean;
  altIdent: string;
  iata: string;
  friendlyName: string;
  friendlyLocation: string;
  coord: number[];
  isLatLon: boolean;
  icao: string;
  gate?: any;
  terminal?: any;
  delays?: any;
}

export interface Distance {
  elapsed: number;
  remaining: number;
  actual: number;
}

export interface FuelBurn2 {
  gallons: number;
  pounds: number;
}

export interface FlightPlan2 {
  speed: number;
  altitude?: any;
  route: string;
  directDistance: number;
  plannedDistance?: any;
  departure: number;
  ete: number;
  fuelBurn: FuelBurn2;
}

export interface GateArrivalTimes2 {
  scheduled?: any;
  estimated?: any;
  actual?: any;
}

export interface GateDepartureTimes2 {
  scheduled?: any;
  estimated?: any;
  actual?: any;
}

export interface GlobalServices {
}

export interface LandingTimes2 {
  scheduled: number;
  estimated: number;
  actual: number;
}

export interface Links3 {
  operated: string;
  registration: string;
  permanent: string;
  trackLog: string;
  flightHistory: string;
  buyFlightHistory: string;
  reportInaccuracies: string;
  facebook: string;
  twitter: string;
}

export interface MyAlerts {
  editAlert: string;
  advancedAlert: string;
}

export interface Origin2 {
  TZ: string;
  isValidAirportCode: boolean;
  altIdent: string;
  iata: string;
  friendlyName: string;
  friendlyLocation: string;
  coord: number[];
  isLatLon: boolean;
  icao: string;
  gate?: any;
  terminal?: any;
  delays?: any;
}

export interface PredictedTimes2 {
  out?: any;
  off?: any;
  on?: any;
  in?: any;
}

export interface RelatedThumbnail {
  thumbnail: string;
  target: string;
}

export interface Runways {
  origin?: any;
  destination?: any;
}

export interface TakeoffTimes2 {
  scheduled: number;
  estimated: number;
  actual: number;
}

export interface Thumbnail2 {
  imageUrl: string;
  linkUrl: string;
}

export interface Track {
  timestamp: number;
  coord: number[];
  alt?: number;
  gs?: number;
  type: string;
  isolated: boolean;
}

export interface FlightRoot {
  activityLog: ActivityLog;
  adhoc: boolean;
  adhocAvailable: boolean;
  aircraft: Aircraft2;
  aireonCandidate: boolean;
  airline: Airline;
  altitude?: any;
  altitudeChange?: any;
  atcIdent?: any;
  averageDelays: AverageDelays;
  blocked: boolean;
  blockedForUser: boolean;
  blockMessage?: any;
  cabinInfo: CabinInfo;
  cancelled: boolean;
  cockpitInformation?: any;
  codeShare: CodeShare;
  coord?: any;
  destination: Destination2;
  displayIdent: string;
  distance: Distance;
  diverted: boolean;
  encryptedFlightId: string;
  flightId: string;
  flightPlan: FlightPlan2;
  flightStatus: string;
  fpasAvailable: boolean;
  friendlyIdent: string;
  fruOverride: boolean;
  ga: boolean;
  gateArrivalTimes: GateArrivalTimes2;
  gateDepartureTimes: GateDepartureTimes2;
  globalCandidate: boolean;
  globalIdent: boolean;
  globalFlightFeatures: boolean;
  globalLegSharing: boolean;
  globalServices: GlobalServices;
  globalVisualizer: boolean;
  groundspeed?: any;
  heading?: any;
  hexid?: any;
  historical: boolean;
  iataIdent: string;
  icon: string;
  ident: string;
  inboundFlight?: any;
  internal?: any;
  interregional: boolean;
  landingTimes: LandingTimes2;
  links: Links3;
  myAlerts: MyAlerts;
  myFlightAware?: any;
  origin: Origin2;
  poweredOff?: any;
  poweredOn?: any;
  predictedAvailable: boolean;
  predictedTimes: PredictedTimes2;
  redactedBlockedTail?: any;
  redactedCallsign?: any;
  redactedTail: boolean;
  relatedThumbnails: RelatedThumbnail[];
  remarks?: any;
  resultUnknown: boolean;
  roundedTimestamp: number;
  runways: Runways;
  speedInformation?: any;
  showSurfaceTimes: boolean;
  surfaceTrackAvailable?: any;
  takeoffTimes: TakeoffTimes2;
  taxiIn?: any;
  taxiOut?: any;
  thumbnail: Thumbnail2;
  timestamp: number;
  track: Track[];
  updateType: string;
  usingShareUrl: boolean;
  waypoints: any[];
  weather?: any;
}

export interface AdvancedResponse {
  version: string;
  summary: boolean;
  flights: Record<string, FlightRoot>;
}