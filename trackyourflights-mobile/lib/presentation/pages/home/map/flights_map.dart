import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackyourflights/presentation/disposables/disposable_state.dart';
import 'package:trackyourflights/presentation/disposables/disposable_stream.dart';
import 'package:trackyourflights/presentation/event/app_notifier.dart';
import 'package:trackyourflights/presentation/pages/home/map/flights_map_mapbox.dart';
import 'package:trackyourflights/presentation/pages/home/map/flights_map_native.dart';
import 'package:trackyourflights/repositories.dart';

class FlightsMap extends StatefulWidget {
  const FlightsMap({Key? key}) : super(key: key);

  @override
  State<FlightsMap> createState() => _FlightsMapState();
}

class _FlightsMapState extends State<FlightsMap> with DisposableState {
  dynamic _geojson;

  bool get _mapboxSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  bool _mapboxSwitched = false;

  @override
  void initState() {
    super.initState();
    appNotifier.events
        .whereType<OrdersModifiedEvent>()
        .listen((e) => refreshGeojson())
        .disposeWith(this);
  }

  void onMapLoaded() {
    refreshGeojson();
  }

  Future<void> refreshGeojson() async {
    final geojson = await trackRepository.listAllTracks();
    if (mounted) {
      setState(() => _geojson = geojson);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget map;
    if (_mapboxSwitched || !_mapboxSupported) {
      map = FlightsMapNative(
        refreshGeojson: refreshGeojson,
        geojson: _geojson,
      );
    } else {
      map = FlightsMapMapbox(
        refreshGeojson: refreshGeojson,
        geojson: _geojson,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        map,
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            icon: const Icon(Icons.change_circle_outlined),
            color: Colors.blue,
            onPressed: () => setState(() => _mapboxSwitched = !_mapboxSwitched),
          ),
        ),
      ],
    );
  }
}
