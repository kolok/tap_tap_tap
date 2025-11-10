import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_tap_tap/models/tap_settings.dart';

void main() {
  group('TapSettings', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('expose la durée initiale par défaut', () {
      final settings = TapSettings();

      expect(settings.tapDuration, const Duration(minutes: 1));
    });

    test('notifie les auditeurs lors d’un changement de durée', () {
      final settings = TapSettings();
      var notifications = 0;
      settings.addListener(() {
        notifications++;
      });

      settings.tapDuration = const Duration(seconds: 45);

      expect(settings.tapDuration, const Duration(seconds: 45));
      expect(notifications, 1);
    });

    test('ne notifie pas quand la durée reste identique', () {
      final settings = TapSettings(tapDuration: const Duration(minutes: 2));
      var notifications = 0;
      settings.addListener(() {
        notifications++;
      });

      settings.tapDuration = const Duration(minutes: 2);

      expect(notifications, 0);
    });

    test('rejette les durées négatives ou nulles', () {
      final settings = TapSettings(tapDuration: const Duration(seconds: 10));

      expect(
        () => settings.tapDuration = Duration.zero,
        throwsAssertionError,
      );
      expect(
        () => settings.tapDuration = const Duration(seconds: -5),
        throwsAssertionError,
      );
    });

    test('persiste la durée choisie', () async {
      final settings = TapSettings();

      settings.tapDuration = const Duration(seconds: 45);
      await pumpEventQueue();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getInt('tap_duration_seconds'), 45);
    });

    test('charge la durée persistée', () async {
      SharedPreferences.setMockInitialValues({
        'tap_duration_seconds': 120,
      });

      final settings = await TapSettings.load();

      expect(settings.tapDuration, const Duration(minutes: 2));
    });
  });
}

