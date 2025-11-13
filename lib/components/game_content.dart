import 'package:flutter/material.dart';

/// Contenu central du jeu affichant le countdown, le compteur de taps et le timer
class GameContent extends StatelessWidget {
  const GameContent({
    super.key,
    required this.theme,
    this.isCountingDown = false,
    this.countdownValue,
    this.isGameRunning = false,
    this.isGameOver = false,
    this.tapCount,
    this.remainingLabel,
    this.playerLabel,
    this.rotationAngle = 0.0,
  });

  final ThemeData theme;
  final bool isCountingDown;
  final int? countdownValue;
  final bool isGameRunning;
  final bool isGameOver;
  final int? tapCount;
  final String? remainingLabel;
  final String? playerLabel;
  final double rotationAngle;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isCountingDown && countdownValue != null) {
      content = Text(
        '$countdownValue',
        key: ValueKey('countdown${playerLabel != null ? '-player-$playerLabel' : ''}'),
        style: theme.textTheme.displayLarge?.copyWith(color: Colors.white) ??
            TextStyle(
              fontSize: playerLabel != null ? 72 : 96,
              color: Colors.white,
            ),
      );
    } else if (isGameRunning || isGameOver) {
      content = Column(
        key: ValueKey('game-stats${playerLabel != null ? '-player-$playerLabel' : ''}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playerLabel != null)
            Text(
              playerLabel!,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ) ??
                  TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
          if (playerLabel != null) const SizedBox(height: 8),
          if (tapCount != null)
            Text(
              '$tapCount',
              key: ValueKey('tap-counter${playerLabel != null ? '-player-$playerLabel' : ''}'),
              style: theme.textTheme.displayLarge?.copyWith(color: Colors.white) ??
                  TextStyle(
                    fontSize: playerLabel != null ? 72 : 96,
                    color: Colors.white,
                  ),
            ),
          if (remainingLabel != null) ...[
            SizedBox(height: playerLabel != null ? 12 : 12),
            Text(
              remainingLabel!,
              key: ValueKey('remaining-time${playerLabel != null ? '-player-$playerLabel' : ''}'),
              style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white70) ??
                  TextStyle(
                    fontSize: playerLabel != null ? 24 : 32,
                    color: Colors.white70,
                  ),
            ),
          ],
        ],
      );
    } else {
      content = Column(
        key: ValueKey('idle${playerLabel != null ? '-player-$playerLabel' : ''}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playerLabel != null)
            Text(
              playerLabel!,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ) ??
                  TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
        ],
      );
    }

    if (rotationAngle != 0.0) {
      content = Transform.rotate(
        angle: rotationAngle,
        child: content,
      );
    }

    return content;
  }
}

