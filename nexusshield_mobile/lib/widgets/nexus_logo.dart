import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum NexusLogoVariant {
  /// Full lockup PNG (shield + wordmark + tagline).
  lockup,

  /// Shield emblem PNG only.
  emblem,
}

/// Frozen intrinsic pixel sizes of bundled PNGs — do not alter assets programmatically.
abstract final class NexusLogoIntrinsic {
  static const lockupWidthPx = 1024;
  static const lockupHeightPx = 888;
  static const emblemWidthPx = 1024;
  static const emblemHeightPx = 1024;

  static const lockupAspect = lockupWidthPx / lockupHeightPx;
  static const emblemAspect = emblemWidthPx / emblemHeightPx;
}

/// Snaps logical layout size to the device pixel grid (layout only; asset bytes unchanged).
double snapToDevicePixel(double logical, double devicePixelRatio) {
  if (logical <= 0 || devicePixelRatio <= 0) {
    return logical;
  }
  return (logical * devicePixelRatio).round() / devicePixelRatio;
}

/// Displays committed PNG brand assets at a fixed aspect ratio — no runtime image processing.
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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;
    final shortest = media.size.shortestSide;
    final widthCap = maxWidth ?? media.size.width * 0.92;

    if (variant == NexusLogoVariant.emblem) {
      final box = _emblemBox(
        designSize: size,
        shortestSide: shortest,
        maxWidth: widthCap,
        dpr: dpr,
      );
      return _LogoFrame(
        width: box.width,
        height: box.height,
        child: _LogoImage(
          asset: NexusBrand.logoEmblemAsset,
          width: box.width,
          height: box.height,
          showFallbackIcon: showFallbackIcon,
        ),
      );
    }

    final box = _lockupBox(
      designHeight: size,
      shortestSide: shortest,
      maxWidth: widthCap,
      dpr: dpr,
    );
    return _LogoFrame(
      width: box.width,
      height: box.height,
      child: _LogoImage(
        asset: NexusBrand.logoLockupAsset,
        width: box.width,
        height: box.height,
        showFallbackIcon: showFallbackIcon,
      ),
    );
  }

  static Size _lockupBox({
    required double designHeight,
    required double shortestSide,
    required double maxWidth,
    required double dpr,
  }) {
    final scaledHeight =
        designHeight * (shortestSide / 390.0).clamp(0.72, 1.4);
    var height = snapToDevicePixel(scaledHeight, dpr);
    var width = snapToDevicePixel(height * NexusLogoIntrinsic.lockupAspect, dpr);

    if (width > maxWidth) {
      width = snapToDevicePixel(maxWidth, dpr);
      height =
          snapToDevicePixel(width / NexusLogoIntrinsic.lockupAspect, dpr);
    }

    return Size(width, height);
  }

  static Size _emblemBox({
    required double designSize,
    required double shortestSide,
    required double maxWidth,
    required double dpr,
  }) {
    final raw = designSize * (shortestSide / 390.0).clamp(0.85, 1.25);
    var width = snapToDevicePixel(
      math.min(raw, maxWidth).clamp(24.0, 128.0),
      dpr,
    );
    var height =
        snapToDevicePixel(width / NexusLogoIntrinsic.emblemAspect, dpr);
    return Size(width, height);
  }
}

/// Centered emblem inside the protection score ring.
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
    final width = snapToDevicePixel(
      (ringDiameter * emblemScale).clamp(40.0, 56.0),
      dpr,
    );
    final height =
        snapToDevicePixel(width / NexusLogoIntrinsic.emblemAspect, dpr);

    return _LogoFrame(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _LogoImage(
            asset: NexusBrand.logoEmblemAsset,
            width: width,
            height: height,
            showFallbackIcon: false,
          ),
          if (busy)
            SizedBox(
              width: width,
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

class _LogoImage extends StatelessWidget {
  const _LogoImage({
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
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
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
