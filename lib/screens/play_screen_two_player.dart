import 'dart:async';

import 'package:flutter/material.dart';

import '../components/game_button.dart';
import '../components/player_zone.dart';
import '../models/tap_settings.dart';

class PlayScreenTwoPlayer extends StatefulWidget {
  const PlayScreenTwoPlayer({
    super.key,
    required this.tapSettings,
  });

  final TapSettings tapSettings;

  @override
  State<PlayScreenTwoPlayer> createState() => _PlayScreenTwoPlayerState();
}

class _PlayScreenTwoPlayerState extends State<PlayScreenTwoPlayer> {
  static const Color _idleBackground = Color(0xFF1976D2);
  static const Color _dangerBackground = Color(0xFFC62828);
  static const Color _endBackground = Color(0xFF2E7D32);
  static const Color _player1Background = Color(0xFF1565C0);
  static const Color _player2Background = Color(0xFF00695C);

  int _tapCountPlayer1 = 0;
  int _tapCountPlayer2 = 0;
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

  void _incrementCounterPlayer1() {
    if (!_canTap) return;
    setState(() {
      _tapCountPlayer1++;
    });
  }

  void _incrementCounterPlayer2() {
    if (!_canTap) return;
    setState(() {
      _tapCountPlayer2++;
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
    _tapCountPlayer1 = 0;
    _tapCountPlayer2 = 0;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jouer à 2'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Joueur 1 - Zone du haut
                Expanded(
                  child: _buildPlayerZone(
                    context: context,
                    theme: theme,
                    playerNumber: 1,
                    tapCount: _tapCountPlayer1,
                    onTap: _incrementCounterPlayer1,
                    backgroundColor: _player1Background,
                  ),
                ),
                // Diviseur
                Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.3),
                ),
                // Joueur 2 - Zone du bas
                Expanded(
                  child: _buildPlayerZone(
                    context: context,
                    theme: theme,
                    playerNumber: 2,
                    tapCount: _tapCountPlayer2,
                    onTap: _incrementCounterPlayer2,
                    backgroundColor: _player2Background,
                  ),
                ),
              ],
            ),
            // Boutons de contrôle au centre, au-dessus de tout
            if (!_isCountingDown && !_isGameRunning)
              GameButton(
                onPressed: _startCountdown,
                label: _gameOver ? 'Rejouer' : 'Démarrer',
                angle: 4.7124, // 270°
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerZone({
    required BuildContext context,
    required ThemeData theme,
    required int playerNumber,
    required int tapCount,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    final computedBackground = _computeBackgroundColor(backgroundColor);
    final rotationAngle = playerNumber == 1 ? 3.14159 : 0.0; // 180° pour joueur 1, 0° pour joueur 2

    return PlayerZone(
      theme: theme,
      playerNumber: playerNumber,
      tapCount: tapCount,
      onTap: onTap,
      backgroundColor: computedBackground,
      isCountingDown: _isCountingDown,
      countdownValue: _countdownValue,
      isGameRunning: _isGameRunning,
      isGameOver: _gameOver,
      remainingLabel: _remainingLabel,
      canTap: _canTap,
      rotationAngle: rotationAngle,
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

  Color _computeBackgroundColor(Color baseColor) {
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
        return Color.lerp(baseColor, _dangerBackground, ratio)!;
      }

      return baseColor;
    }

    return _idleBackground;
  }
}

