import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../../theme/app_theme.dart';
import 'traffic_guard_provider.dart';

/// Guides the user through VPN and Usage Stats grants for Traffic Guard.
Future<void> showTrafficGuardSetupSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: NexusBrand.deepNavy,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _TrafficGuardSetupBody(),
  );
}

class _TrafficGuardSetupBody extends ConsumerStatefulWidget {
  const _TrafficGuardSetupBody();

  @override
  ConsumerState<_TrafficGuardSetupBody> createState() =>
      _TrafficGuardSetupBodyState();
}

class _TrafficGuardSetupBodyState extends ConsumerState<_TrafficGuardSetupBody> {
  bool _busy = false;

  Future<void> _grantVpn() async {
    setState(() => _busy = true);
    try {
      await NexusPlatformBridge.requestVpnConsent();
      await ref.read(trafficGuardProvider.notifier).refresh();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openUsageStats() async {
    await NexusPlatformBridge.openUsageAccessSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'NexusShield için “Kullanım erişimi”ni açın, ardından bu ekrana dönün.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final traffic = ref.watch(trafficGuardProvider);
    final vpnOk = traffic.active && !traffic.needsVpnConsent;
    final usageOk = traffic.usageStatsGranted;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NexusBrand.muted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Trafik Guard kurulumu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: NexusBrand.metallicLight,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sosyal medya / AI davranışsal izleme uyarıları için yerel VPN oturumu '
            've (Android) kullanım erişimi gerekir. Veriler cihazda kalır.',
            style: TextStyle(color: NexusBrand.muted, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _SetupStep(
            done: vpnOk,
            title: '1. Yerel VPN onayı',
            subtitle: vpnOk
                ? 'Guard oturumu aktif'
                : 'Android sistem VPN izni — trafik gözlemcisi',
            actionLabel: vpnOk ? 'Tamam' : 'VPN izni ver',
            onAction: vpnOk ? null : _grantVpn,
            busy: _busy,
          ),
          const SizedBox(height: 12),
          _SetupStep(
            done: usageOk,
            title: '2. Kullanım erişimi (Usage Stats)',
            subtitle: usageOk
                ? 'Ön plandaki uygulama algılanabilir'
                : 'Instagram / TikTok vb. için gerekli',
            actionLabel: usageOk ? 'Tamam' : 'Ayarlara git',
            onAction: usageOk ? null : _openUsageStats,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await ref.read(trafficGuardProvider.notifier).refresh();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Durumu yenile ve kapat'),
          ),
        ],
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({
    required this.done,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onAction,
    this.busy = false,
  });

  final bool done;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final accent = done ? NexusBrand.neonGreen : NexusBrand.cyberCyan;
    return CyberCard(
      borderColor: accent,
      borderOpacity: 0.35,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            color: accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: NexusBrand.muted, fontSize: 12),
                ),
                if (onAction != null) ...[
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: busy ? null : onAction,
                    child: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
