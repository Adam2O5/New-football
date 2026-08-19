import 'package:flutter/material.dart';

/// Wraps a screen's body with the game's background image, painted behind
/// the content. Use inside `Scaffold(body: ScreenBackground(child: ...))`.
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          child: Image.asset(
            'assets/images/new-football-background.png',
            fit: BoxFit.cover,
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.surface.withValues(alpha: 0.76),
                  colors.surface.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
