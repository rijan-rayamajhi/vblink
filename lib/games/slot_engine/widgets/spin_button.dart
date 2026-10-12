import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Chunky 2.5D game button drawn in code: a thick gold rim sitting on a
/// darker base, a glossy dome with a shine, and a circular-arrow icon.
/// Pressing sinks the dome into the base; while [spinning] the arrow turns.
class SpinButton extends StatefulWidget {
  const SpinButton({
    super.key,
    required this.size,
    required this.onTap,
    this.spinning = false,
    this.freeSpinsLeft = 0,
  });

  final double size;
  final VoidCallback onTap;
  final bool spinning;

  /// When > 0 the button turns gold and shows the count instead of the arrow.
  final int freeSpinsLeft;

  @override
  State<SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<SpinButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  bool _pressed = false;

  @override
  void didUpdateWidget(SpinButton old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !_turn.isAnimating) {
      _turn.repeat();
    } else if (!widget.spinning && _turn.isAnimating) {
      // Finish the current turn so the arrow always rests upright.
      _turn.forward(from: _turn.value).then((_) => _turn.value = 0);
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final free = widget.freeSpinsLeft > 0;
    final depth = s * 0.07;
    final sink = _pressed ? depth * 0.75 : 0.0;

    // Green normally, gold during free spins.
    final dome = free
        ? const [Color(0xFFFFF3B0), Color(0xFFFFC93C), Color(0xFFD98A00)]
        : const [Color(0xFFB6FF9E), Color(0xFF3FD957), Color(0xFF0E8A35)];
    final base = free ? const Color(0xFF8A4F00) : const Color(0xFF05501E);
    final glow = free ? AppColors.gold : const Color(0xFF7CFF6B);

    return Semantics(
      button: true,
      label: free ? 'Free spin' : 'Spin',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: SizedBox(
          width: s,
          height: s + depth,
          child: Stack(
            children: [
              // Shadow + thick base: the "side" of the button.
              Positioned(
                top: depth,
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFB8860B), Color(0xFF6B4200)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: glow.withValues(
                          alpha: widget.spinning ? 0.25 : 0.55,
                        ),
                        blurRadius: s * 0.18,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: s * 0.08,
                        offset: Offset(0, s * 0.05),
                      ),
                    ],
                  ),
                ),
              ),
              // Top face: slides down when pressed.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                top: sink,
                child: SizedBox(
                  width: s,
                  height: s,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Gold rim.
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Color(0xFFFFF0A0),
                              Color(0xFFE09A12),
                              Color(0xFFFFE27A),
                              Color(0xFFB8740A),
                              Color(0xFFFFF0A0),
                            ],
                          ),
                        ),
                      ),
                      // Dark groove inside the rim.
                      Container(
                        width: s * 0.84,
                        height: s * 0.84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: base,
                        ),
                      ),
                      // Glossy dome.
                      Container(
                        width: s * 0.78,
                        height: s * 0.78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.35),
                            radius: 0.85,
                            colors: dome,
                            stops: const [0, 0.5, 1],
                          ),
                        ),
                      ),
                      // Shine highlight on the upper half.
                      Positioned(
                        top: s * 0.14,
                        child: Container(
                          width: s * 0.52,
                          height: s * 0.24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(s),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.75),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (free)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('FREE', style: AppText.label(s * 0.13)),
                            Text(
                              '${widget.freeSpinsLeft}',
                              style: AppText.number(s * 0.26),
                            ),
                          ],
                        )
                      else
                        RotationTransition(
                          turns: _turn,
                          child: CustomPaint(
                            size: Size.square(s * 0.42),
                            painter: _SpinArrowsPainter(),
                          ),
                        ),
                    ],
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

/// Two curved arrows chasing each other in a circle, white with a dark edge.
class _SpinArrowsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.36;
    final stroke = size.width * 0.13;

    for (final start in [-pi * 0.95, pi * 0.05]) {
      const sweep = pi * 0.68;
      final rect = Rect.fromCircle(center: c, radius: r);
      for (final (color, width) in [
        (const Color(0xAA0B3B17), stroke + size.width * 0.06),
        (Colors.white, stroke),
      ]) {
        canvas.drawArc(
          rect,
          start,
          sweep,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round,
        );
      }
      // Arrow head at the end of the arc, pointing along the circle.
      final end = start + sweep;
      final tip = c + Offset(cos(end), sin(end)) * r;
      final dir = Offset(-sin(end), cos(end));
      final out = Offset(cos(end), sin(end));
      final h = size.width * 0.22;
      final head = Path()
        ..moveTo(tip.dx + dir.dx * h * 0.9, tip.dy + dir.dy * h * 0.9)
        ..lineTo(tip.dx + out.dx * h * 0.7, tip.dy + out.dy * h * 0.7)
        ..lineTo(tip.dx - out.dx * h * 0.7, tip.dy - out.dy * h * 0.7)
        ..close();
      canvas.drawPath(
        head,
        Paint()
          ..color = const Color(0xAA0B3B17)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.06
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(head, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
