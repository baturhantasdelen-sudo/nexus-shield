import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum NexusLogoVariant {
  /// Shield + NEXUS SHIELD + AI • API • SEC
  lockup,

  /// Shield emblem only — square asset, no crop.
  emblem,
}

/// Snaps logical size to the physical pixel grid (reduces blur from fractional layout).
double snapToDevicePixel(double logical, double devicePixelRatio) {
  if (logical <= 0 || devicePixelRatio <= 0) {
    return logical;
  }
  return (logical * devicePixelRatio).round() / devicePixelRatio;
}

/// Transparent brand assets with fixed, pixel-aligned layout boxes.
class NexusLogo extends StatelessWidget {
  const NexusLogo({
    super.key,
    this.size = 40,
    this.maxWidth,
    this.variant = NexusLogoVariant.lockup,
    this.showFallbackIcon = true,
  });

  /// Nominal lockup height on a 390pt shortest-side reference.
  final double size;
  final double? maxWidth;
  final NexusLogoVariant variant;
  final bool showFallbackIcon;

  /// Must match exported `nexus_logo.png` (see `tool/process_nexus_logo.py`).
  static const lockupAspect = 1024 / 775;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;
    final shortest = media.size.shortestSide;
    final widthCap = maxWidth ?? media.size.width * 0.92;

    if (variant == NexusLogoVariant.emblem) {
      final rawSide = size * (shortest / 390.0).clamp(0.85, 1.25);
      final side = snapToDevicePixel(
        math.min(rawSide, widthCap).clamp(24.0, 128.0),
        dpr,
      );
      return _LogoFrame(
        width: side,
        height: side,
        child: _LogoImage(
          asset: NexusBrand.emblemAsset,
          width: side,
          height: side,
          devicePixelRatio: dpr,
          showFallbackIcon: showFallbackIcon,
        ),
      );
    }

    final scaledHeight = size * (shortest / 390.0).clamp(0.72, 1.4);
    var height = snapToDevicePixel(scaledHeight, dpr);
    var width = snapToDevicePixel(height * lockupAspect, dpr);

    if (width > widthCap) {
      width = snapToDevicePixel(widthCap, dpr);
      height = snapToDevicePixel(width / lockupAspect, dpr);
    }

    return _LogoFrame(
      width: width,
      height: height,
      child: _LogoImage(
        asset: NexusBrand.logoAsset,
        width: width,
        height: height,
        devicePixelRatio: dpr,
        showFallbackIcon: showFallbackIcon,
      ),
    );
  }
}

/// Centered emblem for the protection score ring — fixed square, pixel-snapped.
class NexusRingEmblem extends StatelessWidget {
  const NexusRingEmblem({
    super.key,
    required this.ringDiameter,
    this.busy = false,
    this.busyColor,
  });

  final double ringDiameter;
  final bool busy;
  final Color? busyColor;

  /// Share of ring diameter used for the emblem box.
  static const emblemScale = 0.22;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final side = snapToDevicePixel(
      (ringDiameter * emblemScale).clamp(40.0, 56.0),
      dpr,
    );

    return _LogoFrame(
      width: side,
      height: side,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _LogoImage(
            asset: NexusBrand.emblemAsset,
            width: side,
            height: side,
            devicePixelRatio: dpr,
            showFallbackIcon: false,
          ),
          if (busy)
            SizedBox(
              width: side,
              height: side,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: (busyColor ?? NexusBrand.cyberCyan).withValues(alpha: 0.88),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogoFrame extends StatelessWidget {
  const _LogoFrame({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(child: child),
    );
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({
    required this.asset,
    required this.width,
    required this.height,
    required this.devicePixelRatio,
    required this.showFallbackIcon,
  });

  final String asset;
  final double width;
  final double height;
  final double devicePixelRatio;
  final bool showFallbackIcon;

  @override
  Widget build(BuildContext context) {
    final cacheW = (width * devicePixelRatio).round().clamp(1, 4096);
    final cacheH = (height * devicePixelRatio).round().clamp(1, 4096);

    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
      cacheWidth: cacheW,
      cacheHeight: cacheH,
      errorBuilder: (context, error, stackTrace) {
        if (!showFallbackIcon) {
          return SizedBox(width: width, height: height);
        }
        return Icon(
          Icons.shield,
          size: snapToDevicePixel(height * 0.82, devicePixelRatio),
          color: Colors.white70,
        );
      },
    );
  }
}
