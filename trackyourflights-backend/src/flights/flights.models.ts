export interface FlightApiDto {
  ident:                        string;
  airline:                      string;
  display_airline:              string;
  flightnumber:                 string;
  faFlightID:                   string;
  type:                         string;
  flight_history_link:          string;
  diversion:                    boolean;
  origin:                       string;
  display_origin:               Display;
  destination:                  string;
  display_destination:          Display;
  display_departuretime:        FlightApiDateTime;
  display_arrivaltime:          FlightApiDateTime;
  filed_departuretime:          FlightApiDateTime;
  filed_arrivaltime:            FlightApiDateTime;
  filed_ete:                    string;
  estimateddeparturetime:       FlightApiDateTime;
  actualdeparturetime:          FlightApiDateTime;
  estimatedarrivaltime:         FlightApiDateTime;
  actualarrivaltime:            FlightApiDateTime;
  average_departuretime:        FlightApiDateTime;
  average_arrivaltime:          FlightApiDateTime;
  average_departure_delay_secs: number;
  average_arrival_delay_secs:   number;
  est_block_in:                 FlightApiDateTime;
  sch_block_in:                 FlightApiDateTime;
  act_block_in:                 FlightApiDateTime;
  est_block_out:                FlightApiDateTime;
  sch_block_out:                FlightApiDateTime;
  act_block_out:                FlightApiDateTime;
  show_surface_data:            boolean;
  fs_avionics_on:               FlightApiDateTime;
  fs_avionics_off:              FlightApiDateTime;
  status:                       string;
  status_code:                  number;
  status_orig:                  number;
  status_dest:                  number;
  has_surface_status:           boolean;
  progress_percent:             number;
  state_code:                   number;
  aircrafttype:                 string;
  display_aircrafttype:         string;
  full_aircrafttype:            string;
  terminal_dest:                string;
  gate_dest:                    string;
  terminal_orig:                string;
  gate_orig:                    string;
  bag_claim:                    string;
  route:                        string;
  filed_airspeed_kts:           number;
  distance_filed:               string;
  distance_filed_nm:            number;
  distance_direct:              string;
  distance_direct_nm:           number;
  distance_flown:               string;
  distance_flown_nm:            number;
  inbound_faFlightID:           string;
  inbound_link:                 string;
  adhoc:                        boolean;
  is_piston:                    boolean;
}

export interface FlightApiDateTime {
  epoch:         number;
  tz:            string;
  tz_identifier: string;
  dow:           string;
  time:          string;
  date:          string;
  localtime?:    number;
}


export interface Display {
  city:            string;
  alternate_ident: string;
  airport_name:    string;
}
