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

    Finder _playAreaFinder() => find.byKey(const ValueKey('play-area'));

    testWidgets('démarre un compte à rebours avant la partie', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 5));

      await _pumpPlayScreen(tester, tapSettings: tapSettings);

      await tester.tap(find.text('Démarrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      Text countdownText =
          tester.widget<Text>(find.byKey(const ValueKey('countdown')));
      expect(countdownText.data, '3');

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      countdownText =
          tester.widget<Text>(find.byKey(const ValueKey('countdown')));
      expect(countdownText.data, '2');

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      countdownText =
          tester.widget<Text>(find.byKey(const ValueKey('countdown')));
      expect(countdownText.data, '1');
    });

    testWidgets('incrémente le compteur pendant la partie', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 4));

      await _pumpPlayScreen(tester, tapSettings: tapSettings);

      await tester.tap(find.text('Démarrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey('game-stats')), findsOneWidget);

      await tester.tap(_playAreaFinder());
      await tester.pump();

      final counterText =
          tester.widget<Text>(find.byKey(const ValueKey('tap-counter')));
      expect(counterText.data, '1');
    });

    testWidgets('empêche de taper après la fin du temps', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 2));

      await _pumpPlayScreen(tester, tapSettings: tapSettings);

      await tester.tap(find.text('Démarrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(_playAreaFinder());
      await tester.pump();

      for (var i = 0; i < 2; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      await tester.tap(_playAreaFinder());
      await tester.pump();

      final counterText =
          tester.widget<Text>(find.byKey(const ValueKey('tap-counter')));
      expect(counterText.data, '1');
      final remainingText =
          tester.widget<Text>(find.byKey(const ValueKey('remaining-time')));
      expect(remainingText.data, '00:00');
      expect(find.text('Rejouer'), findsOneWidget);
    });
  });
}

