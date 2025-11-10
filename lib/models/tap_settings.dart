import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TapSettings extends ChangeNotifier {
  TapSettings({
    Duration tapDuration = const Duration(minutes: 1),
  }) : _tapDuration = tapDuration;

  TapSettings._withPersistence({
    required Duration tapDuration,
    required SharedPreferences preferences,
  })  : _tapDuration = tapDuration,
        _preferences = preferences;

  static const Duration _defaultDuration = Duration(minutes: 1);
  static const Duration _minDuration = Duration(seconds: 1);
  static const Duration _maxDuration = Duration(minutes: 5);
  static const String _tapDurationKey = 'tap_duration_seconds';

  Duration _tapDuration;
  SharedPreferences? _preferences;

  Duration get tapDuration => _tapDuration;

  set tapDuration(Duration value) {
    if (value == _tapDuration) return;
    assert(
      !value.isNegative && value > Duration.zero,
      'La durée de tap doit être positive.',
    );
    final clampedDuration = _clampDuration(value);
    _tapDuration = clampedDuration;
    unawaited(_persistDuration(clampedDuration));
    notifyListeners();
  }

  static Future<TapSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedSeconds = preferences.getInt(_tapDurationKey);
    final storedDuration = storedSeconds == null
        ? _defaultDuration
        : Duration(seconds: storedSeconds);
    final clampedDuration = _clampDuration(storedDuration);

    return TapSettings._withPersistence(
      tapDuration: clampedDuration,
      preferences: preferences,
    );
  }

  static Duration _clampDuration(Duration duration) {
    final clampedSeconds = duration.inSeconds.clamp(
      _minDuration.inSeconds,
      _maxDuration.inSeconds,
    );
    return Duration(seconds: clampedSeconds.toInt());
  }

  Future<void> _persistDuration(Duration duration) async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    _preferences = prefs;
    await prefs.setInt(_tapDurationKey, duration.inSeconds);
  }
}


