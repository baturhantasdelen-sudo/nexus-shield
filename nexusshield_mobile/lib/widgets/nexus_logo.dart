import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

enum NexusLogoVariant {
  /// Shield + NEXUS SHIELD + AI • API • SEC
  lockup,

  /// Shield emblem only.
  emblem,
}

/// Snaps logical layout size to the device pixel grid.
double snapToDevicePixel(double logical, double devicePixelRatio) {
  if (logical <= 0 || devicePixelRatio <= 0) {
    return logical;
  }
  return (logical * devicePixelRatio).round() / devicePixelRatio;
}

/// Vector brand assets — crisp at any density.
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

  /// Matches `assets/vector/nexus_logo.svg` viewBox (360×132).
  static const lockupAspect = 360 / 132;

  /// Matches `assets/vector/nexus_emblem.svg` viewBox (100×110).
  static const emblemAspect = 100 / 110;

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
      final height = snapToDevicePixel(side / emblemAspect, dpr);
      return _LogoFrame(
        width: side,
        height: height,
        child: _LogoVector(
          asset: NexusBrand.logoEmblemVector,
          width: side,
          height: height,
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
      child: _LogoVector(
        asset: NexusBrand.logoLockupVector,
        width: width,
        height: height,
        showFallbackIcon: showFallbackIcon,
      ),
    );
  }
}

/// Centered vector emblem inside the protection score ring.
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

  static const emblemScale = 0.22;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final side = snapToDevicePixel(
      (ringDiameter * emblemScale).clamp(40.0, 56.0),
      dpr,
    );
    final height = snapToDevicePixel(side / NexusLogo.emblemAspect, dpr);

    return _LogoFrame(
      width: side,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _LogoVector(
            asset: NexusBrand.logoEmblemVector,
            width: side,
            height: height,
            showFallbackIcon: false,
          ),
          if (busy)
            SizedBox(
              width: side,
              height: height,
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

class _LogoVector extends StatelessWidget {
  const _LogoVector({
    required this.asset,
    required this.width,
    required this.height,
    required this.showFallbackIcon,
  });

  final String asset;
  final double width;
  final double height;
  final bool showFallbackIcon;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      placeholderBuilder: (context) => SizedBox(width: width, height: height),
      errorBuilder: (context, error, stackTrace) {
        if (!showFallbackIcon) {
          return SizedBox(width: width, height: height);
        }
        return Icon(
          Icons.shield,
          size: height * 0.82,
          color: Colors.white70,
        );
      },
    );
  }
}
