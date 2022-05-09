import 'package:http/http.dart';
import 'package:trackyourflights/data/http/clients/token_client.dart';
import 'package:trackyourflights/data/http/token_storage.dart';
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/session/session_repository.dart';

class SessionTokenRefreshHandler implements TokenRefreshHandler {
  SessionTokenRefreshHandler(this.uriResolver, this.tokenStorage);

  final UriResolver uriResolver;
  final TokenStorage tokenStorage;

  @override
  Future<void> refresh(Client client, String? previousToken) async {
    final sessionRepository = SessionRepositoryImpl(
      uriResolver: uriResolver,
      client: client,
      tokenStorage: tokenStorage,
    );
    throw UnimplementedError();
    // final res = await sessionRepository.authenticate('', '');
  }
}
