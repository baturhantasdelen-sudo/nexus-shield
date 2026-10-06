import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'nexus_logo.dart';

/// Top-of-dashboard brand zone — prominent lockup + Personal Guard.
class NexusBrandWelcome extends StatelessWidget {
  const NexusBrandWelcome({super.key});

  /// Nominal lockup height (390pt reference) — slightly larger than inline headers.
  static const _logoDesignHeight = 70.0;
  static const _maxLogoWidth = 336.0;
  static const _horizontalInset = 20.0;

  @override
  Widget build(BuildContext context) {
    final widthBudget = MediaQuery.sizeOf(context).width - _horizontalInset * 2;
    final maxWidth = widthBudget.clamp(200.0, _maxLogoWidth);

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProminentLockupGlow(
            maxWidth: maxWidth,
            child: NexusLogo(
              size: _logoDesignHeight,
              maxWidth: maxWidth,
              vibrantOnDark: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Personal Guard',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: NexusBrand.metallicLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}

/// Soft teal bloom so the lockup reads clearly on deep navy without altering the PNG.
class _ProminentLockupGlow extends StatelessWidget {
  const _ProminentLockupGlow({
    required this.child,
    required this.maxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: maxWidth * 0.92,
          height: NexusBrandWelcome._logoDesignHeight * 1.15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.85,
              colors: [
                NexusBrand.tealAccent.withValues(alpha: 0.14),
                NexusBrand.cyberCyan.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: NexusBrand.tealAccent.withValues(alpha: 0.2),
                blurRadius: 22,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: NexusBrand.cyberCyan.withValues(alpha: 0.1),
                blurRadius: 36,
                spreadRadius: -6,
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}
