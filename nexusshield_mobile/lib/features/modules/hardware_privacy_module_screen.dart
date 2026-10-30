import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/nexus_navigation.dart';
import '../../theme/app_theme.dart';
import '../live_shield/privacy_pillars_provider.dart';
import '../remote_access/remote_access_provider.dart';

class HardwarePrivacyModuleScreen extends ConsumerWidget {
  const HardwarePrivacyModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pillars = ref.watch(privacyPillarsProvider);
    final remote = ref.watch(remoteAccessProvider);

    return NexusSubScreenScaffold(
      title: '360° Donanım & Mahremiyet',
      subtitle: 'Kamera • Mikrofon • Pano',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tile(Icons.videocam_outlined, 'Kamera & ekran', remote.detail, !remote.screenCaptureActive),
          _tile(Icons.mic_none, 'Mikrofon', pillars.callDetail, !pillars.callDetail.contains('erişilebilirlik')),
          _tile(Icons.content_paste, 'Pano & mesaj', pillars.messagingDetail, !pillars.messagingDetail.contains('bindirme')),
          _tile(Icons.photo_library_outlined, 'Medya erişimi', '${pillars.mediaApps} uygulama', pillars.mediaApps < 8),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref.read(privacyPillarsProvider.notifier).refresh(),
            icon: const Icon(Icons.sensors),
            label: const Text('Donanım durumunu yenile'),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String detail, bool ok) {
    final color = ok ? NexusBrand.neonGreen : NexusBrand.amber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CyberCard(
      borderColor: color,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(detail, style: const TextStyle(fontSize: 12, color: NexusBrand.muted)),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
