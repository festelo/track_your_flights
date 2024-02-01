import 'package:http/http.dart';
import 'package:trackyourflights/data/http/clients/error_client.dart';
import 'package:trackyourflights/data/http/clients/http_client.dart';
import 'package:trackyourflights/data/http/clients/token_client.dart';
import 'package:trackyourflights/data/http/token_storage.dart';
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/airports/api/airports_repostiory.dart';
import 'package:trackyourflights/data/repositories/airports/mock/airports_repository_mock.dart';
import 'package:trackyourflights/data/repositories/complex_search/api/complex_search_repository.dart';
import 'package:trackyourflights/data/repositories/complex_search/mock/complex_search_repository_mock.dart';
import 'package:trackyourflights/data/repositories/flight_search/api/flight_search_repository.dart';
import 'package:trackyourflights/data/repositories/flight_search/mock/flight_search_repository_mock.dart';
import 'package:trackyourflights/data/repositories/history/api/history_repository.dart';
import 'package:trackyourflights/data/repositories/history/mock/history_repository_mock.dart';
import 'package:trackyourflights/data/repositories/session/api/session_repository.dart';
import 'package:trackyourflights/data/repositories/session/api/token_refresh_handler.dart';
import 'package:trackyourflights/data/repositories/session/mock/session_repository_mock.dart';
import 'package:trackyourflights/data/repositories/track/api/track_repository.dart';
import 'package:trackyourflights/data/repositories/track/mock/track_repository_mock.dart';
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

enum EnvironmentConfiguration { prod, local, mock }

const _envConfig = EnvironmentConfiguration.prod;

final tokenStorage = TokenStorage();

final _localUriResolver = UriResolver(
  scheme: 'http',
  endpoint: '192.168.1.101:3000',
  path: 'api',
);

final _prodUriResolver = UriResolver(
  scheme: 'https',
  endpoint: 'flights.festelo.net',
  path: 'api',
);

final _localWsUri = Uri.parse('ws://localhost:3001/');

final _prodWsUri = Uri.parse('wss://flights.festelo.net/ws');

UriResolver get _uriResolver => _envConfig == EnvironmentConfiguration.prod
    ? _prodUriResolver
    : _localUriResolver;

Uri get _wsUri =>
    _envConfig == EnvironmentConfiguration.prod ? _prodWsUri : _localWsUri;

final _client = HttpClient(
  Client(),
  [
    (client) => ErrorClient(client),
    (client) => TokenClient(
          client,
          tokenStorage,
          tokenRefreshHandler: SessionTokenRefreshHandler(
            _uriResolver,
            tokenStorage,
          ),
        ),
  ],
);

final _wsClient = AggregatedWsClient(
  WsClient(_wsUri),
  [
    (client) => LoggingWsClient(client),
    (client) => AuthWsClient(client, tokenStorage),
  ],
);

final SessionRepository sessionRepository =
    _envConfig == EnvironmentConfiguration.mock
        ? SessionRepositoryMock()
        : SessionRepositoryImpl(
            uriResolver: _uriResolver,
            client: _client,
            tokenStorage: tokenStorage,
          );

final AirportsRepository airportsRepository =
    _envConfig == EnvironmentConfiguration.mock
        ? AirportsRepositoryMock()
        : AirportsRepositoryImpl(
            uriResolver: _uriResolver,
            client: _client,
          );

final FlightSearchRepository flightSearchRepository =
    _envConfig == EnvironmentConfiguration.mock
        ? FlightSearchRepositoryMock()
        : FlightSearchRepositoryImpl(
            uriResolver: _uriResolver,
            client: _client,
          );

final HistoryRepository historyRepository =
    _envConfig == EnvironmentConfiguration.mock
        ? HistoryRepositoryMock()
        : HistoryRepositoryImpl(
            uriResolver: _uriResolver,
            client: _client,
          );

final TrackRepository trackRepository =
    _envConfig == EnvironmentConfiguration.mock
        ? TrackRepositoryMock()
        : TrackRepositoryImpl(
            uriResolver: _uriResolver,
            client: _client,
          );

final ComplexSearchRepository complexSearchRepository =
    _envConfig == EnvironmentConfiguration.mock
        ? ComplexSearchRepositoryMock()
        : ComplexSearchRepositoryImpl(
            uriResolver: _uriResolver,
            client: _client,
            wsClient: _wsClient,
          );

String get uuid => const Uuid().v4();
