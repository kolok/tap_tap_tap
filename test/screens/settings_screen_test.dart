import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_tap_tap/models/tap_settings.dart';
import 'package:tap_tap_tap/screens/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    Future<void> _pumpSettings(WidgetTester tester, TapSettings tapSettings) {
      return tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(tapSettings: tapSettings),
        ),
      );
    }

    testWidgets('affiche la durée initiale issue des réglages', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 75));

      await _pumpSettings(tester, tapSettings);

      expect(find.text('1 minute 15 s'), findsOneWidget);
    });

    testWidgets('applique une nouvelle durée via le slider', (tester) async {
      final tapSettings = TapSettings(tapDuration: const Duration(seconds: 60));

      await _pumpSettings(tester, tapSettings);

      final sliderFinder = find.byType(Slider);
      var slider = tester.widget<Slider>(sliderFinder);
      slider.onChanged?.call(90);
      await tester.pump();

      slider = tester.widget<Slider>(sliderFinder);
      slider.onChangeEnd?.call(90);
      await tester.pump();

      expect(tapSettings.tapDuration, const Duration(seconds: 90));
      expect(find.text('1 minute 30 s'), findsOneWidget);
    });
  });
}

