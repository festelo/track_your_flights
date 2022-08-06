import 'package:http/http.dart';

class BadStatusCodeException implements Exception {
  final int statusCode;
  final Response? response;

  const BadStatusCodeException({
    required this.statusCode,
    this.response,
  });

  @override
  String toString() {
    final body = response?.body;
    var str = 'Bad status code: $statusCode';
    if (body != null) {
      str += '\n$body';
    }
    return str;
  }
}
