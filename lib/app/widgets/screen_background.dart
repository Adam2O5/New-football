import 'package:flutter/material.dart';

/// Wraps a screen's body with the game's background image, painted behind
/// the content. Use inside `Scaffold(body: ScreenBackground(child: ...))`.
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/new-football-background.png',
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}
