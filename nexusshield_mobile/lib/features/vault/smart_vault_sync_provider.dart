import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../../providers/api_discovery_provider.dart';

class AiClientInstall {
  const AiClientInstall({
    required this.packageId,
    required this.displayName,
    required this.importHint,
  });

  final String packageId;
  final String displayName;
  final String importHint;

  factory AiClientInstall.fromMap(Map<String, dynamic> map) {
    return AiClientInstall(
      packageId: '${map['packageId'] ?? ''}',
      displayName: '${map['displayName'] ?? 'AI Client'}',
      importHint: '${map['importHint'] ?? ''}',
    );
  }
}

class SmartVaultSyncState {
  const SmartVaultSyncState({
    this.clients = const [],
    this.scanning = false,
  });

  final List<AiClientInstall> clients;
  final bool scanning;

  SmartVaultSyncState copyWith({
    List<AiClientInstall>? clients,
    bool? scanning,
  }) {
    return SmartVaultSyncState(
      clients: clients ?? this.clients,
      scanning: scanning ?? this.scanning,
    );
  }
}

/// Discovers installed AI clients; keys are imported only with explicit user action (Vault).
class SmartVaultSyncController extends Notifier<SmartVaultSyncState> {
  @override
  SmartVaultSyncState build() {
    Future.microtask(scan);
    return const SmartVaultSyncState();
  }

  Future<void> scan() async {
    state = state.copyWith(scanning: true);
    final raw = await NexusPlatformBridge.scanInstalledAiClients();
    final clients =
        raw.map(AiClientInstall.fromMap).toList(growable: false);
    state = SmartVaultSyncState(clients: clients, scanning: false);

    final discovery = ref.read(apiDiscoveryProvider.notifier);
    for (final client in clients) {
      discovery.registerDiscoveredClient(
        id: client.packageId,
        title: client.displayName,
        subtitle: 'Yüklü istemci — Vault içe aktarımı bekliyor',
      );
    }
  }
}

final smartVaultSyncProvider =
    NotifierProvider<SmartVaultSyncController, SmartVaultSyncState>(
  SmartVaultSyncController.new,
);
