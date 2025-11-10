import 'package:flutter/material.dart';

import 'models/tap_settings.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TapTapTapApp());
}

class TapTapTapApp extends StatefulWidget {
  const TapTapTapApp({super.key});

  @override
  State<TapTapTapApp> createState() => _TapTapTapAppState();
}

class _TapTapTapAppState extends State<TapTapTapApp> {
  final TapSettings _tapSettings = TapSettings();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Tap Tap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(tapSettings: _tapSettings),
    );
  }
}

