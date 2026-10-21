import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../apps_control/apps_permissions_hub_screen.dart';
import 'active_shield_core.dart';
import 'live_feed_provider.dart';
import 'privacy_pillars_provider.dart';

class LiveShieldScreen extends ConsumerWidget {
  const LiveShieldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(liveFeedProvider);
    final pillars = ref.watch(privacyPillarsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const ActiveShieldCore(),
        const SizedBox(height: 16),
        Text(
          '360° Koruma Sütunları',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        _PillarGrid(pillars: pillars),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Canlı denetim akışı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AppsPermissionsHubScreen(),
                ),
              ),
              icon: const Icon(Icons.apps_outlined, size: 18),
              label: const Text('Uygulama DLP'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CyberCard(
          padding: const EdgeInsets.all(12),
          borderColor: NexusBrand.cyberCyan,
          borderOpacity: 0.25,
          child: SizedBox(
            height: 220,
            child: feed.isEmpty
                ? const Center(
                    child: Text(
                      'Kalkanı açın — olaylar burada akacak',
                      style: TextStyle(color: NexusBrand.muted),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: feed.length,
                    itemBuilder: (context, i) {
                      final line = feed[i];
                      final ts = line.at.toLocal().toString().split('.').first;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '[$ts] ${line.text}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            height: 1.35,
                            color: NexusBrand.neonGreen,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _PillarGrid extends StatelessWidget {
  const _PillarGrid({required this.pillars});

  final PrivacyPillarsState pillars;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Pillar(
        icon: Icons.wifi_tethering,
        title: 'Ağ & Wi‑Fi',
        detail: pillars.wifiDetail,
        ok: pillars.wifiSecure,
      ),
      _Pillar(
        icon: Icons.mic_external_on_outlined,
        title: 'Arama & Mikrofon',
        detail: pillars.callDetail,
        ok: !pillars.callDetail.contains('erişilebilirlik'),
      ),
      _Pillar(
        icon: Icons.chat_bubble_outline,
        title: 'Yazışma & Pano',
        detail: pillars.messagingDetail,
        ok: !pillars.messagingDetail.contains('bindirme'),
      ),
      _Pillar(
        icon: Icons.photo_library_outlined,
        title: 'Fotoğraf & Medya',
        detail: '${pillars.mediaApps} uygulama galeri erişimli',
        ok: pillars.mediaApps < 8,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: items,
    );
  }
}

class _Pillar extends StatelessWidget {
  const _Pillar({
    required this.icon,
    required this.title,
    required this.detail,
    required this.ok,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? NexusBrand.neonGreen : NexusBrand.amber;
    return CyberCard(
      borderColor: color,
      borderOpacity: 0.35,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              detail,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: NexusBrand.muted),
            ),
          ),
        ],
      ),
    );
  }
}
