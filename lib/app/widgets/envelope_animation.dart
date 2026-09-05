import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animowane otwarcie koperty z wynikiem loterii draftowej.
///
/// Etapy animacji (łącznie ~3200ms):
/// 1. Wejście koperty — skala 0→1 z odbiciem (anticipation pop).
/// 2. Napięcie — delikatne drżenie koperty przed otwarciem.
/// 3. Otwarcie klapki — obrót 3D z zanikiem przy krawędzi (bez efektu "lustra"
///    tylnej strony po przekroczeniu 90°).
/// 4. Wysunięcie karty — slide + scale (pop) + tilt + fade.
/// 5. Połysk na karcie i — jeśli [showConfetti] jest true — konfetti w tle,
///    jako akcent finałowy (używane np. tylko dla pick #1).
///
/// Wywołuje [onComplete] po zakończeniu całej sekwencji.
class EnvelopeAnimation extends StatefulWidget {
  const EnvelopeAnimation({
    super.key,
    required this.teamName,
    required this.onComplete,
    this.showConfetti = false,
  });

  final String teamName;
  final VoidCallback onComplete;

  /// Czy po ujawnieniu karty ma się pojawić konfetti. Domyślnie wyłączone —
  /// używane tylko dla najważniejszej koperty (np. pick #1).
  final bool showConfetti;

  @override
  State<EnvelopeAnimation> createState() => _EnvelopeAnimationState();
}

class _EnvelopeAnimationState extends State<EnvelopeAnimation>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 3200);
  static const _stackWidth = 240.0;
  static const _stackHeight = 300.0;

  late final AnimationController _controller;

  late final Animation<double> _envelopeScale;
  late final Animation<double> _envelopeShake;
  late final Animation<double> _shadowBlur;

  late final Animation<double> _flapRotation;
  late final Animation<double> _flapShade;
  late final Animation<double> _interiorOpacity;

  late final Animation<double> _cardSlide;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardTilt;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _shinePosition;

  late final Animation<double> _confettiProgress;
  late final List<_Confetto> _confetti;

  @override
  void initState() {
    super.initState();

    _confetti = widget.showConfetti
        ? _generateConfetti(widget.teamName.hashCode)
        : const [];

    _controller = AnimationController(duration: _duration, vsync: this);

    _envelopeScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.16, curve: Curves.easeOutBack),
    );

    _shadowBlur = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _envelopeShake =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.05), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.04), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.04, end: -0.025), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -0.025, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.16, 0.30, curve: Curves.easeInOut),
          ),
        );

    _flapRotation = Tween<double>(begin: 0, end: -math.pi * 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.55, curve: Curves.easeInOutCubic),
      ),
    );

    _flapShade = Tween<double>(begin: 0, end: 0.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.55, curve: Curves.easeIn),
      ),
    );

    _interiorOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.55, curve: Curves.easeIn),
    );

    _cardSlide = Tween<double>(begin: 0, end: -110).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _cardScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.08), weight: 70),
          TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 30),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.58, 0.90, curve: Curves.easeOut),
          ),
        );

    _cardTilt = Tween<double>(begin: -0.15, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _cardOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.58, 0.74, curve: Curves.easeIn),
    );

    _shinePosition = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 1.0, curve: Curves.easeInOut),
      ),
    );

    _confettiProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();
  }

  List<_Confetto> _generateConfetti(int seed) {
    final random = math.Random(seed);
    return List.generate(20, (_) {
      final angle = random.nextDouble() * math.pi * 2;
      return _Confetto(
        angle: angle,
        speed: 50 + random.nextDouble() * 90,
        size: 4 + random.nextDouble() * 5,
        color: _confettiColors[random.nextInt(_confettiColors.length)],
        rotationSpeed: (random.nextDouble() - 0.5) * 12,
      );
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.rotate(
            angle: _envelopeShake.value,
            child: Transform.scale(
              scale: _envelopeScale.value,
              child: SizedBox(
                width: _stackWidth,
                height: _stackHeight,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    _buildEnvelopeBody(colorScheme),
                    _buildCard(colorScheme),
                    _buildFlap(colorScheme),
                    if (widget.showConfetti) _buildConfetti(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnvelopeBody(ColorScheme colorScheme) {
    return Positioned(
      bottom: 10,
      child: Container(
        width: 240,
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHigh,
              colorScheme.surfaceContainerHighest,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: _shadowBlur.value,
              offset: Offset(0, _shadowBlur.value * 0.3),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 40),
            width: 210,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.22 * _interiorOpacity.value,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlap(ColorScheme colorScheme) {
    final rotation = _flapRotation.value;
    // Zamiast polegać na sztywnym kącie końcowym, wygaszamy klapkę tuż przed
    // przejściem na widok "od krawędzi" (90°) — eliminuje to artefakt
    // renderowania lustrzanej tylnej strony przy dalszej rotacji.
    final edgeOpacity = (1 - (rotation.abs() / (math.pi / 2))).clamp(0.0, 1.0);

    return Positioned(
      bottom: 170,
      child: Opacity(
        opacity: edgeOpacity,
        child: Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(rotation),
          child: ClipPath(
            clipper: _EnvelopeFlapClipper(),
            child: Container(
              width: 240,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surfaceContainerHigh,
                  ],
                ),
              ),
              foregroundDecoration: BoxDecoration(
                color: Colors.black.withValues(alpha: _flapShade.value),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ColorScheme colorScheme) {
    return Transform.translate(
      offset: Offset(0, _cardSlide.value),
      child: Transform.rotate(
        angle: _cardTilt.value,
        child: Transform.scale(
          scale: _cardScale.value,
          child: Opacity(
            opacity: _cardOpacity.value,
            child: ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                final pos = _shinePosition.value;
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Colors.transparent,
                    Color(0x59FFFFFF),
                    Colors.transparent,
                  ],
                  stops: [
                    (pos - 0.25).clamp(0.0, 1.0),
                    pos.clamp(0.0, 1.0),
                    (pos + 0.25).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds);
              },
              child: Container(
                width: 200,
                height: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primaryContainer.withValues(alpha: 0.85),
                    ],
                  ),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        Icons.sports_football,
                        size: 26,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.teamName,
                      style: TextStyle(
                        fontSize: 17,
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
          ),
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ConfettiPainter(
            confetti: _confetti,
            progress: _confettiProgress.value,
          ),
        ),
      ),
    );
  }
}

const _confettiColors = [
  Color(0xFFFFC107),
  Color(0xFF4CAF50),
  Color(0xFF2196F3),
  Color(0xFFE91E63),
  Color(0xFFFF7043),
];

class _Confetto {
  const _Confetto({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });

  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.confetti, required this.progress});

  final List<_Confetto> confetti;
  final double progress;

  static const _fadeStart = 0.65;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || confetti.isEmpty) return;

    final center = Offset(size.width / 2, size.height * 0.14);
    final opacity = progress < _fadeStart
        ? 1.0
        : (1.0 - (progress - _fadeStart) / (1.0 - _fadeStart)).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    for (final confetto in confetti) {
      final distance = confetto.speed * progress;
      final dx = math.cos(confetto.angle) * distance;
      final dy =
          math.sin(confetto.angle) * distance +
          160 * progress * progress; // grawitacja
      final position = center + Offset(dx, dy);

      final paint = Paint()..color = confetto.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(confetto.rotationSpeed * progress * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: confetto.size,
            height: confetto.size * 0.6,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.confetti != confetti;
}

/// Przycina klapkę koperty w kształt rombu z lekko zaokrąglonym wierzchołkiem
/// (bezier zamiast ostrych linii) — bliżej realnego kształtu koperty niż
/// pierwotny ostry trójkąt.
class _EnvelopeFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.9,
        size.width * 0.5,
        size.height,
      )
      ..quadraticBezierTo(size.width * 0.48, size.height * 0.9, 0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
