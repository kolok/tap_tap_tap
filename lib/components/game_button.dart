import 'package:flutter/material.dart';

/// Bouton de jeu réutilisable avec options de rotation et d'alignement
class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.angle = 0.0,
    this.alignment = Alignment.center,
    this.padding,
  });

  final VoidCallback? onPressed;
  final String label;
  final double angle;
  final Alignment alignment;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    Widget button = FilledButton(
      onPressed: onPressed,
      child: Text(label),
    );

    if (angle != 0.0) {
      button = Transform.rotate(
        angle: angle,
        child: button,
      );
    }

    if (alignment != Alignment.center || padding != null) {
      return Align(
        alignment: alignment,
        child: padding != null
            ? Padding(
                padding: padding!,
                child: button,
              )
            : button,
      );
    }

    return button;
  }
}

