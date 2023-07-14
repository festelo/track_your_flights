import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class FlightsMapMapbox extends StatefulWidget {
  const FlightsMapMapbox({
    super.key,
    required this.refreshGeojson,
    required this.geojson,
  });

  final VoidCallback refreshGeojson;
  final dynamic geojson;

  @override
  State<FlightsMapMapbox> createState() => _FlightsMapMapboxState();
}

class _FlightsMapMapboxState extends State<FlightsMapMapbox> {
  MapboxMapController? _mapController;
  bool sourceAdded = false;

  void onMapLoaded() {
    widget.refreshGeojson();
  }

  @override
  void didUpdateWidget(covariant FlightsMapMapbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.geojson != oldWidget.geojson) {
      applyGeojson();
    }
  }

  bool _applying = false;
  Future<void> applyGeojson() async {
    if (_applying) return;
    _applying = true;
    try {
      final geojson = widget.geojson;

      if (sourceAdded) {
        await _mapController!.removeLayer('tracks_lines');
        await _mapController!.removeSource('tracks');
      }

      if (geojson == null) return;

      await _mapController!.addSource(
        'tracks',
        GeojsonSourceProperties(data: geojson),
      );
      sourceAdded = true;

      await _mapController!.addLineLayer(
        'tracks',
        'tracks_lines',
        LineLayerProperties(
          lineColor: Colors.pink.toHexStringRGB(),
        ),
      );
    } finally {
      _applying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
