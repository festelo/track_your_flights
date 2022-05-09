import 'package:trackyourflights/domain/entities/order.dart';

abstract class TrackRepository {
  Future<void> saveOrderTracks(Order order);
  Future<dynamic> listAllTracks();
}
