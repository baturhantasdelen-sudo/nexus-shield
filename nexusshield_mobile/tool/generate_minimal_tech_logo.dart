// ignore_for_file: avoid_print, dangling_library_doc_comments

// Ultra-minimal tech emblem — 35% safe zone (drawing in central 65%).
// Run: dart run tool/generate_minimal_tech_logo.dart

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _size = 1024;
const _contentFraction = 0.65;

Future<void> main() async {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln('Run from nexusshield_mobile/');
    exit(1);
  }
  final canvas = img.Image(width: _size, height: _size);
  img.fill(canvas, color: img.ColorRgb8(11, 19, 43));

  final inner = _size * _contentFraction;
  final origin = (_size - inner) / 2;
  _drawEmblem(canvas, origin, inner);

  final dir = Directory('assets/icon');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final launcher = File('assets/icon/nexus_minimal_launcher.png');
  final splash = File('assets/icon/nexus_minimal_splash.png');
  await launcher.writeAsBytes(img.encodePng(canvas));
  await splash.writeAsBytes(img.encodePng(canvas));
  print('Wrote ${launcher.path} and ${splash.path} (${_size}x$_size, 65% emblem)');
}

void _drawEmblem(img.Image canvas, double ox, double size) {
  final cx = ox + size / 2;
  final cy = ox + size / 2;
  final r = size * 0.38;
  final teal = img.ColorRgb8(94, 234, 212);
  final tealDim = img.ColorRgba8(94, 234, 212, 180);

  // Outer shield arc (3 segments)
  for (var i = 0; i < 3; i++) {
    final a0 = -math.pi / 2 + i * 2 * math.pi / 3;
    final a1 = a0 + 2 * math.pi / 3 * 0.92;
    _arc(canvas, cx, cy, r, a0, a1, teal, width: (size * 0.028).round());
  }

  // Network nodes (hex ring)
  const nodeCount = 6;
  final nodeR = r * 0.72;
  for (var i = 0; i < nodeCount; i++) {
    final a = -math.pi / 2 + i * 2 * math.pi / nodeCount;
    final nx = cx + nodeR * math.cos(a);
    final ny = cy + nodeR * math.sin(a);
    _line(canvas, cx, cy, nx, ny, tealDim, width: (size * 0.012).round());
    _fillCircle(canvas, nx, ny, size * 0.045, teal);
  }

  // Cryptographic core (hex + inner pulse ring)
  _drawHex(canvas, cx, cy, r * 0.28, teal, stroke: (size * 0.022).round());
  _circleStroke(canvas, cx, cy, r * 0.14, teal, width: (size * 0.018).round());
  _fillCircle(canvas, cx, cy, r * 0.08, teal);
}

void _arc(
  img.Image img,
  double cx,
  double cy,
  double r,
  double a0,
  double a1,
  img.Color color, {
  required int width,
}) {
  const steps = 48;
  for (var s = 0; s <= steps; s++) {
    final t = a0 + (a1 - a0) * s / steps;
    final x = cx + r * math.cos(t);
    final y = cy + r * math.sin(t);
    _fillCircle(img, x, y, width / 2.0, color);
  }
}

void _line(
  img.Image img,
  double x0,
  double y0,
  double x1,
  double y1,
  img.Color color, {
  required int width,
}) {
  final dx = x1 - x0;
  final dy = y1 - y0;
  final len = math.sqrt(dx * dx + dy * dy);
  final steps = len.ceil().clamp(1, 512);
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    _fillCircle(img, x0 + dx * t, y0 + dy * t, width / 2.0, color);
  }
}

void _fillCircle(img.Image canvas, double cx, double cy, double radius, img.Color c) {
  img.fillCircle(
    canvas,
    x: cx.round(),
    y: cy.round(),
    radius: radius.round(),
    color: c,
  );
}

void _circleStroke(
  img.Image img,
  double cx,
  double cy,
  double radius,
  img.Color c, {
  required int width,
}) {
  const steps = 64;
  for (var i = 0; i < steps; i++) {
    final a = i * 2 * math.pi / steps;
    _fillCircle(
      img,
      cx + radius * math.cos(a),
      cy + radius * math.sin(a),
      width / 2.0,
      c,
    );
  }
}

void _drawHex(
  img.Image img,
  double cx,
  double cy,
  double r,
  img.Color c, {
  required int stroke,
}) {
  for (var i = 0; i < 6; i++) {
    final a0 = -math.pi / 2 + i * math.pi / 3;
    final a1 = a0 + math.pi / 3;
    final x0 = cx + r * math.cos(a0);
    final y0 = cy + r * math.sin(a0);
    final x1 = cx + r * math.cos(a1);
    final y1 = cy + r * math.sin(a1);
    _line(img, x0, y0, x1, y1, c, width: stroke);
  }
}
