import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../../domain/models/app_permission_report.dart';
import '../live_shield/live_feed_provider.dart';
import '../permissions/permission_scan_provider.dart';
import 'app_catalog.dart';

class BridgeCandidate {
  const BridgeCandidate({
    required this.packageId,
    required this.displayName,
    required this.criticality,
    required this.bridged,
  });

  final String packageId;
  final String displayName;
  final AppCriticalityClass criticality;
  final bool bridged;
}

class AppProtectionBridgeState {
  const AppProtectionBridgeState({
    this.candidates = const [],
    this.pendingPrompt,
  });

  final List<BridgeCandidate> candidates;
  final BridgeCandidate? pendingPrompt;

  AppProtectionBridgeState copyWith({
    List<BridgeCandidate>? candidates,
    BridgeCandidate? pendingPrompt,
    bool clearPrompt = false,
  }) {
    return AppProtectionBridgeState(
      candidates: candidates ?? this.candidates,
      pendingPrompt: clearPrompt ? null : (pendingPrompt ?? this.pendingPrompt),
    );
  }
}

class AppProtectionBridgeController extends Notifier<AppProtectionBridgeState> {
  @override
  AppProtectionBridgeState build() {
    Future.microtask(syncFromDevice);
    return const AppProtectionBridgeState();
  }

  Future<void> syncFromDevice() async {
    await ref.read(permissionScanProvider.notifier).scan();
    final reports = ref.read(permissionScanProvider).reports;
    final candidates = <BridgeCandidate>[];
    BridgeCandidate? prompt;
    for (final r in reports) {
      final c = _fromReport(r);
      if (c.criticality == AppCriticalityClass.other) continue;
      candidates.add(c);
      if (!c.bridged && prompt == null && c.criticality != AppCriticalityClass.social) {
        prompt = c;
      }
    }
    state = AppProtectionBridgeState(candidates: candidates, pendingPrompt: prompt);
  }

  BridgeCandidate _fromReport(AppPermissionReport r) {
    return BridgeCandidate(
      packageId: r.packageId,
      displayName: r.displayName,
      criticality: AppCatalog.classify(r.packageId),
      bridged: r.bridged,
    );
  }

  Future<void> enableBridge(BridgeCandidate c) async {
    await NexusPlatformBridge.setAppProtectionBridge(
      packageId: c.packageId,
      enabled: true,
    );
    ref.read(liveFeedProvider.notifier).push(
          '${c.displayName}: Koruma köprüsü aktif • korunuyor',
        );
    await syncFromDevice();
    state = state.copyWith(clearPrompt: true);
  }

  void dismissPrompt() => state = state.copyWith(clearPrompt: true);
}

final appProtectionBridgeProvider =
    NotifierProvider<AppProtectionBridgeController, AppProtectionBridgeState>(
  AppProtectionBridgeController.new,
);
