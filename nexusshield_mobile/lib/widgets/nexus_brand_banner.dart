import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'nexus_logo.dart';

/// Centered lockup for the dashboard — corporate identity without crowding navigation.
class NexusBrandBanner extends StatelessWidget {
  const NexusBrandBanner({super.key});

  static const _horizontalPadding = 20.0;
  static const _verticalPadding = 16.0;
  static const _logoDesignHeight = 44.0;
  static const _maxLogoWidth = 280.0;

  @override
  Widget build(BuildContext context) {
    final maxWidth = (MediaQuery.sizeOf(context).width - _horizontalPadding * 2)
        .clamp(160.0, _maxLogoWidth);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CyberCard(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        borderOpacity: 0.14,
        child: Center(
          child: NexusLogo(
            size: _logoDesignHeight,
            maxWidth: maxWidth,
          ),
        ),
      ),
    );
  }
}
