import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'nexus_logo.dart';

/// Header lockup: fixed max width with pixel-snapped logo box inside.
class NexusScreenHeader extends StatelessWidget {
  const NexusScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  static const _logoDesignSize = 52.0;
  static const _horizontalInset = 24.0;

  @override
  Widget build(BuildContext context) {
    final maxLogoWidth = (MediaQuery.sizeOf(context).width - _horizontalInset * 2)
        .clamp(160.0, 420.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NexusLogo(
          size: _logoDesignSize,
          maxWidth: maxLogoWidth,
        ),
        const SizedBox(height: 10),
        const _BrandTagline(),
        const SizedBox(height: 12),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
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
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.85,
          height: 1.2,
        );

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Flexible(
            child: ShaderMask(
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: style,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
