import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../live_shield/live_feed_provider.dart';
import '../traffic_guard/traffic_guard_provider.dart';

class AdvancedThreatDefenseState {
  const AdvancedThreatDefenseState({
    this.profile = const {},
    this.blockedCount = 0,
    this.vpnForced = false,
  });

  final Map<String, dynamic> profile;
  final int blockedCount;
  final bool vpnForced;

  AdvancedThreatDefenseState copyWith({
    Map<String, dynamic>? profile,
    int? blockedCount,
    bool? vpnForced,
  }) {
    return AdvancedThreatDefenseState(
      profile: profile ?? this.profile,
      blockedCount: blockedCount ?? this.blockedCount,
      vpnForced: vpnForced ?? this.vpnForced,
    );
  }
}

class AdvancedThreatDefenseController extends Notifier<AdvancedThreatDefenseState> {
  @override
  AdvancedThreatDefenseState build() => const AdvancedThreatDefenseState();

  Future<void> refresh() async {
    final profile = await NexusPlatformBridge.getActiveNetworkProfile();
    final blocked = (profile['blockedThreatDomains'] as List<dynamic>? ?? const [])
        .length;
    final forceVpn = profile['recommendVpnTunnel'] == true ||
        profile['dnsHijackSuspect'] == true ||
        profile['arpPoisonSuspect'] == true;
    if (forceVpn) {
      await ref.read(trafficGuardProvider.notifier).ensureStarted();
      ref.read(liveFeedProvider.notifier).push(
            'Ağ saldırısı riski — DNS/ARP kalkanı ve VPN tüneli zorlandı',
          );
    }
    state = AdvancedThreatDefenseState(
      profile: profile,
      blockedCount: blocked,
      vpnForced: forceVpn,
    );
  }
}

final advancedThreatDefenseProvider =
    NotifierProvider<AdvancedThreatDefenseController, AdvancedThreatDefenseState>(
  AdvancedThreatDefenseController.new,
);
