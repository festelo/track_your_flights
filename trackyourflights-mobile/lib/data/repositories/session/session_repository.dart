import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:trackyourflights/data/http/exceptions/bad_status_code_exception.dart';

import 'package:trackyourflights/data/http/token_storage.dart';
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/domain/exceptions/wrong_credentials_exception.dart';
import 'package:trackyourflights/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  const SessionRepositoryImpl({
    required this.uriResolver,
    required this.client,
    required this.tokenStorage,
  });

  final UriResolver uriResolver;
  final Client client;
  final TokenStorage tokenStorage;

  @override
  bool get authorized => tokenStorage.currentToken.valueOrNull != null;

  @override
  Future<void> authenticate(String username, String password) async {
    try {
      final res = await client.post(
        uriResolver.uri('/auth/login'),
        body: {
          "username": username,
          "password": password,
        },
      );
      final json = jsonDecode(res.body);
      final accessToken = json["access_token"];
      tokenStorage.setCurrentToken(accessToken);
    } on BadStatusCodeException catch (e) {
      if (e.statusCode == 401) {
        throw WrongCredentialsException();
      }
      rethrow;
    }
  }

  @override
  Future<void> verify() async {
    try {
      await client.get(uriResolver.uri('/auth/verify'));
    } catch (e, s) {
      log('Verify token exception', error: e, stackTrace: s);
      tokenStorage.setCurrentToken(null);
    }
  }
}
