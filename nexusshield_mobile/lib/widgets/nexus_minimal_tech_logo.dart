import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Vector minimal tech emblem — matches `tool/generate_minimal_tech_logo.dart`.
class NexusMinimalTechLogo extends StatefulWidget {
  const NexusMinimalTechLogo({
    super.key,
    this.size = 48,
    this.pulseWhenActive = true,
    this.active = false,
  });

  final double size;
  final bool pulseWhenActive;
  final bool active;

  @override
  State<NexusMinimalTechLogo> createState() => _NexusMinimalTechLogoState();
}

class _NexusMinimalTechLogoState extends State<NexusMinimalTechLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.active && widget.pulseWhenActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant NexusMinimalTechLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && widget.pulseWhenActive) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = widget.active ? 0.92 + _controller.value * 0.08 : 1.0;
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _MinimalTechLogoPainter(
            active: widget.active,
            pulseScale: pulse,
          ),
        );
      },
    );
  }
}

class _MinimalTechLogoPainter extends CustomPainter {
  _MinimalTechLogoPainter({required this.active, required this.pulseScale});

  final bool active;
  final double pulseScale;

  static const _teal = NexusBrand.cyberCyan;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final content = s * 0.65;
    final offset = (s - content) / 2;
    canvas.save();
    canvas.translate(offset, offset);
    canvas.scale(content / s * pulseScale, content / s * pulseScale);
    canvas.translate(s * (1 - pulseScale) / 2 / pulseScale, s * (1 - pulseScale) / 2 / pulseScale);

    final cx = s / 2;
    final cy = s / 2;
    final r = s * 0.38;
    final stroke = Paint()
      ..color = _teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.028
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final start = -math.pi / 2 + i * 2 * math.pi / 3;
      final sweep = 2 * math.pi / 3 * 0.92;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start,
        sweep,
        false,
        stroke,
      );
    }

    const nodes = 6;
    final nodeR = r * 0.72;
    final link = Paint()
      ..color = _teal.withValues(alpha: 0.55)
      ..strokeWidth = s * 0.012;
    final nodeFill = Paint()..color = _teal;
    for (var i = 0; i < nodes; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / nodes;
      final nx = cx + nodeR * math.cos(a);
      final ny = cy + nodeR * math.sin(a);
      canvas.drawLine(Offset(cx, cy), Offset(nx, ny), link);
      canvas.drawCircle(Offset(nx, ny), s * 0.045, nodeFill);
    }

    _drawHex(canvas, Offset(cx, cy), r * 0.28, s * 0.022, _teal);
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.14,
      Paint()
        ..color = _teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.018,
    );
    canvas.drawCircle(Offset(cx, cy), r * 0.08, nodeFill);

    if (active) {
      canvas.drawCircle(
        Offset(cx, cy),
        r * 0.5,
        Paint()
          ..color = _teal.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill,
      );
    }
    canvas.restore();
  }

  void _drawHex(Canvas canvas, Offset c, double r, double w, Color color) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + i * math.pi / 3;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w,
    );
  }

  @override
  bool shouldRepaint(covariant _MinimalTechLogoPainter oldDelegate) =>
      oldDelegate.active != active || oldDelegate.pulseScale != pulseScale;
}
