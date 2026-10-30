import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';

class SystemIntegrityState {
  const SystemIntegrityState({
    this.snapshot = const {},
  });

  final Map<String, dynamic> snapshot;

  bool get lockdownRecommended => snapshot['lockdownRecommended'] == true;
  String get detail => '${snapshot['detail'] ?? ''}';
}

class SystemIntegrityController extends Notifier<SystemIntegrityState> {
  @override
  SystemIntegrityState build() {
    Future.microtask(refresh);
    return const SystemIntegrityState();
  }

  Future<void> refresh() async {
    final snap = await NexusPlatformBridge.getSystemIntegritySnapshot();
    state = SystemIntegrityState(snapshot: snap);
  }
}

final systemIntegrityProvider =
    NotifierProvider<SystemIntegrityController, SystemIntegrityState>(
  SystemIntegrityController.new,
);
