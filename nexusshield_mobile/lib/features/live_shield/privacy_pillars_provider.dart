import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';

class PrivacyPillarsState {
  const PrivacyPillarsState({
    this.wifiDetail = '—',
    this.wifiSecure = true,
    this.callDetail = '—',
    this.messagingDetail = '—',
    this.mediaApps = 0,
    this.vpnActive = false,
  });

  final String wifiDetail;
  final bool wifiSecure;
  final String callDetail;
  final String messagingDetail;
  final int mediaApps;
  final bool vpnActive;

  PrivacyPillarsState copyWith({
    String? wifiDetail,
    bool? wifiSecure,
    String? callDetail,
    String? messagingDetail,
    int? mediaApps,
    bool? vpnActive,
  }) {
    return PrivacyPillarsState(
      wifiDetail: wifiDetail ?? this.wifiDetail,
      wifiSecure: wifiSecure ?? this.wifiSecure,
      callDetail: callDetail ?? this.callDetail,
      messagingDetail: messagingDetail ?? this.messagingDetail,
      mediaApps: mediaApps ?? this.mediaApps,
      vpnActive: vpnActive ?? this.vpnActive,
    );
  }
}

class PrivacyPillarsController extends Notifier<PrivacyPillarsState> {
  Timer? _timer;

  @override
  PrivacyPillarsState build() {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => refresh());
    Future.microtask(refresh);
    return const PrivacyPillarsState();
  }

  Future<void> refresh() async {
    final snap = await NexusPlatformBridge.getPrivacyPillarsSnapshot();
    final wifi = Map<String, dynamic>.from(snap['wifi'] as Map? ?? const {});
    final remote =
        Map<String, dynamic>.from(snap['remoteAccess'] as Map? ?? const {});
    final openWifi = '${wifi['encryption'] ?? ''}' == 'OPEN';
    state = PrivacyPillarsState(
      wifiDetail: '${wifi['detail'] ?? 'Wi‑Fi durumu'}',
      wifiSecure: !openWifi && wifi['dnsHijackSuspect'] != true,
      callDetail: '${remote['detail'] ?? 'Arama / mikrofon taranıyor'}',
      messagingDetail: remote['overlayAppsCount'] != null &&
              (remote['overlayAppsCount'] as num) > 0
          ? '${remote['overlayAppsCount']} bindirme uygulaması tespit edildi'
          : 'Pano & erişilebilirlik denetleniyor',
      mediaApps: (snap['mediaAppsWithAccess'] as num?)?.toInt() ?? 0,
      vpnActive: snap['vpnActive'] == true,
    );
  }
}

final privacyPillarsProvider =
    NotifierProvider<PrivacyPillarsController, PrivacyPillarsState>(
  PrivacyPillarsController.new,
);
