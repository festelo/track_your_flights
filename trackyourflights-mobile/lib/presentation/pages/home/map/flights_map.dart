import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:trackyourflights/repositories.dart';

class FlightsMap extends StatefulWidget {
  const FlightsMap({Key? key}) : super(key: key);

  @override
  State<FlightsMap> createState() => _FlightsMapState();
}

class _FlightsMapState extends State<FlightsMap> {
  MapboxMapController? _mapController;

  @override
  void initState() {
    super.initState();
  }

  void onMapLoaded() {
    refreshGeojson();
  }

  Future<void> refreshGeojson() async {
    final tracks = await trackRepository.listAllTracks();
    await _mapController!.addSource(
      'tracks',
      GeojsonSourceProperties(data: tracks),
    );

    await _mapController!.addLineLayer(
      'tracks',
      'tracks_lines',
      LineLayerProperties(
        lineColor: Colors.pink.toHexStringRGB(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
      return FlutterMap(
        options: MapOptions(
          zoom: 13,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            attributionBuilder: (_) {
              return const Text("© OpenStreetMap contributors");
            },
          ),
        ],
      );
    }
    return MapboxMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(52.5200, 13.4050),
      ),
      accessToken:
          'pk.eyJ1Ijoidm90ZXIiLCJhIjoiY2tiZjhzMG12MHQwZjMxdWZoOXB6aXliaCJ9.ow8x2P3JMAV6-UaWd0cYyA',
      styleString: 'mapbox://styles/mapbox/outdoors-v11',
      onMapCreated: (c) => _mapController = c,
      onStyleLoadedCallback: onMapLoaded,
      myLocationEnabled: true,
    );
  }
}
