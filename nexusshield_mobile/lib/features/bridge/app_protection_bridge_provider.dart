import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../../domain/models/app_permission_report.dart';
import '../live_shield/live_feed_provider.dart';
import '../permissions/permission_scan_provider.dart';
import 'app_catalog.dart';

class BridgeEntry {
  const BridgeEntry({required this.report});

  final AppPermissionReport report;

  AppCriticalityClass get criticality => AppCatalog.classify(report.packageId);
}

class AppProtectionBridgeState {
  const AppProtectionBridgeState({
    this.entries = const [],
    this.pendingPrompt,
    this.bridgingAll = false,
  });

  final List<BridgeEntry> entries;
  final BridgeEntry? pendingPrompt;
  final bool bridgingAll;

  int get unbridgedLaunchableCount =>
      entries.where((e) => e.report.launchable && !e.report.bridged).length;

  AppProtectionBridgeState copyWith({
    List<BridgeEntry>? entries,
    BridgeEntry? pendingPrompt,
    bool clearPrompt = false,
    bool? bridgingAll,
  }) {
    return AppProtectionBridgeState(
      entries: entries ?? this.entries,
      pendingPrompt: clearPrompt ? null : (pendingPrompt ?? this.pendingPrompt),
      bridgingAll: bridgingAll ?? this.bridgingAll,
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
    final entries = reports.map((r) => BridgeEntry(report: r)).toList(growable: false);
    BridgeEntry? prompt;
    for (final e in entries) {
      if (!e.report.bridged &&
          prompt == null &&
          e.criticality != AppCriticalityClass.social &&
          e.criticality != AppCriticalityClass.other) {
        prompt = e;
      }
    }
    state = AppProtectionBridgeState(entries: entries, pendingPrompt: prompt);
  }

  Future<void> enableBridge(BridgeEntry entry) async {
    final r = entry.report;
    await NexusPlatformBridge.setAppProtectionBridge(
      packageId: r.packageId,
      enabled: true,
    );
    ref.read(liveFeedProvider.notifier).push(
          '${r.displayName}: Koruma köprüsü aktif • korunuyor',
        );
    await syncFromDevice();
    state = state.copyWith(clearPrompt: true);
  }

  Future<void> bridgeAllLaunchable() async {
    state = state.copyWith(bridgingAll: true);
    final targets = state.entries
        .where((e) => e.report.launchable && !e.report.bridged)
        .toList(growable: false);
    for (final e in targets) {
      await NexusPlatformBridge.setAppProtectionBridge(
        packageId: e.report.packageId,
        enabled: true,
      );
    }
    ref.read(liveFeedProvider.notifier).push(
          'Toplu köprü: ${targets.length} uygulama koruma altına alındı',
        );
    await syncFromDevice();
    state = state.copyWith(bridgingAll: false);
  }

  Future<void> addManualBridgeTarget(String packageOrBundleId, String displayName) async {
    await NexusPlatformBridge.setAppProtectionBridge(
      packageId: packageOrBundleId.trim(),
      enabled: true,
    );
    ref.read(liveFeedProvider.notifier).push(
          '$displayName manuel kalkan köprüsüne eklendi',
        );
    await syncFromDevice();
  }

  void dismissPrompt() => state = state.copyWith(clearPrompt: true);
}

final appProtectionBridgeProvider =
    NotifierProvider<AppProtectionBridgeController, AppProtectionBridgeState>(
  AppProtectionBridgeController.new,
);
