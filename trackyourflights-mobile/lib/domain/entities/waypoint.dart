class Waypoint {
  const Waypoint({
    required this.airport,
    required this.city,
    required this.iata,
  });

  final String city;
  final String airport;
  final String? iata;
}
