import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/security/security_alert_provider.dart';
import '../features/traffic_guard/social_tracking_catalog.dart';
import '../features/traffic_guard/traffic_guard_provider.dart';
import '../theme/app_theme.dart';

/// Floating badge when social / AI behavioral tracking is detected.
class TrackingAlertBadge extends ConsumerWidget {
  const TrackingAlertBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traffic = ref.watch(trafficGuardProvider);
    final alerts = ref.watch(securityAlertProvider);
    SecurityAlert? aiAlert;
    for (final a in alerts) {
      if (a.kind == SecurityAlertKind.ai) {
        aiAlert = a;
        break;
      }
    }

    final label = traffic.foregroundLabel;
    final showSocial = label != null && traffic.active;
    if (!showSocial && aiAlert == null) return const SizedBox.shrink();

    final text = aiAlert?.body ??
        'Şu an $label üzerinden yapay zeka tabanlı davranışsal yönlendirme/takip algılandı';

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: NexusBrand.deepNavy.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: NexusBrand.cyberCyan.withValues(alpha: 0.55),
                ),
                boxShadow: [
                  BoxShadow(
                    color: NexusBrand.cyberCyan.withValues(alpha: 0.15),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_outlined,
                      color: NexusBrand.cyberCyan, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ),
                  if (label != null)
                    Text(
                      SocialTrackingCatalog.trackingDomains.first
                          .split('.')
                          .first,
                      style: const TextStyle(
                        color: NexusBrand.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
