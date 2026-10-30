import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shield_providers.dart';
import '../bridge/app_protection_bridge_provider.dart';
import '../defense/advanced_threat_defense_provider.dart';
import '../defense/system_integrity_provider.dart';
import '../live_shield/live_feed_provider.dart';
import '../traffic_guard/traffic_guard_provider.dart';

enum AutoProtectionStep {
  idle,
  scanningNetwork,
  validatingBridges,
  updatingSignatures,
  activatingAiBanking,
  complete,
}

class AutoProtectionWizardState {
  const AutoProtectionWizardState({
    this.step = AutoProtectionStep.idle,
    this.progress = 0,
    this.message = '',
  });

  final AutoProtectionStep step;
  final double progress;
  final String message;

  AutoProtectionWizardState copyWith({
    AutoProtectionStep? step,
    double? progress,
    String? message,
  }) {
    return AutoProtectionWizardState(
      step: step ?? this.step,
      progress: progress ?? this.progress,
      message: message ?? this.message,
    );
  }
}

class AutoProtectionWizardController extends Notifier<AutoProtectionWizardState> {
  @override
  AutoProtectionWizardState build() => const AutoProtectionWizardState();

  Future<void> runFullAutoProtection() async {
    final feed = ref.read(liveFeedProvider.notifier);
    await _step(
      AutoProtectionStep.scanningNetwork,
      0.25,
      '1. Ağ taranıyor…',
      () async {
        await ref.read(advancedThreatDefenseProvider.notifier).refresh();
        await ref.read(trafficGuardProvider.notifier).ensureStarted();
      },
    );
    await _step(
      AutoProtectionStep.validatingBridges,
      0.5,
      '2. Uygulama köprüleri doğrulanıyor…',
      () => ref.read(appProtectionBridgeProvider.notifier).syncFromDevice(),
    );
    await _step(
      AutoProtectionStep.updatingSignatures,
      0.75,
      '3. iOS/Android saldırı imzaları güncelleniyor…',
      () => ref.read(systemIntegrityProvider.notifier).refresh(),
    );
    await _step(
      AutoProtectionStep.activatingAiBanking,
      1.0,
      '4. AI & Banka zırhı aktif…',
      () async {
        if (!ref.read(shieldStatusProvider)) {
          await ref.read(shieldStatusProvider.notifier).toggle();
        }
      },
    );
    HapticFeedback.mediumImpact();
    state = const AutoProtectionWizardState(
      step: AutoProtectionStep.complete,
      progress: 1,
      message: 'Otomatik tam koruma aktif',
    );
    feed.push('Otomatik tam koruma tamamlandı — tüm katmanlar devrede');
  }

  Future<void> _step(
    AutoProtectionStep step,
    double progress,
    String message,
    Future<void> Function() work,
  ) async {
    HapticFeedback.lightImpact();
    state = AutoProtectionWizardState(step: step, progress: progress, message: message);
    ref.read(liveFeedProvider.notifier).push(message);
    await work();
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  void reset() => state = const AutoProtectionWizardState();
}

final autoProtectionWizardProvider =
    NotifierProvider<AutoProtectionWizardController, AutoProtectionWizardState>(
  AutoProtectionWizardController.new,
);
