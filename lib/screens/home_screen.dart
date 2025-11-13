import 'package:flutter/material.dart';

import '../models/tap_settings.dart';
import 'play_screen.dart';
import 'play_screen_two_player.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.tapSettings,
  });

  final TapSettings tapSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tap Tap Tap'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlayScreen(tapSettings: tapSettings),
                  ),
                );
              },
              child: const Text('Jouer'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        PlayScreenTwoPlayer(tapSettings: tapSettings),
                  ),
                );
              },
              child: const Text('Jouer à 2'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(tapSettings: tapSettings),
                  ),
                );
              },
              child: const Text('Paramètres'),
            ),
          ],
        ),
      ),
    );
  }
}

