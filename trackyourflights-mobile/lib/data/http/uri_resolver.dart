class UriResolver {
  UriResolver({
    required this.scheme,
    required this.baseUrl,
  });

  final String scheme;
  final String baseUrl;

  Uri uri(String path, [List<QueryParam>? queryParams]) {
    queryParams ??= [];
    var query = '?';
    for (final p in queryParams) {
      if (p.value == null) continue;
      query +=
          '${Uri.encodeComponent(p.key)}=${Uri.encodeComponent(p.value!)}&';
    }
    if (scheme == 'https') {
      return Uri.parse(Uri.https(baseUrl, path).toString() + query);
    } else {
      return Uri.parse(Uri.http(baseUrl, path).toString() + query);
    }
  }
}

class QueryParam {
  QueryParam(this.key, this.value);
  final String key;
  final String? value;
}
