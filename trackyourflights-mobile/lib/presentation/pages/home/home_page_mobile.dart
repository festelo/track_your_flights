import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/home/map/map_tab.dart';
import 'package:trackyourflights/presentation/pages/home/history/orders_tab.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

class HomePageMobile extends PresenterWidget {
  const HomePageMobile({Key? key}) : super(key: key);

  @override
  HomePageMobileState createState() => HomePageMobileState();
}

class HomePageMobileState extends PresenterState<HomePageMobile> {
  int _selectedTab = 0;

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return const OrdersTab();
      case 1:
        return const MapTab();
      default:
        throw Exception('Unknown tab');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) => setState(() => _selectedTab = i),
        currentIndex: _selectedTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}
