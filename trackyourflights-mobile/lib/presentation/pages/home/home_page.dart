import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/home/home_page_desktop.dart';
import 'package:trackyourflights/presentation/pages/home/home_page_mobile.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

class HomePage extends PresenterWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends PresenterState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < 1000) {
      return const HomePageMobile();
    } else {
      return const HomePageDesktop();
    }
  }
}
