import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/interfaces/security_module.dart';
import '../../../domain/models/module_health.dart';
import '../../../domain/models/protection_score.dart';
import '../../banking/banking_shield_provider.dart';

class BankingSecurityModule implements SecurityModule {
  BankingSecurityModule(this._ref);

  final Ref _ref;

  static const moduleKey = 'banking';

  @override
  String get id => moduleKey;

  @override
  String get displayName => 'Finans';

  @override
  Future<ModuleHealth> evaluate() async {
    final bank = _ref.read(bankingShieldProvider);
    if (bank.threatDetected) {
      return ModuleHealth(
        moduleId: moduleKey,
        title: 'Finansal Koruma',
        riskLevel: RiskLevel.critical,
        score: 28,
        statusLabel: 'Oturum tehdidi',
        detail: bank.detail,
      );
    }
    if (bank.bankingAppActive) {
      return const ModuleHealth(
        moduleId: moduleKey,
        title: 'Finansal Koruma',
        riskLevel: RiskLevel.secure,
        score: 90,
        statusLabel: 'Bankacılık kalkanı aktif',
        detail: 'Overlay / ekran kaydı taranıyor',
      );
    }
    return const ModuleHealth(
      moduleId: moduleKey,
      title: 'Finansal Koruma',
      riskLevel: RiskLevel.secure,
      score: 82,
      statusLabel: 'Hazır',
      detail: 'Finans uygulaması açıldığında devreye girer',
    );
  }
}
