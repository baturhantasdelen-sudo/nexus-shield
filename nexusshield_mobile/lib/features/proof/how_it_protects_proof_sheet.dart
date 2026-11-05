import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'protection_proof_provider.dart';

Future<void> showHowItProtectsProofSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: NexusBrand.deepSlate,
    builder: (ctx) => const _HowItProtectsProofSheet(),
  );
}

class _HowItProtectsProofSheet extends ConsumerWidget {
  const _HowItProtectsProofSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proof = ref.watch(protectionProofProvider);
    final snap = proof.snapshot;
    final wifi = Map<String, dynamic>.from(snap['wifi'] as Map? ?? const {});
    final remote = Map<String, dynamic>.from(snap['remoteAccess'] as Map? ?? const {});
    final trackers = (snap['trackerEvents'] as List<dynamic>? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NexusBrand.muted,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Canlı Teknik Kanıt',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _sectionTitle('Ağ & VPN tüneli'),
              _kv('Arayüz', '${snap['vpnInterface'] ?? '—'}'),
              _kv('DNS/IP inceleme sayacı', '${snap['dnsQueriesInspected'] ?? '—'}'),
              _kv('Köprülü uygulama', '${snap['bridgedAppCount'] ?? 0}'),
              for (final t in trackers)
                _statusLine(
                  '${t['domain']} — ${t['action']}',
                  '${t['action']}'.toLowerCase().contains('engellendi'),
                ),
              const SizedBox(height: 12),
              _sectionTitle('Pano zırhı'),
              _statusLine(
                'Clipboard imza motoru (IBAN / kart / API anahtarı)',
                snap['clipboardShieldActive'] == true,
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(const ClipboardData(text: ''));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pano güvenli şekilde temizlendi')),
                    );
                  }
                },
                icon: const Icon(Icons.content_paste_off),
                label: const Text('Panoyu şimdi temizle / test et'),
              ),
              const SizedBox(height: 12),
              _sectionTitle('Bankacılık & ekran koruması'),
              _statusLine('Ekran kaydı / yansıtma', remote['screenCaptureActive'] != true),
              _statusLine('Erişilebilirlik okuma servisi', (remote['suspiciousAccessibilityCount'] as num? ?? 0) == 0),
              _statusLine('Sahte bindirme (overlay)', (remote['overlayAppsCount'] as num? ?? 0) == 0),
              _statusLine('USB hata ayıklama (ADB)', remote['adbEnabled'] != true),
              Text('${remote['detail'] ?? ''}', style: const TextStyle(fontSize: 12, color: NexusBrand.muted)),
              const SizedBox(height: 12),
              _sectionTitle('Wi‑Fi & MITM'),
              _kv('SSID', '${wifi['ssid'] ?? '—'}'),
              _kv('Gateway', '${wifi['gateway'] ?? '—'}'),
              _kv('DNS', '${wifi['dnsServers'] ?? '—'}'),
              _kv('Şifreleme', '${wifi['encryption'] ?? '—'}'),
              _kv('TLS doğrulama', '${wifi['tlsValidation'] ?? '—'}'),
              Text('${wifi['detail'] ?? ''}', style: const TextStyle(fontSize: 12, color: NexusBrand.muted)),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(k, style: const TextStyle(color: NexusBrand.muted, fontSize: 12))),
            Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
          ],
        ),
      );

  Widget _statusLine(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: ok ? NexusBrand.neonGreen : NexusBrand.alertRed,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
