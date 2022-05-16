class UriResolver {
  UriResolver({
    required this.scheme,
    required this.endpoint,
    this.path,
  });

  final String scheme;
  final String endpoint;
  final String? path;

  Uri uri(String path, [List<QueryParam>? queryParams]) {
    queryParams ??= [];
    var query = '?';
    for (final p in queryParams) {
      if (p.value == null) continue;
      query +=
          '${Uri.encodeComponent(p.key)}=${Uri.encodeComponent(p.value!)}&';
    }
    if (this.path != null) {
      path = '${this.path}$path';
    }
    if (scheme == 'https') {
      return Uri.parse(Uri.https(endpoint, path).toString() + query);
    } else {
      return Uri.parse(Uri.http(endpoint, path).toString() + query);
    }
  }
}

class QueryParam {
  QueryParam(this.key, this.value);
  final String key;
  final String? value;
}
