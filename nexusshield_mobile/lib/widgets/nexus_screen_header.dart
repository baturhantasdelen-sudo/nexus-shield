import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dashboard header — text-only brand hierarchy (logo only on native splash / app icon).
class NexusScreenHeader extends StatelessWidget {
  const NexusScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBrandTagline = true,
  });

  final String title;
  final String? subtitle;
  final bool showBrandTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBrandTagline) ...[
          const _BrandTagline(),
          const SizedBox(height: 10),
        ],
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: NexusBrand.metallicLight,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                height: 1.2,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: NexusBrand.muted.withValues(alpha: 0.95),
              height: 1.35,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

class _BrandTagline extends StatelessWidget {
  const _BrandTagline();

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.65,
          height: 1.15,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Flexible(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFF1F5F9),
                  NexusBrand.cyberCyan,
                  NexusBrand.neonGreen,
                ],
                stops: [0.0, 0.52, 1.0],
              ).createShader(bounds),
              child: Text(
                'Personal Guard',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: baseStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
