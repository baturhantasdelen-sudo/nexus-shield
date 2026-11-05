import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation/nexus_navigation.dart';
import '../theme/app_theme.dart';

/// 40×40 cam efektli vektörel geri dönüş — yalnızca ikon, metin yok.
class NexusVectorBackButton extends StatelessWidget {
  const NexusVectorBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Center(
        child: Material(
          color: NexusBrand.glassPanel.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: NexusBrand.tealAccent.withValues(alpha: 0.35),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onPressed != null) {
                onPressed!();
              } else {
                popNexusRoute(context);
              }
            },
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: NexusBrand.tealAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
