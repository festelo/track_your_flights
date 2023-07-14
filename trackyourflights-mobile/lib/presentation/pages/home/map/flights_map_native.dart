import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';

class FlightsMapNative extends StatefulWidget {
  const FlightsMapNative({
    super.key,
    required this.refreshGeojson,
    required this.geojson,
  });

  final VoidCallback refreshGeojson;
  final dynamic geojson;

  @override
  State<FlightsMapNative> createState() => _FlightsMapNativeState();
}

class _FlightsMapNativeState extends State<FlightsMapNative> {
  final _geoJsonParser = GeoJsonParser();

  @override
  void initState() {
    super.initState();
    onMapLoaded();
  }

  void onMapLoaded() {
    widget.refreshGeojson();
  }

  @override
  void didUpdateWidget(covariant FlightsMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.geojson != oldWidget.geojson) {
      applyGeojson();
    }
  }

  void applyGeojson() {
    final geojson = widget.geojson;
    if (geojson == null) {
      _geoJsonParser.parseGeoJson({});
      return;
    }

    _geoJsonParser.parseGeoJson(geojson as Map<String, dynamic>);
    _geoJsonParser.defaultPolylineColor = Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: MapController(),
      options: MapOptions(
        center: const LatLng(52.5200, 13.4050),
        zoom: 14,
      ),
      children: [
        TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c']),
        PolygonLayer(polygons: _geoJsonParser.polygons),
        PolylineLayer(polylines: _geoJsonParser.polylines),
        MarkerLayer(markers: _geoJsonParser.markers)
      ],
    );
  }
}
