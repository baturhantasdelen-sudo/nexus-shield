import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/interfaces/security_module.dart';
import '../../../domain/models/module_health.dart';
import '../../../domain/models/protection_score.dart';
import '../../vault/smart_vault_sync_provider.dart';

class VaultSyncSecurityModule implements SecurityModule {
  VaultSyncSecurityModule(this._ref);

  final Ref _ref;

  static const moduleKey = 'vault_sync';

  @override
  String get id => moduleKey;

  @override
  String get displayName => 'Vault';

  @override
  Future<ModuleHealth> evaluate() async {
    final sync = _ref.read(smartVaultSyncProvider);
    if (sync.clients.isEmpty) {
      return const ModuleHealth(
        moduleId: moduleKey,
        title: 'Akıllı Vault',
        riskLevel: RiskLevel.warning,
        score: 60,
        statusLabel: 'AI istemcisi yok',
        detail: 'ChatGPT / Claude yüklendiğinde keşfedilir',
      );
    }
    return ModuleHealth(
      moduleId: moduleKey,
      title: 'Akıllı Vault',
      riskLevel: RiskLevel.secure,
      score: 86,
      statusLabel: '${sync.clients.length} istemci keşfedildi',
      detail: 'Vault sekmesinden onaylı içe aktarım',
    );
  }
}
