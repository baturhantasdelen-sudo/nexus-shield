import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/nexus_navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_package_icon.dart';
import '../apps_control/apps_permissions_hub_screen.dart';
import '../banking/banking_active_armor_panel.dart';
import '../bridge/app_protection_bridge_provider.dart';
import '../messenger/messenger_guard_panel.dart';
import '../permissions/permission_scan_provider.dart';
import '../proof/how_it_protects_proof_sheet.dart';

class AppBridgeModuleScreen extends ConsumerStatefulWidget {
  const AppBridgeModuleScreen({super.key});

  @override
  ConsumerState<AppBridgeModuleScreen> createState() => _AppBridgeModuleScreenState();
}

class _AppBridgeModuleScreenState extends ConsumerState<AppBridgeModuleScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final bridge = ref.watch(appProtectionBridgeProvider);
    final scan = ref.watch(permissionScanProvider);
    final filtered = bridge.entries.where((e) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return e.report.displayName.toLowerCase().contains(q) ||
          e.report.packageId.toLowerCase().contains(q);
    }).toList();

    return NexusSubScreenScaffold(
      title: 'Otonom Uygulama Köprüsü',
      subtitle: '${bridge.entries.length} paket • ${scan.includeSystemPackages ? 'tüm paketler' : 'kullanıcı uygulamaları'}',
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sistem servislerini de göster (tüm paketler)'),
                  subtitle: const Text('Gizli sistem paketleri dahil eksiksiz envanter'),
                  value: scan.includeSystemPackages,
                  onChanged: scan.scanning
                      ? null
                      : (v) async {
                          await ref.read(permissionScanProvider.notifier).scan(
                                includeSystemPackages: v,
                              );
                          await ref.read(appProtectionBridgeProvider.notifier).syncFromDevice();
                        },
                ),
                FilledButton.icon(
                  onPressed: bridge.bridgingAll
                      ? null
                      : () => ref.read(appProtectionBridgeProvider.notifier).bridgeAllLaunchable(),
                  icon: bridge.bridgingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.hub),
                  label: Text(
                    'Bulunan tüm uygulamaları köprüle ve koru (${bridge.unbridgedLaunchableCount} uygulama)',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showManualBridgeDialog(context),
                  icon: const Icon(Icons.add_link),
                  label: const Text('Kalkan köprüsüne dahil et (manuel / iOS)'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => showHowItProtectsProofSheet(context),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Nasıl koruyor? (canlı kanıt)'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await ref.read(appProtectionBridgeProvider.notifier).syncFromDevice();
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Uygulamaları yeniden tara'),
                ),
                TextButton.icon(
                  onPressed: () => pushNexusSubRoute(context, const AppsPermissionsHubScreen()),
                  icon: const Icon(Icons.tune),
                  label: const Text('İzin & DLP merkezi'),
                ),
                const SizedBox(height: 12),
                const BankingActiveArmorPanel(),
                const SizedBox(height: 12),
                const MessengerGuardPanel(),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Uygulama ara…',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
                Text(
                  'Yüklü uygulamalar (${filtered.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...filtered.map((e) => _BridgeTile(entry: e)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualBridgeDialog(BuildContext context) async {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexusBrand.glassPanel,
        title: const Text('Manuel köprü'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Görünen ad'),
            ),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(
                labelText: 'Paket / Bundle ID',
                hintText: 'com.example.app veya tr.gov.edevlet',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Köprüle')),
        ],
      ),
    );
    if (ok == true && idCtrl.text.trim().isNotEmpty && mounted) {
      await ref.read(appProtectionBridgeProvider.notifier).addManualBridgeTarget(
            idCtrl.text.trim(),
            nameCtrl.text.trim().isEmpty ? idCtrl.text.trim() : nameCtrl.text.trim(),
          );
    }
    idCtrl.dispose();
    nameCtrl.dispose();
  }
}

class _BridgeTile extends ConsumerWidget {
  const _BridgeTile({required this.entry});

  final BridgeEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = entry.report;
    final rules = r.bridgeRuleLabelsTr;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CyberCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppPackageIcon(report: r, size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        r.packageId,
                        style: const TextStyle(fontSize: 10, color: NexusBrand.muted),
                      ),
                      if (r.versionName.isNotEmpty)
                        Text(
                          'v${r.versionName}',
                          style: const TextStyle(fontSize: 10, color: NexusBrand.muted),
                        ),
                    ],
                  ),
                ),
                if (r.bridged)
                  const Chip(
                    label: Text('Köprü Aktif • Korunuyor'),
                    labelStyle: TextStyle(fontSize: 10, color: NexusBrand.neonGreen),
                  )
                else
                  TextButton(
                    onPressed: () =>
                        ref.read(appProtectionBridgeProvider.notifier).enableBridge(entry),
                    child: const Text('Köprü Kur'),
                  ),
              ],
            ),
            if (rules.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final rule in rules)
                Text('• $rule', style: const TextStyle(fontSize: 11, color: NexusBrand.neonGreen)),
            ],
          ],
        ),
      ),
    );
  }
}
