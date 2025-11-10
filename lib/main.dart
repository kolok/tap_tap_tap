import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const TapTapTapApp());
}

class TapTapTapApp extends StatelessWidget {
  const TapTapTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Tap Tap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

