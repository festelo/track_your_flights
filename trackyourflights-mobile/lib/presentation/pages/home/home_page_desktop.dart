import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/home/history/orders_bar.dart';
import 'package:trackyourflights/presentation/pages/home/map/map_bar.dart';

class HomePageDesktop extends StatelessWidget {
  const HomePageDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: const [
          Expanded(
            child: MapBar(),
          ),
          OrdersBar(),
        ],
      ),
    );
  }
}
