import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/home/map/flights_map.dart';

class MapBar extends StatelessWidget {
  const MapBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FlightsMap();
  }
}
