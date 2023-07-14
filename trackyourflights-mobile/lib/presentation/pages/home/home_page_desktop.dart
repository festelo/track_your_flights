import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/home/history/orders_bar.dart';
import 'package:trackyourflights/presentation/pages/home/map/map_bar.dart';

class HomePageDesktop extends StatelessWidget {
  const HomePageDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Expanded(
            child: MapBar(),
          ),
          SizedBox(
            width: 500,
            child: OrdersBar(),
          ),
        ],
      ),
    );
  }
}
