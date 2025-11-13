import 'package:flutter/material.dart';

import 'game_content.dart';

/// Zone de joueur avec compteur, countdown et timer
class PlayerZone extends StatelessWidget {
  const PlayerZone({
    super.key,
    required this.theme,
    required this.playerNumber,
    required this.tapCount,
    required this.onTap,
    required this.backgroundColor,
    required this.isCountingDown,
    required this.countdownValue,
    required this.isGameRunning,
    required this.isGameOver,
    required this.remainingLabel,
    required this.canTap,
    this.rotationAngle = 0.0,
  });

  final ThemeData theme;
  final int playerNumber;
  final int tapCount;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final bool isCountingDown;
  final int? countdownValue;
  final bool isGameRunning;
  final bool isGameOver;
  final String remainingLabel;
  final bool canTap;
  final double rotationAngle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('play-area-player-$playerNumber'),
      behavior: HitTestBehavior.opaque,
      onTap: canTap ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: backgroundColor,
        child: Stack(
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: GameContent(
                  key: ValueKey('game-content-player-$playerNumber-${isCountingDown ? countdownValue : tapCount}'),
                  theme: theme,
                  isCountingDown: isCountingDown,
                  countdownValue: countdownValue,
                  isGameRunning: isGameRunning,
                  isGameOver: isGameOver,
                  tapCount: tapCount,
                  remainingLabel: remainingLabel,
                  playerLabel: 'Joueur $playerNumber',
                  rotationAngle: rotationAngle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

