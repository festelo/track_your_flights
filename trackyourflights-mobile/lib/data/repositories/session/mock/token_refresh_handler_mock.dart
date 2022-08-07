import 'package:http/src/client.dart';
import 'package:trackyourflights/data/http/clients/token_client.dart';

class TokenRefreshHandlerMock implements TokenRefreshHandler {
  @override
  Future<void> refresh(Client client, String? tokenInfo) => Future.value();
}
