import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Text-only screen header — brand lockup lives on the dashboard banner.
class NexusScreenHeader extends StatelessWidget {
  const NexusScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrandTagline(),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.15,
                height: 1.2,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: NexusBrand.muted,
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
                NexusBrand.brandTagline,
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
