import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../../providers/shield_providers.dart';
import '../security/security_alert_provider.dart';

class BankingShieldState {
  const BankingShieldState({
    this.bankingAppActive = false,
    this.screenCaptureActive = false,
    this.overlayAppsCount = 0,
    this.suspiciousAccessibilityCount = 0,
    this.foregroundPackage = '',
    this.detail = '',
  });

  final bool bankingAppActive;
  final bool screenCaptureActive;
  final int overlayAppsCount;
  final int suspiciousAccessibilityCount;
  final String foregroundPackage;
  final String detail;

  bool get threatDetected =>
      bankingAppActive &&
      (screenCaptureActive ||
          overlayAppsCount > 0 ||
          suspiciousAccessibilityCount > 0);

  BankingShieldState copyWith({
    bool? bankingAppActive,
    bool? screenCaptureActive,
    int? overlayAppsCount,
    int? suspiciousAccessibilityCount,
    String? foregroundPackage,
    String? detail,
  }) {
    return BankingShieldState(
      bankingAppActive: bankingAppActive ?? this.bankingAppActive,
      screenCaptureActive: screenCaptureActive ?? this.screenCaptureActive,
      overlayAppsCount: overlayAppsCount ?? this.overlayAppsCount,
      suspiciousAccessibilityCount:
          suspiciousAccessibilityCount ?? this.suspiciousAccessibilityCount,
      foregroundPackage: foregroundPackage ?? this.foregroundPackage,
      detail: detail ?? this.detail,
    );
  }
}

class BankingShieldController extends Notifier<BankingShieldState> {
  Timer? _timer;

  @override
  BankingShieldState build() {
    ref.onDispose(() => _timer?.cancel());
    ref.listen(shieldSettingsProvider, (_, next) {
      if (next.bankingGuard) {
        _start();
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
    if (ref.read(shieldSettingsProvider).bankingGuard) {
      Future.microtask(_poll);
      _start();
    }
    return const BankingShieldState();
  }

  void _start() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  Future<void> _poll() async {
    final snap = await NexusPlatformBridge.getBankingShieldSnapshot();
    final next = BankingShieldState(
      bankingAppActive: snap['bankingAppActive'] == true,
      screenCaptureActive: snap['screenCaptureActive'] == true,
      overlayAppsCount: (snap['overlayAppsCount'] as num?)?.toInt() ?? 0,
      suspiciousAccessibilityCount:
          (snap['suspiciousAccessibilityCount'] as num?)?.toInt() ?? 0,
      foregroundPackage: '${snap['foregroundPackage'] ?? ''}',
      detail: '${snap['detail'] ?? ''}',
    );
    if (next.threatDetected && !state.threatDetected) {
      ref.read(securityAlertProvider.notifier).push(
            SecurityAlert(
              title: 'Finansal oturum riski',
              body:
                  'Bankacılık uygulaması açıkken ekran kaydı, bindirme veya uzaktan erişim sinyali algılandı. '
                  '${next.detail}',
              kind: SecurityAlertKind.remoteAccess,
            ),
          );
    }
    state = next;
  }
}

final bankingShieldProvider =
    NotifierProvider<BankingShieldController, BankingShieldState>(
  BankingShieldController.new,
);
