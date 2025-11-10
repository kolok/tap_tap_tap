import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_tap_tap/models/tap_settings.dart';
import 'package:tap_tap_tap/screens/play_screen.dart';

void main() {
  group('PlayScreen', () {
    Future<void> _pumpPlayScreen(
      WidgetTester tester, {
      required TapSettings tapSettings,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: PlayScreen(tapSettings: tapSettings),
        ),
      );
    }

    Finder _playAreaFinder() {
      return find.byType(GestureDetector).last;
    }

    Finder _counterFinder() {
      return find.descendant(
        of: _playAreaFinder(),
        matching: find.byType(Text),
      );
    }

    testWidgets('démarre un compte à rebours avant la partie', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 5));

      await _pumpPlayScreen(tester, tapSettings: tapSettings);

      await tester.tap(find.text('Démarrer'));
      await tester.pump();

      expect(find.text('3'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('incrémente le compteur pendant la partie', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 4));

      await _pumpPlayScreen(tester, tapSettings: tapSettings);

      await tester.tap(find.text('Démarrer'));
      await tester.pump(); // affiche 3
      await tester.pump(const Duration(seconds: 3)); // compte à rebours jusqu’à 0
      await tester.pump(const Duration(seconds: 1)); // cache l’affichage 0

      await tester.tap(_playAreaFinder());
      await tester.pump();

      final counterText = tester.widget<Text>(_counterFinder());
      expect(counterText.data, '1');
    });

    testWidgets('empêche de taper après la fin du temps', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 2));

      await _pumpPlayScreen(tester, tapSettings: tapSettings);

      await tester.tap(find.text('Démarrer'));
      await tester.pump(); // 3
      await tester.pump(const Duration(seconds: 3)); // fin du compte à rebours
      await tester.pump(const Duration(seconds: 1)); // suppression du 0

      await tester.tap(_playAreaFinder());
      await tester.pump();

      await tester.pump(const Duration(seconds: 3)); // laisse le timer de jeu atteindre la fin

      await tester.tap(_playAreaFinder());
      await tester.pump();

      final counterText = tester.widget<Text>(_counterFinder());
      expect(counterText.data, '1');
      expect(find.text('00:00'), findsOneWidget);
    });
  });
}

