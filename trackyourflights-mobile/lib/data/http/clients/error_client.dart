import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:trackyourflights/data/http/exceptions/bad_status_code_exception.dart';

class ErrorClient extends http.BaseClient {
  ErrorClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final unstreamedResponse = await http.Response.fromStream(response);
      throw BadStatusCodeException(
        statusCode: response.statusCode,
        response: unstreamedResponse,
      );
    }
    return response;
  }
}
