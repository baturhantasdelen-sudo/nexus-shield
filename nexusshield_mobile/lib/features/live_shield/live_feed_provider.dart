import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shield_providers.dart';
import '../network/wifi_security_provider.dart';
import '../permissions/permission_scan_provider.dart';
import '../traffic_guard/traffic_guard_provider.dart';

class LiveFeedLine {
  const LiveFeedLine({required this.text, required this.at});

  final String text;
  final DateTime at;
}

class LiveFeedController extends Notifier<List<LiveFeedLine>> {
  Timer? _poll;

  @override
  List<LiveFeedLine> build() {
    ref.onDispose(() => _poll?.cancel());
    ref.listen(shieldStatusProvider, (prev, next) {
      push(
        next
            ? 'Tam koruma devrede — DLP ve ağ kalkanı aktif'
            : 'Kalkan beklemede — dokunarak tam korumayı açın',
      );
    });
    ref.listen(wifiSecurityProvider, (_, next) {
      if (next.connected) {
        push('Wi‑Fi: ${next.encryption.label} — ${next.detail}');
        if (next.recommendVpnTunnel) {
          push('Wi‑Fi: Güvensiz ağ — otomatik tünel zorlandı');
        }
      }
    });
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _heartbeat());
    Future.microtask(_bootstrap);
    return const [];
  }

  Future<void> _bootstrap() async {
    push('Canlı denetim akışı başlatıldı');
    await ref.read(permissionScanProvider.notifier).scan();
    push('Uygulama & AI envanteri tarandı');
  }

  void _heartbeat() {
    final traffic = ref.read(trafficGuardProvider);
    final label = traffic.foregroundLabel;
    if (label != null && traffic.active) {
      push('$label: arka plan telemetri denetleniyor');
    }
  }

  void push(String text) {
    final line = LiveFeedLine(text: text, at: DateTime.now());
    state = [line, ...state].take(40).toList(growable: false);
  }
}

final liveFeedProvider =
    NotifierProvider<LiveFeedController, List<LiveFeedLine>>(
  LiveFeedController.new,
);
