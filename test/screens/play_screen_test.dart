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

      final countdownFinder = find.byKey(const ValueKey('countdown'));
      expect(countdownFinder, findsOneWidget);
      final countdownText = tester.widget<Text>(countdownFinder);
      expect(countdownText.data, '3');

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final countdownFinder2 = find.byKey(const ValueKey('countdown'));
      expect(countdownFinder2, findsOneWidget);
      final countdownText2 = tester.widget<Text>(countdownFinder2);
      expect(countdownText2.data, '2');

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final countdownFinder3 = find.byKey(const ValueKey('countdown'));
      expect(countdownFinder3, findsOneWidget);
      final countdownText3 = tester.widget<Text>(countdownFinder3);
      expect(countdownText3.data, '1');
    });

    testWidgets('incrémente le compteur pendant la partie', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 4));

      await _pumpPlayScreen(tester, tapSettings: tapSettings);

      await tester.tap(find.text('Démarrer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Attendre que le countdown se termine (3 secondes: 3, 2, 1, puis jeu commence)
      // Le timer périodique se déclenche après 1 seconde, donc on attend 4 secondes au total
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
      }

      // Vérifier que le jeu a commencé (le countdown doit avoir disparu)
      expect(find.byKey(const ValueKey('countdown')), findsNothing);
      expect(find.byKey(const ValueKey('game-stats')), findsOneWidget);

      // Vérifier que le compteur est à 0 avant de taper
      final initialCounterFinder = find.byKey(const ValueKey('tap-counter'));
      expect(initialCounterFinder, findsWidgets);
      final initialCounterText = tester.widget<Text>(initialCounterFinder.first);
      expect(initialCounterText.data, '0');

      // Maintenant on peut taper
      await tester.tap(_playAreaFinder());
      await tester.pump(); // Un pump supplémentaire pour s'assurer que l'état est mis à jour

      // Il peut y avoir plusieurs widgets avec cette clé à cause de l'AnimatedSwitcher
      // On utilise find.first pour obtenir le premier
      final counterFinder = find.byKey(const ValueKey('tap-counter'));
      expect(counterFinder, findsWidgets);
      final counterText = tester.widget<Text>(counterFinder.first);
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

      final counterFinder = find.byKey(const ValueKey('tap-counter'));
      expect(counterFinder, findsOneWidget);
      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '1');
      
      final remainingFinder = find.byKey(const ValueKey('remaining-time'));
      expect(remainingFinder, findsOneWidget);
      final remainingText = tester.widget<Text>(remainingFinder);
      expect(remainingText.data, '00:00');
      expect(find.text('Rejouer'), findsOneWidget);
    });
  });
}

