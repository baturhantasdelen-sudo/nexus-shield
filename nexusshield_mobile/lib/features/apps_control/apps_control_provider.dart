import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../permissions/permission_scan_provider.dart';

class AppsControlController extends Notifier<void> {
  @override
  void build() {}

  Future<void> openSystemSettings(String packageId) async {
    await NexusPlatformBridge.openAppSettings(packageId);
  }

  Future<void> toggleNetworkBlock({
    required String packageId,
    required bool blocked,
  }) async {
    await NexusPlatformBridge.setPackageNetworkBlocked(
      packageId: packageId,
      blocked: blocked,
    );
    await ref.read(permissionScanProvider.notifier).scan();
  }
}

final appsControlProvider =
    NotifierProvider<AppsControlController, void>(AppsControlController.new);
