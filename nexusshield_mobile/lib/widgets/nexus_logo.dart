import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum NexusLogoVariant {
  /// Shield + NEXUS SHIELD + AI • API • SEC
  lockup,

  /// Shield emblem only — for circular controls.
  emblem,
}

/// Transparent lockup scaled to the device shortest side.
class NexusLogo extends StatelessWidget {
  const NexusLogo({
    super.key,
    this.size = 40,
    this.maxWidth,
    this.variant = NexusLogoVariant.lockup,
    this.showFallbackIcon = true,
  });

  /// Design height at a 390pt shortest side.
  final double size;
  final double? maxWidth;
  final NexusLogoVariant variant;
  final bool showFallbackIcon;

  /// Must match exported `nexus_logo.png` width / height (regenerate via tool/process_nexus_logo.py).
  static const lockupAspect = 1024 / 775;

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final height = (size * (shortest / 390.0)).clamp(size * 0.72, size * 1.4);
    final cap = maxWidth ?? MediaQuery.sizeOf(context).width * 0.92;

    final dpr = MediaQuery.devicePixelRatioOf(context);

    if (variant == NexusLogoVariant.emblem) {
      final side = height.clamp(24.0, cap);
      return _asset(
        asset: NexusBrand.emblemAsset,
        width: side,
        height: side,
        dpr: dpr,
      );
    }

    var width = height * lockupAspect;
    if (width > cap) {
      width = cap;
    }
    final resolvedHeight = width / lockupAspect;
    return _asset(
      asset: NexusBrand.logoAsset,
      width: width,
      height: resolvedHeight,
      dpr: dpr,
    );
  }

  Widget _asset({
    required String asset,
    required double width,
    required double height,
    required double dpr,
  }) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
      cacheWidth: (width * dpr).round().clamp(1, 4096),
      cacheHeight: (height * dpr).round().clamp(1, 4096),
      errorBuilder: (context, error, stackTrace) {
        if (!showFallbackIcon) {
          return SizedBox(width: width, height: height);
        }
        return Icon(
          Icons.shield,
          size: height * 0.85,
          color: Colors.white70,
        );
      },
    );
  }
}
