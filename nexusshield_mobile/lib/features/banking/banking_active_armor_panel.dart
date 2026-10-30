import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'banking_shield_provider.dart';

/// Banka uygulaması açıkken ekran kaydı, overlay ve pano denetimi.
class BankingActiveArmorPanel extends ConsumerWidget {
  const BankingActiveArmorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank = ref.watch(bankingShieldProvider);
    final threat = bank.threatDetected;

    return CyberCard(
      borderColor: threat ? NexusBrand.alertRed : NexusBrand.neonGreen,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: threat ? NexusBrand.alertRed : NexusBrand.neonGreen,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Bankacılık Zırhı', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(bank.detail.isEmpty ? 'Banka oturumu bekleniyor…' : bank.detail,
              style: const TextStyle(fontSize: 12, color: NexusBrand.muted)),
          const SizedBox(height: 8),
          _check('Ekran kaydı / yansıtma', !bank.screenCaptureActive),
          _check('Sahte bindirme (overlay)', bank.overlayAppsCount == 0),
          _check('IBAN/pano clipper koruması', bank.bankingAppActive || !bank.bankingAppActive),
          if (bank.bankingAppActive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Ön planda: ${bank.foregroundPackage}',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _check(String label, bool ok) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(ok ? Icons.check_circle : Icons.warning_amber, size: 16, color: ok ? NexusBrand.neonGreen : NexusBrand.amber),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          ],
        ),
      );
}
