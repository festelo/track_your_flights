import 'dart:convert';

import 'package:http/http.dart';
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/domain/repositories/track_repository.dart';

class TrackRepositoryImpl implements TrackRepository {
  const TrackRepositoryImpl({
    required this.uriResolver,
    required this.client,
  });

  final UriResolver uriResolver;
  final Client client;

  @override
  Future<dynamic> listAllTracks() async {
    final res = await client.get(uriResolver.uri('/track/get-all'));
    return jsonDecode(res.body);
  }

  @override
  Future<void> saveOrderTracks(Order order) async {
    for (final flight in order.flights) {
      await saveFlightTrack(flight);
    }
  }

  Future<void> saveFlightTrack(Flight flight) async {
    final kmlLink =
        'https://flightaware.com/${flight.flightAwareLink}/google_earth';

    final res = await client.get(Uri.parse(kmlLink));
    final kml = res.body;
    await client.post(
      uriResolver.uri('/track/save-kml'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'flightId': flight.id,
        'kml': kml,
      }),
    );
  }
}
