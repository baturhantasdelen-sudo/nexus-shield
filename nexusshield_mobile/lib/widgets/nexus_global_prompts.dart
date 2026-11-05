import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/ai_guard/api_key_leak_shield_provider.dart';
import '../features/bridge/app_protection_bridge_provider.dart';
import '../theme/app_theme.dart';

/// Karargah üzerinde köprü ve API anahtarı onay kartları.
class NexusGlobalPrompts extends ConsumerStatefulWidget {
  const NexusGlobalPrompts({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NexusGlobalPrompts> createState() => _NexusGlobalPromptsState();
}

class _NexusGlobalPromptsState extends ConsumerState<NexusGlobalPrompts> {
  String? _shownBridgeId;
  bool _apiDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(appProtectionBridgeProvider, (prev, next) {
      final p = next.pendingPrompt;
      if (p == null || p.report.bridged) return;
      if (_shownBridgeId == p.report.packageId) return;
      _shownBridgeId = p.report.packageId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showBridgeDialog(p);
      });
    });

    ref.listen(apiKeyLeakShieldProvider, (prev, next) {
      if (next.pendingOffer == null || _apiDialogOpen) return;
      _apiDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _showApiKeyDialog(next.pendingOffer!);
        _apiDialogOpen = false;
      });
    });

    return widget.child;
  }

  Future<void> _showBridgeDialog(BridgeEntry c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexusBrand.glassPanel,
        title: Text('${c.report.displayName} tespit edildi'),
        content: Text(
          '${c.report.displayName} için arka plan veri sızıntısı, oltalama linkleri ve '
          'ekran okuma saldırılarına karşı Koruma Köbrüsü kurulsun mu?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(appProtectionBridgeProvider.notifier).dismissPrompt();
              Navigator.pop(ctx, false);
            },
            child: const Text('Şimdilik hayır'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('İzin Ver ve Köprü Kur'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(appProtectionBridgeProvider.notifier).enableBridge(c);
    } else {
      ref.read(appProtectionBridgeProvider.notifier).dismissPrompt();
    }
  }

  Future<void> _showApiKeyDialog(ApiKeyLeakOffer offer) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexusBrand.glassPanel,
        title: const Text('Açıkta AI API anahtarı'),
        content: const Text(
          'Açıkta bir Yapay Zeka API anahtarı tespit edildi! Diğer uygulamaların '
          'panodan bu anahtarı çalmasını engellemek için Şifreli Kasa\'ya taşınsın '
          've pano temizlensin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(apiKeyLeakShieldProvider.notifier).dismiss();
              Navigator.pop(ctx, false);
            },
            child: const Text('Reddet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vault\'a taşı'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(apiKeyLeakShieldProvider.notifier).vaultAndClearClipboard();
    } else {
      ref.read(apiKeyLeakShieldProvider.notifier).dismiss();
    }
  }
}
