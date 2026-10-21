import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shield_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nexus_minimal_tech_logo.dart';
import '../traffic_guard/traffic_guard_setup_sheet.dart';
import '../traffic_guard/traffic_guard_provider.dart';

class ActiveShieldCore extends ConsumerStatefulWidget {
  const ActiveShieldCore({super.key});

  @override
  ConsumerState<ActiveShieldCore> createState() => _ActiveShieldCoreState();
}

class _ActiveShieldCoreState extends ConsumerState<ActiveShieldCore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radar;

  @override
  void initState() {
    super.initState();
    _radar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(shieldStatusProvider);
    final guard = ref.watch(trafficGuardProvider);

    return CyberCard(
      borderColor: active ? NexusBrand.cyberCyan : NexusBrand.muted,
      borderOpacity: active ? 0.45 : 0.2,
      glowColor: NexusBrand.cyberCyan,
      glowStrength: active ? 0.12 : 0,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (active)
                  AnimatedBuilder(
                    animation: _radar,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size.square(200),
                        painter: _RadarPainter(_radar.value),
                      );
                    },
                  ),
                NexusMinimalTechLogo(size: 96, active: active),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            active ? 'Tam Koruma Aktif' : 'Kalkanı Devreye Al',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: NexusBrand.metallicLight,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            active
                ? 'DLP • Wi‑Fi • Arama • Mesaj • Medya denetleniyor'
                : 'Tek dokunuşla canlı kişisel güvenlik kalkanı',
            textAlign: TextAlign.center,
            style: const TextStyle(color: NexusBrand.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(shieldStatusProvider.notifier).toggle();
              if (!context.mounted) return;
              if (ref.read(shieldSettingsProvider).localVpn) {
                final needs = ref.read(trafficGuardProvider.notifier).needsSetup;
                if (needs) {
                  await showTrafficGuardSetupSheet(context);
                } else {
                  await ref.read(trafficGuardProvider.notifier).refresh();
                }
              }
            },
            icon: Icon(active ? Icons.verified_user : Icons.shield_outlined),
            label: Text(active ? 'Korumayı sürdür' : 'Tam korumayı aç'),
          ),
          if (guard.needsVpnConsent && active)
            TextButton(
              onPressed: () => showTrafficGuardSetupSheet(context),
              child: const Text('VPN / Usage Stats kurulumu'),
            ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(
        c,
        r * i / 3,
        Paint()
          ..color = NexusBrand.cyberCyan.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    final sweep = Paint()
      ..shader = SweepGradient(
        colors: [
          NexusBrand.cyberCyan.withValues(alpha: 0),
          NexusBrand.cyberCyan.withValues(alpha: 0.35),
        ],
        stops: const [0.7, 1.0],
        transform: GradientRotation(t * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, sweep);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.t != t;
}
