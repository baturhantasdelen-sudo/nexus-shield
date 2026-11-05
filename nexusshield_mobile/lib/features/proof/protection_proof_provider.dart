import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../../providers/shield_providers.dart';

class ProtectionProofState {
  const ProtectionProofState({
    this.loading = true,
    this.snapshot = const {},
    this.lastRefresh,
  });

  final bool loading;
  final Map<String, dynamic> snapshot;
  final DateTime? lastRefresh;

  ProtectionProofState copyWith({
    bool? loading,
    Map<String, dynamic>? snapshot,
    DateTime? lastRefresh,
  }) {
    return ProtectionProofState(
      loading: loading ?? this.loading,
      snapshot: snapshot ?? this.snapshot,
      lastRefresh: lastRefresh ?? this.lastRefresh,
    );
  }
}

class ProtectionProofController extends Notifier<ProtectionProofState> {
  Timer? _timer;

  @override
  ProtectionProofState build() {
    ref.onDispose(() => _timer?.cancel());
    ref.listen(shieldStatusProvider, (_, _) => refresh());
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => refresh());
    Future.microtask(refresh);
    return const ProtectionProofState();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      final snap = await NexusPlatformBridge.getProtectionProofSnapshot();
      state = ProtectionProofState(
        loading: false,
        snapshot: snap,
        lastRefresh: DateTime.now(),
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }
}

final protectionProofProvider =
    NotifierProvider<ProtectionProofController, ProtectionProofState>(
  ProtectionProofController.new,
);
