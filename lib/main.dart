import 'package:flutter/material.dart';

import 'models/tap_settings.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tapSettings = await TapSettings.load();

  runApp(TapTapTapApp(tapSettings: tapSettings));
}

class TapTapTapApp extends StatelessWidget {
  const TapTapTapApp({
    super.key,
    required this.tapSettings,
  });

  final TapSettings tapSettings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Tap Tap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(tapSettings: tapSettings),
    );
  }
}

