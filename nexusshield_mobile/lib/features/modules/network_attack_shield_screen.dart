import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/nexus_navigation.dart';
import '../../theme/app_theme.dart';
import '../defense/advanced_threat_defense_provider.dart';
import '../defense/system_integrity_provider.dart';
import '../network/wifi_security_provider.dart';
import '../traffic_guard/traffic_guard_setup_sheet.dart';
import '../traffic_guard/traffic_guard_provider.dart';

class NetworkAttackShieldScreen extends ConsumerWidget {
  const NetworkAttackShieldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defense = ref.watch(advancedThreatDefenseProvider);
    final integrity = ref.watch(systemIntegrityProvider);
    final wifi = ref.watch(wifiSecurityProvider);
    final profile = defense.profile;

    return NexusSubScreenScaffold(
      title: 'Ağ & Siber Saldırı Kalkanı',
      subtitle: 'ARP • DNS • SSL strip • C2 imzaları',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CyberCard(
            borderColor: NexusBrand.cyberCyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aktif ağ profili', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _row('SSID', '${profile['ssid'] ?? wifi.ssid}'),
                _row('Şifreleme', '${profile['encryption'] ?? wifi.encryption.label}'),
                _row('DNS hijack', _flag(profile['dnsHijackSuspect'] == true)),
                _row('ARP spoof', _flag(profile['arpPoisonSuspect'] == true)),
                _row('Captive portal', _flag(profile['captivePortalSuspect'] == true)),
                Text(
                  '${profile['detail'] ?? wifi.detail}',
                  style: const TextStyle(fontSize: 12, color: NexusBrand.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(advancedThreatDefenseProvider.notifier).refresh();
              if (defense.vpnForced || profile['recommendVpnTunnel'] == true) {
                await ref.read(trafficGuardProvider.notifier).ensureStarted();
              }
            },
            icon: const Icon(Icons.radar),
            label: const Text('Ağı yeniden tara ve tehditleri blokla'),
          ),
          if (ref.watch(trafficGuardProvider).needsVpnConsent)
            TextButton(
              onPressed: () => showTrafficGuardSetupSheet(context),
              child: const Text('DNS zırhı / VPN kurulumu'),
            ),
          const SizedBox(height: 16),
          CyberCard(
            borderColor: NexusBrand.amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'iOS Yüksek Güvenlik / Kilit Modu',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(integrity.detail, style: const TextStyle(color: NexusBrand.muted)),
                const SizedBox(height: 10),
                const Text(
                  '1. Ayarlar → Gizlilik → Kilit Modu\n'
                  '2. Mesaj eklerini kısıtla\n'
                  '3. NexusShield DNS zırhını etkinleştir',
                  style: TextStyle(fontSize: 12, height: 1.45),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => ref.read(trafficGuardProvider.notifier).ensureStarted(),
                  icon: const Icon(Icons.dns_outlined),
                  label: const Text('Otomatik DNS zırhını etkinleştir'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Engellenen tehdit imzaları: ${defense.blockedCount}',
            style: const TextStyle(color: NexusBrand.neonGreen, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  String _flag(bool bad) => bad ? 'ŞÜPHELİ' : 'Temiz';

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(k, style: const TextStyle(color: NexusBrand.muted))),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
