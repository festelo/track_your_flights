import 'package:equatable/equatable.dart';

import 'flight.dart';

class FlightSearch with EquatableMixin {
  FlightSearch({
    required this.id,
    required this.ident,
    required this.aproxDate,
    required this.state,
    required this.minutesRange,
    this.originItea,
    this.destItea,
    this.progress,
    this.error,
    this.flight,
  });

  final String id;
  final String ident;
  final DateTime aproxDate;
  final String? originItea;
  final String? destItea;
  final int minutesRange;
  String state;
  double? progress;
  String? error;
  Flight? flight;

  @override
  List<Object?> get props => [
        id,
        ident,
        aproxDate,
        originItea,
        destItea,
        minutesRange,
        state,
        progress,
        error,
        flight,
      ];
}
