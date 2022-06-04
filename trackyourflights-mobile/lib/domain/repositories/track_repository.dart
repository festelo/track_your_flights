import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/order.dart';

abstract class TrackRepository {
  Future<void> saveOrderTracks(Order order);
  Future<void> saveFlightTrack(Flight flight);
  Future<dynamic> listAllTracks();
}
