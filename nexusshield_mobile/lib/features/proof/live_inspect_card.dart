import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'how_it_protects_proof_sheet.dart';
import 'protection_live_test_provider.dart';
import 'protection_proof_provider.dart';

class LiveInspectCard extends ConsumerWidget {
  const LiveInspectCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proof = ref.watch(protectionProofProvider);
    final test = ref.watch(protectionLiveTestProvider);
    final snap = proof.snapshot;
    final vpn = '${snap['vpnInterface'] ?? '—'}';
    final dnsCount = '${snap['dnsQueriesInspected'] ?? '—'}';

    return CyberCard(
      borderColor: NexusBrand.tealAccent,
      borderOpacity: 0.28,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: NexusBrand.tealAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nasıl Koruyor? (Canlı Teknik Kanıt)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Yenile',
                onPressed: () => ref.read(protectionProofProvider.notifier).refresh(),
                icon: proof.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('VPN: $vpn', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          Text(
            'İncelenen DNS/IP sorgusu (oturum): $dnsCount',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          if (test.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                test.message,
                style: TextStyle(
                  color: test.verifiedPercent >= 100
                      ? NexusBrand.neonGreen
                      : NexusBrand.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => showHowItProtectsProofSheet(context),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Canlı kanıt panelini aç'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: test.running
                ? null
                : () => ref.read(protectionLiveTestProvider.notifier).runLiveTest(),
            icon: test.running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_circle_outline),
            label: const Text('Korumayı Canlı Test Et'),
          ),
        ],
      ),
    );
  }
}
