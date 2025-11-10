import 'package:flutter/foundation.dart';

class TapSettings extends ChangeNotifier {
  TapSettings({
    Duration tapDuration = const Duration(minutes: 1),
  }) : _tapDuration = tapDuration;

  Duration _tapDuration;

  Duration get tapDuration => _tapDuration;

  set tapDuration(Duration value) {
    if (value == _tapDuration) return;
    assert(
      !value.isNegative && value > Duration.zero,
      'La durée de tap doit être positive.',
    );
    _tapDuration = value;
    notifyListeners();
  }
}


