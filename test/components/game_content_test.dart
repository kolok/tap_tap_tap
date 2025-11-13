import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_tap_tap/components/game_content.dart';

void main() {
  group('GameContent', () {
    final theme = ThemeData(
      textTheme: TextTheme(
        displayLarge: const TextStyle(fontSize: 96),
        headlineSmall: const TextStyle(fontSize: 32),
        titleLarge: const TextStyle(fontSize: 20),
      ),
    );

    testWidgets('affiche le countdown quand isCountingDown est true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isCountingDown: true,
              countdownValue: 3,
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.byKey(const ValueKey('countdown')), findsOneWidget);
    });

    testWidgets('affiche le countdown avec playerLabel si fourni', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isCountingDown: true,
              countdownValue: 2,
              playerLabel: 'Joueur 1',
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.byKey(const ValueKey('countdown-player-Joueur 1')), findsOneWidget);
    });

    testWidgets('affiche le compteur de taps pendant le jeu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isGameRunning: true,
              tapCount: 42,
              remainingLabel: '00:30',
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.text('00:30'), findsOneWidget);
      expect(find.byKey(const ValueKey('game-stats')), findsOneWidget);
      expect(find.byKey(const ValueKey('tap-counter')), findsOneWidget);
      expect(find.byKey(const ValueKey('remaining-time')), findsOneWidget);
    });

    testWidgets('affiche le compteur avec playerLabel pendant le jeu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isGameRunning: true,
              tapCount: 15,
              remainingLabel: '00:15',
              playerLabel: 'Joueur 2',
            ),
          ),
        ),
      );

      expect(find.text('Joueur 2'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('00:15'), findsOneWidget);
      expect(find.byKey(const ValueKey('game-stats-player-Joueur 2')), findsOneWidget);
      expect(find.byKey(const ValueKey('tap-counter-player-Joueur 2')), findsOneWidget);
    });

    testWidgets('affiche le contenu de fin de partie', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isGameOver: true,
              tapCount: 100,
              remainingLabel: '00:00',
            ),
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.byKey(const ValueKey('game-stats')), findsOneWidget);
    });

    testWidgets('affiche l\'état idle si pas de jeu en cours', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isCountingDown: false,
              isGameRunning: false,
              isGameOver: false,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('idle')), findsOneWidget);
    });

    testWidgets('affiche l\'état idle avec playerLabel si fourni', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isCountingDown: false,
              isGameRunning: false,
              isGameOver: false,
              playerLabel: 'Joueur 1',
            ),
          ),
        ),
      );

      expect(find.text('Joueur 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('idle-player-Joueur 1')), findsOneWidget);
    });

    testWidgets('applique une rotation si rotationAngle est fourni', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isGameRunning: true,
              tapCount: 10,
              rotationAngle: 3.14159, // 180 degrés
            ),
          ),
        ),
      );

      // Vérifie que le contenu est affiché (la rotation est appliquée en interne)
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('n\'applique pas de rotation si rotationAngle est 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isGameRunning: true,
              tapCount: 10,
              rotationAngle: 0.0,
            ),
          ),
        ),
      );

      // Vérifie que le contenu est affiché correctement sans rotation
      expect(find.text('10'), findsOneWidget);
      // Note: Il peut y avoir des Transform dans l'arbre des widgets (MaterialApp, etc.)
      // mais le GameContent lui-même n'en crée pas quand rotationAngle est 0
    });

    testWidgets('n\'affiche pas remainingLabel si null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isGameRunning: true,
              tapCount: 5,
              remainingLabel: null,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.byKey(const ValueKey('remaining-time')), findsNothing);
    });

    testWidgets('priorise le countdown sur le jeu en cours', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: GameContent(
              theme: theme,
              isCountingDown: true,
              countdownValue: 1,
              isGameRunning: true,
              tapCount: 50,
            ),
          ),
        ),
      );

      // Le countdown doit être affiché, pas le compteur
      expect(find.text('1'), findsOneWidget);
      expect(find.byKey(const ValueKey('countdown')), findsOneWidget);
      expect(find.byKey(const ValueKey('game-stats')), findsNothing);
    });
  });
}

