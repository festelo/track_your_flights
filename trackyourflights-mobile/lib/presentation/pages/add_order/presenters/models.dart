class SearchError {
  const SearchError(this.text, {this.showSearchRangeSuggestion = false});

  final bool showSearchRangeSuggestion;
  final String text;
}

enum SearchType {
  byParameters,
  byFlightAwareLink,
  byDateRange,
}
