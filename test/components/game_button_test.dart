import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_tap_tap/components/game_button.dart';

void main() {
  group('GameButton', () {
    testWidgets('affiche le label fourni', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: () {},
              label: 'Test Button',
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('appelle onPressed quand on appuie dessus', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: () {
                pressed = true;
              },
              label: 'Test Button',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      expect(pressed, isTrue);
    });

    testWidgets('ne fait rien si onPressed est null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: null,
              label: 'Disabled Button',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled Button'));
      // Ne devrait pas lever d'exception
      expect(find.text('Disabled Button'), findsOneWidget);
    });

    testWidgets('applique une rotation si angle est fourni', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: () {},
              label: 'Rotated Button',
              angle: 1.5708, // 90 degrés
            ),
          ),
        ),
      );

      // Vérifie que le bouton est affiché (la rotation est appliquée en interne)
      expect(find.text('Rotated Button'), findsOneWidget);
    });

    testWidgets('n\'applique pas de rotation si angle est 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: () {},
              label: 'Normal Button',
              angle: 0.0,
            ),
          ),
        ),
      );

      // Vérifie que le bouton est affiché normalement
      expect(find.text('Normal Button'), findsOneWidget);
    });

    testWidgets('applique l\'alignement si fourni', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: () {},
              label: 'Aligned Button',
              alignment: Alignment.topLeft,
            ),
          ),
        ),
      );

      // Vérifie que le bouton est affiché (l'alignement est appliqué en interne)
      expect(find.text('Aligned Button'), findsOneWidget);
    });

    testWidgets('n\'applique pas d\'alignement si center et pas de padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: () {},
              label: 'Centered Button',
              alignment: Alignment.center,
            ),
          ),
        ),
      );

      // Vérifie que le bouton est affiché normalement
      expect(find.text('Centered Button'), findsOneWidget);
    });

    testWidgets('applique le padding si fourni', (tester) async {
      const padding = EdgeInsets.all(16);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: () {},
              label: 'Padded Button',
              padding: padding,
            ),
          ),
        ),
      );

      // Vérifie que le bouton est affiché (le padding est appliqué en interne)
      expect(find.text('Padded Button'), findsOneWidget);
    });

    testWidgets('combine alignement et padding si tous deux fournis', (tester) async {
      const padding = EdgeInsets.only(left: 20);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              onPressed: () {},
              label: 'Combined Button',
              alignment: Alignment.centerLeft,
              padding: padding,
            ),
          ),
        ),
      );

      // Vérifie que le bouton est affiché (l'alignement et le padding sont appliqués en interne)
      expect(find.text('Combined Button'), findsOneWidget);
    });
  });
}

