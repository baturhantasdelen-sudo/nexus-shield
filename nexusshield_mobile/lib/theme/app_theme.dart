import 'package:flutter/material.dart';

/// NexusShield design tokens — aligned with lockup navy / teal / gold accents.
abstract final class NexusBrand {
  static const logoLockupAsset = 'assets/icon/nexus_logo.png';
  static const logoEmblemAsset = 'assets/icon/nexus_emblem.png';
  static const brandTagline = 'Personal Guard Nexus Shield';

  /// Core shell — deep navy from lockup (#0B132B family).
  static const deepNavy = Color(0xFF0B132B);
  static const deepSlate = deepNavy;
  static const surfaceElevated = Color(0xFF121C32);
  static const glassPanel = Color(0xFF172240);
  static const glassPanelOpacity = 0.88;

  static const metallicLight = Color(0xFFE8EEF4);
  static const tealAccent = Color(0xFF5EEAD4);
  static const cyberCyan = Color(0xFF67E8F9);
  static const neonGreen = Color(0xFF2DD4BF);
  static const goldAccent = Color(0xFFEAB308);
  static const amber = goldAccent;
  static const alertRed = Color(0xFFF87171);
  static const muted = Color(0xFF94A3B8);

  static const cardRadius = 20.0;
  static Border cyberBorder({double opacity = 0.1, double width = 1}) =>
      Border.all(color: tealAccent.withValues(alpha: opacity), width: width);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NexusBrand.deepNavy,
    colorScheme: ColorScheme.fromSeed(
      seedColor: NexusBrand.tealAccent,
      brightness: Brightness.dark,
      primary: NexusBrand.tealAccent,
      secondary: NexusBrand.cyberCyan,
      surface: NexusBrand.glassPanel,
      error: NexusBrand.alertRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: NexusBrand.deepNavy,
      foregroundColor: NexusBrand.metallicLight,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NexusBrand.cardRadius),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: NexusBrand.metallicLight, height: 1.4),
      bodyMedium: TextStyle(color: NexusBrand.metallicLight, height: 1.4),
      titleLarge: TextStyle(
        color: NexusBrand.metallicLight,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NexusBrand.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: NexusBrand.muted),
      hintStyle: const TextStyle(color: NexusBrand.muted),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? NexusBrand.tealAccent
            : NexusBrand.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? NexusBrand.tealAccent.withValues(alpha: 0.32)
            : const Color(0xFF334155),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: NexusBrand.surfaceElevated.withValues(alpha: 0.98),
      indicatorColor: NexusBrand.tealAccent.withValues(alpha: 0.22),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      elevation: 12,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: selected ? NexusBrand.tealAccent : NexusBrand.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? NexusBrand.tealAccent : NexusBrand.muted,
          size: 24,
        );
      }),
    ),
  );
}

/// Soft elevated surface — warm corners, subtle depth (replaces harsh cyber panels).
class CyberCard extends StatelessWidget {
  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.borderOpacity = 0.08,
    this.backgroundOpacity = NexusBrand.glassPanelOpacity,
    this.glowColor,
    this.glowStrength = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double borderOpacity;
  final double backgroundOpacity;
  final Color? glowColor;
  final double glowStrength;

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? NexusBrand.tealAccent;
    return Material(
      color: NexusBrand.glassPanel.withValues(alpha: backgroundOpacity),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NexusBrand.cardRadius),
        side: BorderSide(
          color: border.withValues(alpha: borderOpacity),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}
