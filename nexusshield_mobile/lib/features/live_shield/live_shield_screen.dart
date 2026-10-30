import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/nexus_navigation.dart';
import '../../theme/app_theme.dart';
import '../auto_protection/auto_protection_wizard_provider.dart';
import '../modules/ai_vault_module_screen.dart';
import '../modules/app_bridge_module_screen.dart';
import '../modules/hardware_privacy_module_screen.dart';
import '../modules/network_attack_shield_screen.dart';
import 'active_shield_core.dart';
import 'live_feed_provider.dart';
import 'privacy_pillars_provider.dart';

class LiveShieldScreen extends ConsumerWidget {
  const LiveShieldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(liveFeedProvider);
    final pillars = ref.watch(privacyPillarsProvider);
    final wizard = ref.watch(autoProtectionWizardProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const ActiveShieldCore(),
        if (wizard.step != AutoProtectionStep.idle) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: wizard.progress),
          const SizedBox(height: 6),
          Text(
            wizard.message,
            style: const TextStyle(fontSize: 12, color: NexusBrand.cyberCyan),
          ),
        ],
        const SizedBox(height: 12),
        _SecurityStatusStrip(pillars: pillars),
        const SizedBox(height: 20),
        Text(
          'Komuta modülleri',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        const _CommandModuleGrid(),
        const SizedBox(height: 16),
        ExpansionTile(
          initiallyExpanded: feed.isNotEmpty,
          tilePadding: EdgeInsets.zero,
          title: Text(
            'Canlı müdahale günlüğü',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          subtitle: const Text(
            'Engellenen tehditler ve doğrulanan bağlantılar',
            style: TextStyle(fontSize: 12, color: NexusBrand.muted),
          ),
          children: [
            CyberCard(
              padding: const EdgeInsets.all(12),
              borderColor: NexusBrand.cyberCyan,
              borderOpacity: 0.25,
              child: SizedBox(
                height: 200,
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
        ),
      ],
    );
  }
}

class _SecurityStatusStrip extends StatelessWidget {
  const _SecurityStatusStrip({required this.pillars});

  final PrivacyPillarsState pillars;

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderOpacity: 0.2,
      child: Row(
        children: [
          _chip(Icons.wifi, pillars.wifiSecure),
          _chip(Icons.vpn_key_outlined, pillars.vpnActive),
          _chip(Icons.mic_none, !pillars.callDetail.contains('erişilebilirlik')),
          _chip(Icons.chat_outlined, !pillars.messagingDetail.contains('bindirme')),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, bool ok) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: ok ? NexusBrand.neonGreen : NexusBrand.amber),
          const SizedBox(height: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? NexusBrand.neonGreen : NexusBrand.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandModuleGrid extends StatelessWidget {
  const _CommandModuleGrid();

  @override
  Widget build(BuildContext context) {
    final modules = [
      _ModuleDef(
        icon: Icons.shield_moon_outlined,
        title: 'Ağ & iOS/Android Siber Saldırı Kalkanı',
        screen: const NetworkAttackShieldScreen(),
      ),
      _ModuleDef(
        icon: Icons.hub_outlined,
        title: 'Otonom Uygulama Köprüsü',
        subtitle: 'WhatsApp, Banka & Sosyal',
        screen: const AppBridgeModuleScreen(),
      ),
      _ModuleDef(
        icon: Icons.psychology_outlined,
        title: 'Yapay Zeka & API Kasa Koruması',
        screen: const AiVaultModuleScreen(),
      ),
      _ModuleDef(
        icon: Icons.privacy_tip_outlined,
        title: '360° Donanım & Mahremiyet',
        subtitle: 'Kamera / Mikrofon / Pano',
        screen: const HardwarePrivacyModuleScreen(),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.92,
      children: modules
          .map(
            (m) => _CommandCard(
              module: m,
              onTap: () => pushNexusSubRoute(context, m.screen),
            ),
          )
          .toList(),
    );
  }
}

class _ModuleDef {
  const _ModuleDef({
    required this.icon,
    required this.title,
    required this.screen,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget screen;
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({required this.module, required this.onTap});

  final _ModuleDef module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NexusBrand.cardRadius),
        child: CyberCard(
          padding: const EdgeInsets.all(12),
          borderColor: NexusBrand.cyberCyan,
          borderOpacity: 0.28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(module.icon, color: NexusBrand.cyberCyan, size: 26),
              const SizedBox(height: 10),
              Text(
                module.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.25),
              ),
              if (module.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  module.subtitle!,
                  style: const TextStyle(fontSize: 10, color: NexusBrand.muted),
                ),
              ],
              const Spacer(),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: NexusBrand.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
