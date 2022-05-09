import 'dart:async';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:trackyourflights/data/http/token_storage.dart';

abstract class TokenRefreshHandler {
  Future<void> refresh(http.Client client, String? tokenInfo);
}

class TokenClient extends http.BaseClient {
  TokenClient(
    this._inner,
    this.tokenStorage, {
    this.tokenRefreshHandler,
  });

  final http.Client _inner;
  final TokenStorage tokenStorage;

  TokenRefreshHandler? tokenRefreshHandler;

  Completer<void>? _refreshCompleter;

  Future<void> _waitRefresh() async {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      await _refreshCompleter!.future;
    }
  }

  Future<bool> _refreshToken() async {
    _refreshCompleter = Completer();
    try {
      final tokenInfo = tokenStorage.currentToken.value!;
      await tokenRefreshHandler!.refresh(_inner, tokenInfo);
      return true;
    } catch (e) {
      log('error received on token refreshing: $e');
      tokenStorage.setCurrentToken(null);
      return false;
    } finally {
      _refreshCompleter!.complete();
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await _waitRefresh();
    final token = tokenStorage.currentToken.value;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    final response = await _inner.send(request);

    if (response.statusCode == 401 && token != null) {
      final refreshed = await _refreshToken();
      if (refreshed && request is http.Request) {
        final req = http.Request(request.method, request.url)
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding
          ..followRedirects = request.followRedirects
          ..persistentConnection = request.persistentConnection
          ..headers.addAll(request.headers);
        return await send(req);
      }
    }
    return response;
  }
}
