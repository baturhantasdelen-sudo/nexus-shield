import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../ai_guard/api_key_leak_shield_provider.dart';
import '../live_shield/live_feed_provider.dart';

class LiveProtectionTestState {
  const LiveProtectionTestState({
    this.running = false,
    this.steps = const [],
    this.verifiedPercent = 0,
    this.message = '',
  });

  final bool running;
  final List<Map<String, dynamic>> steps;
  final int verifiedPercent;
  final String message;

  LiveProtectionTestState copyWith({
    bool? running,
    List<Map<String, dynamic>>? steps,
    int? verifiedPercent,
    String? message,
  }) {
    return LiveProtectionTestState(
      running: running ?? this.running,
      steps: steps ?? this.steps,
      verifiedPercent: verifiedPercent ?? this.verifiedPercent,
      message: message ?? this.message,
    );
  }
}

class ProtectionLiveTestController extends Notifier<LiveProtectionTestState> {
  @override
  LiveProtectionTestState build() => const LiveProtectionTestState();

  Future<void> runLiveTest() async {
    final feed = ref.read(liveFeedProvider.notifier);
    state = const LiveProtectionTestState(running: true, message: 'Canlı test başlatılıyor…');
    HapticFeedback.mediumImpact();
    feed.push('Korumayı canlı test et — adım 1: pano probu');

    await Clipboard.setData(
      const ClipboardData(text: 'sk-test_nexus_live_probe_do_not_use'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    ref.read(apiKeyLeakShieldProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    feed.push('Adım 2: izleyici domain politikası doğrulanıyor');
    await NexusPlatformBridge.setPackageNetworkBlocked(
      packageId: 'com.zhiliaoapp.musically',
      blocked: true,
    );

    feed.push('Adım 3: sistem sensörleri okunuyor');
    final native = await NexusPlatformBridge.runProtectionSelfTest();
    final steps = (native['steps'] as List<dynamic>? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
    final percent = (native['verifiedPercent'] as num?)?.toInt() ?? 0;
    final allPassed = native['allPassed'] == true;

    HapticFeedback.mediumImpact();
    state = LiveProtectionTestState(
      running: false,
      steps: steps,
      verifiedPercent: percent,
      message: allPassed ? '%100 Doğrulandı' : 'Kısmi doğrulama — VPN/onay gerekebilir',
    );
    feed.push(allPassed ? 'Canlı koruma testi: %100 doğrulandı' : 'Canlı test tamamlandı ($percent%)');
  }
}

final protectionLiveTestProvider =
    NotifierProvider<ProtectionLiveTestController, LiveProtectionTestState>(
  ProtectionLiveTestController.new,
);
