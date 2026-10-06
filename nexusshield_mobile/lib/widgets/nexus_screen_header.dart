import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'nexus_logo.dart';

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
    final maxLogoWidth = MediaQuery.sizeOf(context).width - 48;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NexusLogo(size: 52, maxWidth: maxLogoWidth.clamp(160.0, 420.0)),
        const SizedBox(height: 10),
        const _BrandTagline(),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
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
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFE2E8F0),
          NexusBrand.cyberCyan,
          NexusBrand.neonGreen,
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(bounds),
      child: Text(
        NexusBrand.brandTagline,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              height: 1.25,
            ),
      ),
    );
  }
}
