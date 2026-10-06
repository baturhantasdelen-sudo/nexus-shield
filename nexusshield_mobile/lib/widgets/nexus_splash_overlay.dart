import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Brief in-app fade while Rust/telemetry init; brand logo is native splash only.
class NexusSplashOverlay extends StatefulWidget {
  const NexusSplashOverlay({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 900),
  });

  final Widget child;
  final Duration duration;

  @override
  State<NexusSplashOverlay> createState() => _NexusSplashOverlayState();
}

class _NexusSplashOverlayState extends State<NexusSplashOverlay> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.duration, () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_showSplash)
          AnimatedOpacity(
            opacity: _showSplash ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            child: ColoredBox(
              color: NexusBrand.deepSlate,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Personal Guard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: NexusBrand.metallicLight,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
