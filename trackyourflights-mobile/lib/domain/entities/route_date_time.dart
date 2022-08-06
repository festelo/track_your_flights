class RouteDateTime {
  const RouteDateTime({
    required this.actual,
    required this.scheduled,
    required this.estimated,
  });

  final DateTime? actual;
  final DateTime? estimated;
  final DateTime? scheduled;

  DateTime? get display => actual ?? estimated ?? scheduled;
}
