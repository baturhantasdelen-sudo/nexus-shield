import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../live_shield/privacy_pillars_provider.dart';
import '../traffic_guard/traffic_guard_provider.dart';

/// WhatsApp / mesajlaşma DNS sinkhole ve arka plan mikrofon uyarısı.
class MessengerGuardPanel extends ConsumerWidget {
  const MessengerGuardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pillars = ref.watch(privacyPillarsProvider);
    final vpn = ref.watch(trafficGuardProvider).active;
    final messagingRisk = pillars.messagingDetail.contains('bindirme') ||
        pillars.messagingDetail.contains('oltalama');

    return CyberCard(
      borderColor: messagingRisk ? NexusBrand.amber : NexusBrand.cyberCyan,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.chat, color: NexusBrand.cyberCyan),
              SizedBox(width: 8),
              Text('WhatsApp & İletişim Kalkanı', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            vpn
                ? 'Oltalama domainleri ve zararlı indirme linkleri VPN/DNS katmanında engelleniyor.'
                : 'DNS kalkanı için trafik korumasını etkinleştirin.',
            style: const TextStyle(fontSize: 12, color: NexusBrand.muted, height: 1.35),
          ),
          const SizedBox(height: 8),
          Text(pillars.messagingDetail, style: const TextStyle(fontSize: 12)),
          if (pillars.callDetail.contains('mikrofon') || pillars.callDetail.contains('Mikrofon'))
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '⚠ Mikrofon/kamera anomalisi — mesajlaşma kapalıyken tetiklenme şüphesi',
                style: TextStyle(color: NexusBrand.alertRed, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
