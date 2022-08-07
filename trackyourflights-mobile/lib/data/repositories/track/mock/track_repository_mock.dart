import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/repositories/track_repository.dart';

class TrackRepositoryMock implements TrackRepository {
  @override
  Future listAllTracks() => Future.value({});

  @override
  Future<void> saveFlightTrack(Flight flight) => Future.value();

  @override
  Future<void> saveOrderTracks(Order order) => Future.value();
}
