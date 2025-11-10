import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tap_settings.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    required this.tapSettings,
  });

  final TapSettings tapSettings;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  int _tapCount = 0;
  int? _countdownValue;
  bool _canTap = false;
  Timer? _countdownTimer;
  Timer? _gameTimer;
  Duration _elapsed = Duration.zero;
  bool _gameOver = false;
  late Duration _gameDuration;

  bool get _isCountingDown => _countdownTimer != null;
  bool get _isGameRunning => _canTap && !_gameOver;

  String get _remainingLabel {
    final rawRemaining = _gameDuration - _elapsed;
    final remaining = rawRemaining <= Duration.zero ? Duration.zero : rawRemaining;
    final seconds = remaining.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _gameDuration = widget.tapSettings.tapDuration;
    widget.tapSettings.addListener(_onSettingsChanged);
  }

  void _incrementCounter() {
    if (!_canTap) return;
    setState(() {
      _tapCount++;
    });
  }

  void _startCountdown() {
    if (_isCountingDown) return;
    _resetGameState();

    setState(() {
      _countdownValue = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdownValue == null) {
        timer.cancel();
        _countdownTimer = null;
        return;
      }

      if (_countdownValue! > 0) {
        final nextValue = _countdownValue! - 1;
        setState(() {
          _countdownValue = nextValue;
          if (nextValue == 0) {
            _startGame();
          }
        });

        if (nextValue == 0) {
          timer.cancel();
          _countdownTimer = null;
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            if (_countdownValue == 0) {
              setState(() {
                _countdownValue = null;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    widget.tapSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _resetGameState() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    _countdownTimer = null;
    _gameTimer = null;
    _tapCount = 0;
    _elapsed = Duration.zero;
    _canTap = false;
    _gameOver = false;
    _countdownValue = null;
    _gameDuration = widget.tapSettings.tapDuration;
  }

  void _startGame() {
    _canTap = true;
    _gameOver = false;
    _elapsed = Duration.zero;
    _gameDuration = widget.tapSettings.tapDuration;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextElapsed = _elapsed + const Duration(seconds: 1);
      final isGameFinished = nextElapsed >= _gameDuration;

      setState(() {
        _elapsed = nextElapsed;
        if (isGameFinished) {
          _gameOver = true;
          _canTap = false;
        }
      });

      if (isGameFinished) {
        timer.cancel();
        _gameTimer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _canTap
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = _canTap
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jouer'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isCountingDown ? null : _startCountdown,
                    child: const Text('Démarrer'),
                  ),
              Text(
                _durationLabel(_gameDuration),
                style: theme.textTheme.bodyLarge,
              ),
                  if (_countdownValue != null && _countdownValue! > 0)
                    Text(
                      '${_countdownValue!}',
                      style: theme.textTheme.headlineMedium,
                    ),
                  if (_elapsed > Duration.zero || _isGameRunning)
                    Text(
                      _remainingLabel,
                      style: theme.textTheme.titleLarge,
                    ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _canTap ? _incrementCounter : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                  ),
                  child: Center(
                    child: Text(
                      '$_tapCount',
                      style: theme.textTheme.displayLarge?.copyWith(
                            color: textColor,
                          ) ??
                          TextStyle(
                            fontSize: 96,
                            color: textColor,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSettingsChanged() {
    final newDuration = widget.tapSettings.tapDuration;
    if (!mounted || newDuration == _gameDuration) return;
    setState(() {
      _gameDuration = newDuration;
      if (_elapsed >= _gameDuration) {
        _gameOver = true;
        _canTap = false;
        _gameTimer?.cancel();
        _gameTimer = null;
      }
    });
  }

  String _durationLabel(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      final minutePart = minutes > 1 ? '$minutes minutes' : '$minutes minute';
      if (seconds == 0) {
        return minutePart;
      }
      return '$minutePart ${seconds.toString().padLeft(2, '0')} s';
    }
    return '${duration.inSeconds} s';
  }
}

