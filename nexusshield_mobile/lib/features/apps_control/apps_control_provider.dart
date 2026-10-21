import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/nexus_platform_bridge.dart';
import '../live_shield/live_feed_provider.dart';
import '../permissions/permission_scan_provider.dart';

class AppsControlController extends Notifier<void> {
  @override
  void build() {}

  Future<void> openSystemSettings(String packageId) async {
    await NexusPlatformBridge.openAppSettings(packageId);
  }

  Future<void> setDlp({
    required String packageId,
    required String displayName,
    required bool outboundBlocked,
    required bool clipboardBlocked,
    required bool backgroundRestricted,
  }) async {
    await NexusPlatformBridge.setAppDlpPolicy(
      packageId: packageId,
      outboundBlocked: outboundBlocked,
      clipboardBlocked: clipboardBlocked,
      backgroundRestricted: backgroundRestricted,
    );
    ref.read(liveFeedProvider.notifier).push(
          outboundBlocked
              ? '$displayName: veri çıkışı kesildi (DLP)'
              : '$displayName: DLP politikası güncellendi',
        );
    await ref.read(permissionScanProvider.notifier).scan();
  }
}

final appsControlProvider =
    NotifierProvider<AppsControlController, void>(AppsControlController.new);
