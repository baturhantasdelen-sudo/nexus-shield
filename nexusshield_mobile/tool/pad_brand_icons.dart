// Generates launcher/splash PNGs with ~18% safe padding (82% emblem scale).
// Run from nexusshield_mobile/: dart run tool/pad_brand_icons.dart
// ignore_for_file: avoid_print, dangling_library_doc_comments

import 'dart:io';

import 'package:image/image.dart' as img;

const _scale = 0.82;
Future<void> main() async {
  final root = Directory.current;
  if (!File('${root.path}/pubspec.yaml').existsSync()) {
    stderr.writeln('Run from nexusshield_mobile/');
    exit(1);
  }
  final iconDir = Directory('${root.path}/assets/icon');
  await _padTransparent(
    src: File('${iconDir.path}/nexus_emblem.png'),
    dst: File('${iconDir.path}/nexus_emblem_launcher.png'),
    size: 1024,
    fillBackground: false,
  );
  await _padTransparent(
    src: File('${iconDir.path}/nexus_logo.png'),
    dst: File('${iconDir.path}/nexus_logo_splash.png'),
    size: 1024,
    fillBackground: false,
  );
  await _padTransparent(
    src: File('${iconDir.path}/nexus_emblem.png'),
    dst: File('${iconDir.path}/nexus_emblem_splash.png'),
    size: 1024,
    fillBackground: true,
  );
  print('Padded assets written under assets/icon/');
}

Future<void> _padTransparent({
  required File src,
  required File dst,
  required int size,
  required bool fillBackground,
}) async {
  final bytes = await src.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('Could not decode ${src.path}');
  }
  final canvas = img.Image(width: size, height: size);
  if (fillBackground) {
    img.fill(canvas, color: img.ColorRgb8(11, 19, 43));
  }
  final aspect = decoded.width / decoded.height;
  var targetW = (size * _scale).round();
  var targetH = (targetW / aspect).round();
  if (targetH > size * _scale) {
    targetH = (size * _scale).round();
    targetW = (targetH * aspect).round();
  }
  final resized = img.copyResize(
    decoded,
    width: targetW,
    height: targetH,
    interpolation: img.Interpolation.average,
  );
  img.compositeImage(
    canvas,
    resized,
    dstX: (size - targetW) ~/ 2,
    dstY: (size - targetH) ~/ 2,
  );
  await dst.writeAsBytes(img.encodePng(canvas));
}
