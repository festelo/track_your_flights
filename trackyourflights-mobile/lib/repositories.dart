import 'package:http/http.dart';
import 'package:trackyourflights/data/http/clients/error_client.dart';
import 'package:trackyourflights/data/http/clients/http_client.dart';
import 'package:trackyourflights/data/http/clients/token_client.dart';
import 'package:trackyourflights/data/http/token_storage.dart';
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/flight_search/flight_search_repository.dart';
import 'package:trackyourflights/data/repositories/history/history_repository.dart';
import 'package:trackyourflights/data/repositories/session/session_repository.dart';
import 'package:trackyourflights/data/repositories/session/token_refresh_handler.dart';
import 'package:trackyourflights/data/repositories/track/track_repository.dart';
import 'package:trackyourflights/domain/repositories/flight_search_repository.dart';
import 'package:trackyourflights/domain/repositories/history_repository.dart';
import 'package:trackyourflights/domain/repositories/session_repository.dart';
import 'package:trackyourflights/domain/repositories/track_repository.dart';
import 'package:uuid/uuid.dart';

final tokenStorage = TokenStorage();

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

UriResolver get uriResolver => prodUriResolver;

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

final SessionRepository sessionRepository = SessionRepositoryImpl(
  uriResolver: uriResolver,
  client: client,
  tokenStorage: tokenStorage,
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

String get uuid => const Uuid().v4();
