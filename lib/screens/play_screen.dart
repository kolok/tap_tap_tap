import 'dart:async';

import 'package:flutter/material.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

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

  bool get _isCountingDown => _countdownTimer != null;
  bool get _isGameRunning => _canTap && !_gameOver;

  String get _elapsedLabel {
    final seconds = _elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
  }

  void _startGame() {
    _canTap = true;
    _gameOver = false;
    _elapsed = Duration.zero;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextElapsed = _elapsed + const Duration(seconds: 1);
      final isGameFinished = nextElapsed >= const Duration(minutes: 1);

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
                  if (_countdownValue != null && _countdownValue! > 0)
                    Text(
                      '${_countdownValue!}',
                      style: theme.textTheme.headlineMedium,
                    ),
                  if (_elapsed > Duration.zero || _isGameRunning)
                    Text(
                      _elapsedLabel,
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
}

