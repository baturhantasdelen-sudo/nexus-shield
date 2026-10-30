import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_permission_report.dart';
import '../../theme/app_theme.dart';
import '../../navigation/nexus_navigation.dart';
import '../../widgets/nexus_screen_header.dart';
import '../permissions/permission_scan_provider.dart';
import 'apps_control_provider.dart';

enum _AppsFilter { risky, all }

class AppsPermissionsHubScreen extends ConsumerStatefulWidget {
  const AppsPermissionsHubScreen({super.key});

  @override
  ConsumerState<AppsPermissionsHubScreen> createState() =>
      _AppsPermissionsHubScreenState();
}

class _AppsPermissionsHubScreenState
    extends ConsumerState<AppsPermissionsHubScreen> {
  _AppsFilter _filter = _AppsFilter.risky;

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(permissionScanProvider);
    final list = switch (_filter) {
      _AppsFilter.risky => scan.risky,
      _AppsFilter.all => scan.reports,
    };

    return NexusSubScreenScaffold(
      title: 'Uygulama & İzin Merkezi',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const NexusScreenHeader(
            title: 'İzin denetim karargahı',
            subtitle:
                'Yüklü uygulamalar, kritik izinler ve ağ izolasyonu — tam kullanıcı kontrolü.',
          ),
          const SizedBox(height: 12),
          SegmentedButton<_AppsFilter>(
            segments: const [
              ButtonSegment(
                value: _AppsFilter.risky,
                label: Text('Riskli'),
                icon: Icon(Icons.warning_amber_outlined, size: 18),
              ),
              ButtonSegment(
                value: _AppsFilter.all,
                label: Text('Tümü'),
                icon: Icon(Icons.apps_outlined, size: 18),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (s) => setState(() => _filter = s.first),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: scan.scanning
                ? null
                : () => ref.read(permissionScanProvider.notifier).scan(),
            icon: scan.scanning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(scan.scanning ? 'Taranıyor…' : 'Cihazı tara'),
          ),
          const SizedBox(height: 12),
          Text(
            'Kayıt: ${list.length} • Son tarama: ${scan.lastScan?.toLocal().toString().split('.').first ?? '—'}',
            style: const TextStyle(color: NexusBrand.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...list.map((r) => _AppControlCard(report: r)),
          if (list.isEmpty && !scan.scanning)
            const CyberCard(
              padding: EdgeInsets.all(16),
              child: Text(
                'Bu filtrede uygulama bulunamadı.',
                style: TextStyle(color: NexusBrand.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppControlCard extends ConsumerWidget {
  const _AppControlCard({required this.report});

  final AppPermissionReport report;

  Color get _accent => switch (report.riskTier) {
        AppPermissionRiskTier.high => NexusBrand.alertRed,
        AppPermissionRiskTier.medium => NexusBrand.amber,
        AppPermissionRiskTier.low => NexusBrand.neonGreen,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final control = ref.read(appsControlProvider.notifier);
    final permLabels =
        report.permissions.map((p) => p.labelTr).join(' • ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CyberCard(
        borderColor: _accent,
        borderOpacity: 0.35,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        report.packageId,
                        style: const TextStyle(
                          color: NexusBrand.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _RiskChip(score: report.riskScore, color: _accent),
              ],
            ),
            const SizedBox(height: 8),
            Text(permLabels, style: TextStyle(color: _accent, fontSize: 13)),
            if (report.networkBlocked)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Ağ izolasyonu politikası etkin',
                  style: TextStyle(color: NexusBrand.cyberCyan, fontSize: 12),
                ),
              ),
            const SizedBox(height: 10),
            _DlpSwitch(
              label: 'Veri çıkışını kes',
              value: report.dlp.outboundBlocked,
              onChanged: (v) => control.setDlp(
                packageId: report.packageId,
                displayName: report.displayName,
                outboundBlocked: v,
                clipboardBlocked: report.dlp.clipboardBlocked,
                backgroundRestricted: report.dlp.backgroundRestricted,
              ),
            ),
            _DlpSwitch(
              label: 'Pano / kopyalama erişimini kapat',
              value: report.dlp.clipboardBlocked,
              onChanged: (v) => control.setDlp(
                packageId: report.packageId,
                displayName: report.displayName,
                outboundBlocked: report.dlp.outboundBlocked,
                clipboardBlocked: v,
                backgroundRestricted: report.dlp.backgroundRestricted,
              ),
            ),
            _DlpSwitch(
              label: 'Arka plan izni kısıtla',
              value: report.dlp.backgroundRestricted,
              onChanged: (v) => control.setDlp(
                packageId: report.packageId,
                displayName: report.displayName,
                outboundBlocked: report.dlp.outboundBlocked,
                clipboardBlocked: report.dlp.clipboardBlocked,
                backgroundRestricted: v,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => control.openSystemSettings(report.packageId),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Sistem izinlerini aç'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DlpSwitch extends StatelessWidget {
  const _DlpSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      activeTrackColor: NexusBrand.cyberCyan.withValues(alpha: 0.5),
      onChanged: onChanged,
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        'Risk $score',
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
