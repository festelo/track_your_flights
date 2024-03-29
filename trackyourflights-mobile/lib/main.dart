import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/pages/home/home_page.dart';
import 'package:trackyourflights/presentation/pages/login/login_page.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/repositories.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await tokenStorage.restoreToken();
  await sessionRepository.verify();
  runApp(
    ProviderScope(
      child: App(
        authorized: sessionRepository.authorized,
      ),
    ),
  );
}

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.authorized,
  }) : super(key: key);

  final bool authorized;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track Your Flights',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: const [
        // Locale('ru', 'RU'),
        // Locale('en', 'RU'),
        Locale('en', 'GB'),
      ],
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: authorized ? const HomePage() : const LoginPage(),
    );
  }
}
