import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Section title under the brand welcome — Güvenlik Panosu hierarchy.
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
