import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/nexus_navigation.dart';
import '../../theme/app_theme.dart';
import '../apps_control/apps_permissions_hub_screen.dart';
import '../banking/banking_active_armor_panel.dart';
import '../bridge/app_catalog.dart';
import '../bridge/app_protection_bridge_provider.dart';
import '../messenger/messenger_guard_panel.dart';

class AppBridgeModuleScreen extends ConsumerWidget {
  const AppBridgeModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.watch(appProtectionBridgeProvider);
    final grouped = <AppCriticalityClass, List<BridgeCandidate>>{};
    for (final c in bridge.candidates) {
      grouped.putIfAbsent(c.criticality, () => []).add(c);
    }

    return NexusSubScreenScaffold(
      title: 'Otonom Uygulama Köprüsü',
      subtitle: 'WhatsApp • Banka • Sosyal',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FilledButton.icon(
            onPressed: () => ref.read(appProtectionBridgeProvider.notifier).syncFromDevice(),
            icon: const Icon(Icons.sync),
            label: const Text('Uygulamaları yeniden tara'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => pushNexusSubRoute(
              context,
              const AppsPermissionsHubScreen(),
            ),
            icon: const Icon(Icons.tune),
            label: const Text('İzin & DLP merkezi'),
          ),
          const SizedBox(height: 16),
          const BankingActiveArmorPanel(),
          const SizedBox(height: 12),
          const MessengerGuardPanel(),
          const SizedBox(height: 16),
          for (final cls in AppCriticalityClass.values)
            if (cls != AppCriticalityClass.other && (grouped[cls]?.isNotEmpty ?? false)) ...[
              Text(cls.labelTr, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...grouped[cls]!.map((c) => _BridgeTile(candidate: c)),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _BridgeTile extends ConsumerWidget {
  const _BridgeTile({required this.candidate});

  final BridgeCandidate candidate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CyberCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(candidate.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  candidate.packageId,
                  style: const TextStyle(fontSize: 10, color: NexusBrand.muted),
                ),
              ],
            ),
          ),
          if (candidate.bridged)
            const Chip(
              label: Text('Köprü Aktif • Korunuyor'),
              backgroundColor: Color(0x221AEE8A),
              labelStyle: TextStyle(color: NexusBrand.neonGreen, fontSize: 11),
            )
          else
            TextButton(
              onPressed: () =>
                  ref.read(appProtectionBridgeProvider.notifier).enableBridge(candidate),
              child: const Text('Köprü Kur'),
            ),
        ],
      ),
      ),
    );
  }
}
