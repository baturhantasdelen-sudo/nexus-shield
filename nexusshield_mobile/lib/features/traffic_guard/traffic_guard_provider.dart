import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../../providers/shield_providers.dart';
import '../security/security_alert_provider.dart';
import 'social_tracking_catalog.dart';

class TrafficGuardState {
  const TrafficGuardState({
    this.active = false,
    this.foregroundPackage = '',
    this.blockedPackages = const [],
    this.usageStatsGranted = false,
    this.needsVpnConsent = false,
    this.lastDetection,
  });

  final bool active;
  final String foregroundPackage;
  final List<String> blockedPackages;
  final bool usageStatsGranted;
  final bool needsVpnConsent;
  final DateTime? lastDetection;

  String? get foregroundLabel =>
      SocialTrackingCatalog.labelForPackage(foregroundPackage);

  TrafficGuardState copyWith({
    bool? active,
    String? foregroundPackage,
    List<String>? blockedPackages,
    bool? usageStatsGranted,
    bool? needsVpnConsent,
    DateTime? lastDetection,
  }) {
    return TrafficGuardState(
      active: active ?? this.active,
      foregroundPackage: foregroundPackage ?? this.foregroundPackage,
      blockedPackages: blockedPackages ?? this.blockedPackages,
      usageStatsGranted: usageStatsGranted ?? this.usageStatsGranted,
      needsVpnConsent: needsVpnConsent ?? this.needsVpnConsent,
      lastDetection: lastDetection ?? this.lastDetection,
    );
  }
}

class TrafficGuardController extends Notifier<TrafficGuardState> {
  Timer? _poll;

  @override
  TrafficGuardState build() {
    ref.onDispose(() => _poll?.cancel());
    ref.listen(shieldSettingsProvider, (_, next) {
      if (next.localVpn) {
        _ensureStarted();
      } else {
        _stop();
      }
    });
    if (ref.read(shieldSettingsProvider).localVpn) {
      Future.microtask(_ensureStarted);
    }
    return const TrafficGuardState();
  }

  Future<void> _ensureStarted() async {
    final result = await NexusPlatformBridge.startLocalTrafficGuard();
    final needsConsent = result['needsVpnConsent'] == true;
    state = state.copyWith(
      active: result['active'] == true,
      needsVpnConsent: needsConsent,
    );
    _poll ??= Timer.periodic(const Duration(seconds: 4), (_) => _tick());
    await _tick();
  }

  Future<void> _stop() async {
    _poll?.cancel();
    _poll = null;
    await NexusPlatformBridge.stopLocalTrafficGuard();
    state = const TrafficGuardState();
  }

  Future<void> refresh() => _tick();

  bool get needsSetup =>
      state.needsVpnConsent || !state.usageStatsGranted || !state.active;

  Future<void> completeSetupAfterResume() async {
    await _tick();
    if (ref.read(shieldSettingsProvider).localVpn && !state.active) {
      await _ensureStarted();
    }
  }

  Future<void> _tick() async {
    final snap = await NexusPlatformBridge.getTrafficGuardSnapshot();
    final fg = '${snap['foregroundPackage'] ?? ''}';
    final blocked = (snap['blockedPackages'] as List<dynamic>? ?? const [])
        .map((e) => '$e')
        .toList(growable: false);
    state = state.copyWith(
      active: snap['vpnActive'] == true || state.active,
      foregroundPackage: fg,
      blockedPackages: blocked,
      usageStatsGranted: snap['usageStatsGranted'] == true,
    );

    if (!SocialTrackingCatalog.isSocialPackage(fg)) return;
    final label = SocialTrackingCatalog.labelForPackage(fg)!;
    final last = state.lastDetection;
    if (last != null && DateTime.now().difference(last).inSeconds < 45) {
      return;
    }
    final domainHint = SocialTrackingCatalog.trackingDomains.first;
    ref.read(securityAlertProvider.notifier).push(
          SecurityAlert(
            title: 'Algoritma / davranışsal izleme',
            body:
                'Şu an $label üzerinden yapay zeka tabanlı davranışsal yönlendirme/takip algılandı '
                '($domainHint ve benzeri uçlar).',
            kind: SecurityAlertKind.ai,
          ),
        );
    state = state.copyWith(lastDetection: DateTime.now());
  }
}

final trafficGuardProvider =
    NotifierProvider<TrafficGuardController, TrafficGuardState>(
  TrafficGuardController.new,
);
