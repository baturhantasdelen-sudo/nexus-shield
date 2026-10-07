import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/interfaces/security_module.dart';
import '../../../domain/models/module_health.dart';
import '../../../domain/models/protection_score.dart';
import '../../traffic_guard/traffic_guard_provider.dart';

class TrafficGuardSecurityModule implements SecurityModule {
  TrafficGuardSecurityModule(this._ref);

  final Ref _ref;

  static const moduleKey = 'traffic_guard';

  @override
  String get id => moduleKey;

  @override
  String get displayName => 'AI Trafik';

  @override
  Future<ModuleHealth> evaluate() async {
    final guard = _ref.read(trafficGuardProvider);
    if (guard.active && guard.foregroundLabel != null) {
      return ModuleHealth(
        moduleId: moduleKey,
        title: 'Sosyal / AI Trafik',
        riskLevel: RiskLevel.warning,
        score: 58,
        statusLabel: '${guard.foregroundLabel} izleniyor',
        detail: 'Davranışsal yönlendirme dedektörü aktif',
      );
    }
    if (guard.active) {
      return const ModuleHealth(
        moduleId: moduleKey,
        title: 'Sosyal / AI Trafik',
        riskLevel: RiskLevel.secure,
        score: 88,
        statusLabel: 'Yerel Guard aktif',
        detail: 'Reels / TikTok API uçları gözlemleniyor',
      );
    }
    return const ModuleHealth(
      moduleId: moduleKey,
      title: 'Sosyal / AI Trafik',
      riskLevel: RiskLevel.warning,
      score: 52,
      statusLabel: 'Guard kapalı',
      detail: 'Kalkanı açarak trafik gözlemcisini etkinleştirin',
    );
  }
}
