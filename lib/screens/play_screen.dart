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
  static const Color _idleBackground = Color(0xFF1976D2);
  static const Color _gameBackground = Color(0xFF1565C0);
  static const Color _dangerBackground = Color(0xFFC62828);
  static const Color _endBackground = Color(0xFF2E7D32);

  int _tapCount = 0;
  int? _countdownValue;
  bool _canTap = false;
  Timer? _countdownTimer;
  Timer? _gameTimer;
  Duration _elapsed = Duration.zero;
  bool _gameOver = false;
  late Duration _gameDuration;

  bool get _isCountingDown => _countdownValue != null;
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
    if (_isCountingDown || _isGameRunning) return;
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

      final nextValue = _countdownValue! - 1;
      setState(() {
        if (nextValue <= 0) {
          _countdownValue = null;
          _startGame();
        } else {
          _countdownValue = nextValue;
        }
      });

      if (nextValue <= 0) {
        timer.cancel();
        _countdownTimer = null;
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
    final backgroundColor = _computeBackgroundColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jouer'),
      ),
      body: SafeArea(
        child: GestureDetector(
          key: const ValueKey('play-area'),
          behavior: HitTestBehavior.opaque,
          onTap: _canTap ? _incrementCounter : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: backgroundColor,
            child: Stack(
              children: [
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCentralContent(theme),
                  ),
                ),
                if (_gameOver)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FilledButton(
                        onPressed: _startCountdown,
                        child: const Text('Rejouer'),
                      ),
                    ),
                  ),
                if (!_isCountingDown && !_isGameRunning && !_gameOver)
                  Center(
                    child: FilledButton(
                      onPressed: _startCountdown,
                      child: const Text('Démarrer'),
                    ),
                  ),
              ],
            ),
          ),
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

  Widget _buildCentralContent(ThemeData theme) {
    final textTheme = theme.textTheme;

    if (_isCountingDown && _countdownValue != null) {
      return Text(
        '${_countdownValue!}',
        key: const ValueKey('countdown'),
        style: textTheme.displayLarge?.copyWith(color: Colors.white) ??
            const TextStyle(
              fontSize: 96,
              color: Colors.white,
            ),
      );
    }

    if (_isGameRunning || _gameOver) {
      return Column(
        key: const ValueKey('game-stats'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_tapCount',
            key: const ValueKey('tap-counter'),
            style: textTheme.displayLarge?.copyWith(color: Colors.white) ??
                const TextStyle(
                  fontSize: 96,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _remainingLabel,
            key: const ValueKey('remaining-time'),
            style: textTheme.headlineMedium?.copyWith(color: Colors.white70) ??
                const TextStyle(
                  fontSize: 32,
                  color: Colors.white70,
                ),
          ),
        ],
      );
    }

    return const SizedBox(
      key: ValueKey('idle'),
    );
  }

  Color _computeBackgroundColor() {
    if (_gameOver) {
      return _endBackground;
    }

    if (_isGameRunning) {
      final remaining = _gameDuration - _elapsed;
      if (remaining <= Duration.zero) {
        return _endBackground;
      }

      if (remaining <= const Duration(seconds: 3)) {
        final ratio =
            1 - (remaining.inMilliseconds.clamp(0, 3000) / 3000.0);
        return Color.lerp(_gameBackground, _dangerBackground, ratio)!;
      }

      return _gameBackground;
    }

    return _idleBackground;
  }
}

