class RouteDateTime {
  const RouteDateTime({
    required this.actual,
    required this.scheduled,
  });

  final DateTime? actual;
  final DateTime? scheduled;

  DateTime? get display => actual ?? scheduled;
}
