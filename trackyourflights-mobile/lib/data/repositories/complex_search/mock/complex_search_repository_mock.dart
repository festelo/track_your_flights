import 'package:trackyourflights/domain/entities/flight_search_status_update.dart';
import 'package:trackyourflights/domain/entities/flight_search.dart';
import 'package:trackyourflights/domain/repositories/complex_search_repository.dart';

class ComplexSearchRepositoryMock implements ComplexSearchRepository {
  @override
  Future<void> cancelSearch(String id) => Future.value();

  @override
  Future<FlightSearch> createSearch({
    required String ident,
    required DateTime aproxDate,
    required String? originItea,
    required String? destItea,
    required bool? restart,
  }) =>
      Future.value(
        FlightSearch(
          id: 'mock',
          ident: 'ident',
          aproxDate: DateTime.now(),
          state: 'state',
          minutesRange: 600,
        ),
      );

  @override
  Stream<FlightSearchStatusUpdate> get onStatusChange => Stream.multi((_) {});
}
