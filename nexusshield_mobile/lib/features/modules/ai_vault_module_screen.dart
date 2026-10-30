import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../../navigation/nexus_navigation.dart';
import '../../providers/api_discovery_provider.dart';
import '../../screens/vault_screen.dart';
import '../../theme/app_theme.dart';
import '../ai_guard/api_key_leak_shield_provider.dart';

class AiVaultModuleScreen extends ConsumerStatefulWidget {
  const AiVaultModuleScreen({super.key});

  @override
  ConsumerState<AiVaultModuleScreen> createState() => _AiVaultModuleScreenState();
}

class _AiVaultModuleScreenState extends ConsumerState<AiVaultModuleScreen> {
  List<Map<String, dynamic>> _aiApps = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await NexusPlatformBridge.scanInstalledAiClients();
    if (mounted) {
      setState(() {
        _aiApps = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(apiKeyLeakShieldProvider);
    ref.watch(apiDiscoveryProvider);

    return NexusSubScreenScaffold(
      title: 'AI & API Kasa Koruması',
      subtitle: 'Anahtar sızıntısı • Vault',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CyberCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('API anahtarı sızıntı kalkanı', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Pano veya giriş alanında sk-, AIza, claude-, hf_ formatları anlık taranır. '
                  'Kalkan açıkken pano izleme aktiftir.',
                  style: TextStyle(fontSize: 12, color: NexusBrand.muted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => pushNexusSubRoute(context, const VaultScreen()),
            icon: const Icon(Icons.key),
            label: const Text('Şifreli Kasayı aç'),
          ),
          const SizedBox(height: 16),
          Text('Tespit edilen AI araçları', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_aiApps.isEmpty)
            const Text('Yerel taramada AI istemcisi bulunamadı — Vault ile manuel ekleyin.',
                style: TextStyle(color: NexusBrand.muted))
          else
            ..._aiApps.map(
              (a) => ListTile(
                dense: true,
                title: Text('${a['displayName'] ?? a['packageId']}'),
                subtitle: Text('${a['packageId']}'),
                trailing: const Icon(Icons.smart_toy_outlined, color: NexusBrand.muted),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('AI uygulamalarını yeniden tara'),
          ),
        ],
      ),
    );
  }
}
