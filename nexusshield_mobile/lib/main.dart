import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/banking/banking_shield_provider.dart';
import 'features/call_fraud/call_fraud_provider.dart';
import 'features/live_shield/live_feed_provider.dart';
import 'features/live_shield/live_shield_screen.dart';
import 'features/live_shield/privacy_pillars_provider.dart';
import 'features/network/wifi_security_provider.dart';
import 'features/permissions/permission_scan_provider.dart';
import 'features/remote_access/remote_access_provider.dart';
import 'features/traffic_guard/traffic_guard_provider.dart';
import 'features/vault/smart_vault_sync_provider.dart';
import 'providers/shield_providers.dart';
import 'providers/vault_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/vault_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/nexus_minimal_tech_logo.dart';
import 'widgets/nexus_splash_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: NexusShieldApp(),
    ),
  );
}

class NexusShieldApp extends StatelessWidget {
  const NexusShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexusShield',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const NexusSplashOverlay(
        child: _LiveShieldShell(),
      ),
    );
  }
}

class _LiveShieldShell extends ConsumerWidget {
  const _LiveShieldShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shieldOn = ref.watch(shieldStatusProvider);
    ref.watch(vaultServiceProvider);
    ref.watch(securityEventBridgeProvider);
    ref.watch(wifiSecurityProvider);
    ref.watch(remoteAccessProvider);
    ref.watch(callFraudProvider);
    ref.watch(trafficGuardProvider);
    ref.watch(bankingShieldProvider);
    ref.watch(smartVaultSyncProvider);
    ref.watch(liveFeedProvider);
    ref.watch(privacyPillarsProvider);

    return Scaffold(
      backgroundColor: NexusBrand.deepSlate,
      appBar: AppBar(
        title: const Text('Personal Guard'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: NexusMinimalTechLogo(
            size: 36,
            active: shieldOn,
            pulseWhenActive: true,
          ),
        ),
        leadingWidth: 52,
        actions: [
          IconButton(
            tooltip: 'Vault',
            icon: const Icon(Icons.key_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const VaultScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Ayarlar',
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: const LiveShieldScreen(),
    );
  }
}
