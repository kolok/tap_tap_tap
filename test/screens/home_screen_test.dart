import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_tap_tap/models/tap_settings.dart';
import 'package:tap_tap_tap/screens/home_screen.dart';
import 'package:tap_tap_tap/screens/play_screen.dart';
import 'package:tap_tap_tap/screens/settings_screen.dart';

void main() {
  group('HomeScreen', () {
    Future<void> _pumpHomeScreen(WidgetTester tester, TapSettings settings) {
      return tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(tapSettings: settings),
        ),
      );
    }

    testWidgets('affiche les boutons pour jouer et paramétrer', (tester) async {
      final tapSettings = TapSettings();

      await _pumpHomeScreen(tester, tapSettings);

      expect(find.text('Jouer'), findsOneWidget);
      expect(find.text('Paramètres'), findsOneWidget);
    });

    testWidgets('navigue vers PlayScreen', (tester) async {
      final tapSettings = TapSettings();

      await _pumpHomeScreen(tester, tapSettings);

      await tester.tap(find.text('Jouer'));
      await tester.pumpAndSettle();

      expect(find.byType(PlayScreen), findsOneWidget);
    });

    testWidgets('navigue vers SettingsScreen', (tester) async {
      final tapSettings = TapSettings();

      await _pumpHomeScreen(tester, tapSettings);

      await tester.tap(find.text('Paramètres'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}

