import 'package:http/http.dart';
import 'package:trackyourflights/data/http/clients/error_client.dart';
import 'package:trackyourflights/data/http/clients/http_client.dart';
import 'package:trackyourflights/data/http/clients/token_client.dart';
import 'package:trackyourflights/data/http/token_storage.dart';
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/airports/airports_repostiory.dart';
import 'package:trackyourflights/data/repositories/complex_search/complex_search_repository.dart';
import 'package:trackyourflights/data/repositories/flight_search/flight_search_repository.dart';
import 'package:trackyourflights/data/repositories/history/history_repository.dart';
import 'package:trackyourflights/data/repositories/session/session_repository.dart';
import 'package:trackyourflights/data/repositories/session/token_refresh_handler.dart';
import 'package:trackyourflights/data/repositories/track/track_repository.dart';
import 'package:trackyourflights/data/ws/clients/auth_ws_client.dart';
import 'package:trackyourflights/data/ws/clients/logging_ws_client.dart';
import 'package:trackyourflights/data/ws/clients/aggregated_ws_client.dart';
import 'package:trackyourflights/data/ws/ws_client.dart';
import 'package:trackyourflights/domain/repositories/airports_repository.dart';
import 'package:trackyourflights/domain/repositories/complex_search_repository.dart';
import 'package:trackyourflights/domain/repositories/flight_search_repository.dart';
import 'package:trackyourflights/domain/repositories/history_repository.dart';
import 'package:trackyourflights/domain/repositories/session_repository.dart';
import 'package:trackyourflights/domain/repositories/track_repository.dart';
import 'package:uuid/uuid.dart';

final tokenStorage = TokenStorage();

const isProd = true;

final debugUriResolver = UriResolver(
  scheme: 'http',
  endpoint: '192.168.1.101:3000',
  path: 'api',
);

final prodUriResolver = UriResolver(
  scheme: 'https',
  endpoint: 'flights.festelo.tk',
  path: 'api',
);

final debugWsUri = Uri.parse('ws://localhost:3001/');

final prodWsUri = Uri.parse('wss://flights.festelo.tk/ws');

UriResolver get uriResolver => isProd ? prodUriResolver : debugUriResolver;
Uri get wsUri => isProd ? prodWsUri : debugWsUri;

final client = HttpClient(
  Client(),
  [
    (client) => ErrorClient(client),
    (client) => TokenClient(
          client,
          tokenStorage,
          tokenRefreshHandler:
              SessionTokenRefreshHandler(uriResolver, tokenStorage),
        ),
  ],
);

final wsClient = AggregatedWsClient(
  WsClient(wsUri),
  [
    (client) => LoggingWsClient(client),
    (client) => AuthWsClient(client, tokenStorage),
  ],
);

final SessionRepository sessionRepository = SessionRepositoryImpl(
  uriResolver: uriResolver,
  client: client,
  tokenStorage: tokenStorage,
);

final AirportsRepository airportsRepository = AirportsRepositoryImpl(
  uriResolver: uriResolver,
  client: client,
);

final FlightSearchRepository flightSearchRepository =
    FlightSearchRepositoryImpl(
  uriResolver: uriResolver,
  client: client,
);

final HistoryRepository historyRepository = HistoryRepositoryImpl(
  uriResolver: uriResolver,
  client: client,
);

final TrackRepository trackRepository = TrackRepositoryImpl(
  uriResolver: uriResolver,
  client: client,
);

final ComplexSearchRepository complexSearchRepository =
    ComplexSearchRepositoryImpl(
  uriResolver: uriResolver,
  client: client,
  wsClient: wsClient,
);

String get uuid => const Uuid().v4();
