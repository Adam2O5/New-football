import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated envelope reveal widget for the draft lottery ceremony.
///
/// Performs a 3-phase animation (total ~2500ms):
/// 1. Envelope entrance — scales from 0 to 1 with bounce effect
/// 2. Flap opens — top flap rotates from 0 to -π/2 radians
/// 3. Card slides out — translates upward with team name fading in
///
/// Calls [onComplete] when the full animation finishes.
class EnvelopeAnimation extends StatefulWidget {
  const EnvelopeAnimation({
    super.key,
    required this.teamName,
    required this.onComplete,
  });

  final String teamName;
  final VoidCallback onComplete;

  @override
  State<EnvelopeAnimation> createState() => _EnvelopeAnimationState();
}

class _EnvelopeAnimationState extends State<EnvelopeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _envelopeScale;
  late final Animation<double> _flapRotation;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _envelopeScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
    );

    _flapRotation = Tween<double>(begin: 0, end: -math.pi / 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeInOut),
      ),
    );

    _cardSlide = Tween<double>(begin: 0, end: -80).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _cardOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.85, curve: Curves.easeIn),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ScaleTransition(
        scale: _envelopeScale,
        child: SizedBox(
          width: 200,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Card that slides out from inside the envelope
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _cardSlide.value),
                    child: Opacity(
                      opacity: _cardOpacity.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 180,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_football,
                        size: 28,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.teamName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Envelope body
              Positioned(
                bottom: 0,
                child: Container(
                  width: 200,
                  height: 140,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Envelope flap (top triangle)
              Positioned(
                bottom: 140 - 2, // Sits on top of envelope body
                child: AnimatedBuilder(
                  animation: _flapRotation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateX(_flapRotation.value),
                      child: child,
                    );
                  },
                  child: ClipPath(
                    clipper: _EnvelopeFlapClipper(),
                    child: Container(
                      width: 200,
                      height: 70,
                      color: colorScheme.surfaceContainerHigh,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clips the envelope flap into a trapezoid/triangle shape pointing downward.
class _EnvelopeFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
