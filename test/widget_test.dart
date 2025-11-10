// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_tap_tap/main.dart';
import 'package:tap_tap_tap/models/tap_settings.dart';
import 'package:tap_tap_tap/screens/home_screen.dart';

void main() {
  group('TapTapTapApp', () {
    testWidgets('construit un MaterialApp avec HomeScreen', (tester) async {
      final tapSettings = TapSettings();

      await tester.pumpWidget(TapTapTapApp(tapSettings: tapSettings));

      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(materialAppFinder);
      expect(materialApp.home, isA<HomeScreen>());
    });

    testWidgets('le HomeScreen partage la même instance de TapSettings', (tester) async {
      final tapSettings = TapSettings();

      await tester.pumpWidget(TapTapTapApp(tapSettings: tapSettings));

      final home = tester.widget<HomeScreen>(find.byType(HomeScreen));
      final settings = home.tapSettings;

      expect(settings.tapDuration, const Duration(minutes: 1));

      settings.tapDuration = const Duration(seconds: 90);
      await tester.pump();

      // Le HomeScreen est reconstruit automatiquement puisque les tests
      // manipulent le même objet.
      final updatedHome = tester.widget<HomeScreen>(find.byType(HomeScreen));
      expect(identical(settings, updatedHome.tapSettings), isTrue);
    });
  });
}
