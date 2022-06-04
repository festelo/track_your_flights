import 'package:trackyourflights/domain/entities/flight_search.dart';
import 'package:trackyourflights/domain/entities/flight_search_status_update.dart';

abstract class ComplexSearchRepository {
  // Future<List<FlightSearch>> searches();

  Future<FlightSearch> createSearch({
    required String ident,
    required DateTime aproxDate,
    required String? originItea,
    required String? destItea,
    required bool? restart,
  });

  Future<void> cancelSearch(String id);

  // Future<void> getSearchStatus({required String searchId});

  Stream<FlightSearchStatusUpdate> get onStatusChange;
}
