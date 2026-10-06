import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'nexus_logo.dart';

/// Top-of-dashboard brand zone — lockup + Personal Guard, no banner chrome.
class NexusBrandWelcome extends StatelessWidget {
  const NexusBrandWelcome({super.key});

  static const _logoHeight = 56.0;
  static const _maxLogoWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    final maxWidth = (MediaQuery.sizeOf(context).width - 40).clamp(180.0, _maxLogoWidth);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      child: Column(
        children: [
          NexusLogo(
            size: _logoHeight,
            maxWidth: maxWidth,
          ),
          const SizedBox(height: 10),
          Text(
            'Personal Guard',
            textAlign: TextAlign.center,
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
