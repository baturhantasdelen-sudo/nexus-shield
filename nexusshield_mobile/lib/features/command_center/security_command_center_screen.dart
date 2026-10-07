import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../widgets/nexus_screen_header.dart';
import '../ai_shield/ai_shield_screen.dart';
import '../apps_control/apps_permissions_hub_screen.dart';
import '../banking/banking_shield_provider.dart';
import '../permissions/permission_scan_screen.dart';
import '../traffic_guard/traffic_guard_provider.dart';
import '../traffic_guard/traffic_guard_setup_sheet.dart';
import '../vault/smart_vault_sync_provider.dart';

class SecurityCommandCenterScreen extends ConsumerWidget {
  const SecurityCommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traffic = ref.watch(trafficGuardProvider);
    final banking = ref.watch(bankingShieldProvider);
    final vaultSync = ref.watch(smartVaultSyncProvider);

    return Scaffold(
      backgroundColor: NexusBrand.deepSlate,
      appBar: AppBar(title: const Text('Security Karargahı')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const NexusScreenHeader(
            title: 'Personal Security Karargahı',
            subtitle:
                'İzinler, ağ trafiği, yapay zeka takibi, Vault ve finansal koruma — tek merkez.',
          ),
          const SizedBox(height: 16),
          _CommandTile(
            icon: Icons.apps_outlined,
            title: 'Uygulama & İzin Denetimi',
            subtitle: 'Tüm yüklü uygulamalar, risk skoru, sistem ayarları',
            accent: NexusBrand.cyberCyan,
            onTap: () => _push(context, const AppsPermissionsHubScreen()),
          ),
          _CommandTile(
            icon: Icons.travel_explore_outlined,
            title: 'Sosyal / AI Trafik Gözlemcisi',
            subtitle: traffic.active
                ? 'Guard aktif • ${traffic.foregroundLabel ?? 'Ön planda uygulama yok'}'
                : 'Yerel tünel hazır — kalkanı açın',
            accent: NexusBrand.neonGreen,
            onTap: () {
              final guard = ref.read(trafficGuardProvider.notifier);
              if (guard.needsSetup) {
                showTrafficGuardSetupSheet(context);
              } else {
                guard.refresh();
              }
            },
          ),
          _CommandTile(
            icon: Icons.key_outlined,
            title: 'Akıllı Vault Senkronu',
            subtitle:
                '${vaultSync.clients.length} AI istemcisi yüklü • kullanıcı onaylı içe aktarım',
            accent: NexusBrand.amber,
            onTap: () => ref.read(smartVaultSyncProvider.notifier).scan(),
          ),
          _CommandTile(
            icon: Icons.account_balance_outlined,
            title: 'Finansal Arka Plan Kalkanı',
            subtitle: banking.threatDetected
                ? 'Tehdit sinyali — ${banking.detail}'
                : banking.bankingAppActive
                    ? 'Bankacılık oturumu izleniyor'
                    : 'Bankacılık uygulaması kapalı',
            accent: NexusBrand.alertRed,
            onTap: () {},
          ),
          _CommandTile(
            icon: Icons.shield_outlined,
            title: 'AI Guard & Onay',
            subtitle: 'API uçları, consent, Action Firewall',
            accent: NexusBrand.cyberCyan,
            onTap: () => _push(context, const AiShieldScreen()),
          ),
          _CommandTile(
            icon: Icons.fact_check_outlined,
            title: 'Hızlı izin taraması',
            subtitle: 'Klasik risk listesi görünümü',
            accent: NexusBrand.muted,
            onTap: () => _push(context, const PermissionScanScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _CommandTile extends StatelessWidget {
  const _CommandTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CyberCard(
        borderColor: accent,
        borderOpacity: 0.35,
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: accent),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
