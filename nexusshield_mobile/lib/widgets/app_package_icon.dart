import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../domain/models/app_permission_report.dart';
import '../theme/app_theme.dart';

class AppPackageIcon extends StatelessWidget {
  const AppPackageIcon({super.key, required this.report, this.size = 40});

  final AppPermissionReport report;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = _decode(report.iconPngBase64);
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: NexusBrand.surfaceElevated,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: NexusBrand.tealAccent.withValues(alpha: 0.2)),
      ),
      child: Icon(Icons.apps_rounded, size: size * 0.5, color: NexusBrand.muted),
    );
  }

  Uint8List? _decode(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }
}
