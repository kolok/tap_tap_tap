import 'package:flutter/material.dart';

import '../models/tap_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.tapSettings,
  });

  final TapSettings tapSettings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _minDuration = Duration(seconds: 1);
  static const _maxDuration = Duration(minutes: 5);
  late double _durationSeconds;

  @override
  void initState() {
    super.initState();
    final currentSeconds = widget.tapSettings.tapDuration.inSeconds.toDouble();
    _durationSeconds =
        currentSeconds.clamp(_minDuration.inSeconds.toDouble(), _maxDuration.inSeconds.toDouble());
  }

  String get _durationLabel {
    final totalSeconds = _durationSeconds.round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0) {
      final minutePart = minutes > 1 ? '$minutes minutes' : '$minutes minute';
      if (seconds == 0) {
        return minutePart;
      }
      return '$minutePart ${seconds.toString().padLeft(2, '0')} s';
    }
    return '$totalSeconds s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durée autorisée pour taper',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _durationLabel,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              min: _minDuration.inSeconds.toDouble(),
              max: _maxDuration.inSeconds.toDouble(),
              divisions: _maxDuration.inSeconds - _minDuration.inSeconds,
              label: _durationLabel,
              value: _durationSeconds,
              onChanged: (value) {
                setState(() {
                  _durationSeconds = value;
                });
              },
              onChangeEnd: (value) {
                final duration =
                    Duration(seconds: value.round().clamp(_minDuration.inSeconds, _maxDuration.inSeconds));
                widget.tapSettings.tapDuration = duration;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Sélectionnez une durée entre 1 seconde et 5 minutes. Elle sera appliquée immédiatement.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

