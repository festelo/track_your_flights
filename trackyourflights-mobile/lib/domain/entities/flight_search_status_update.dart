import 'package:trackyourflights/domain/entities/flight.dart';

class FlightSearchStatusUpdate {
  FlightSearchStatusUpdate({
    required this.id,
    required this.status,
    this.progress,
    this.data,
    this.error,
  });

  final String id;
  final FlightSearchStatus status;
  final double? progress;
  final Flight? data;
  final String? error;
}

enum FlightSearchStatus { started, progress, failed, completed }
