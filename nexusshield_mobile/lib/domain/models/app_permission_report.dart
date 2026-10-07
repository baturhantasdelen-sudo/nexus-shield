enum SensitivePermissionKind {
  camera,
  microphone,
  contacts,
  location,
  network,
  unknown;

  static SensitivePermissionKind fromNative(String raw) {
    return switch (raw.toLowerCase()) {
      'camera' => SensitivePermissionKind.camera,
      'microphone' => SensitivePermissionKind.microphone,
      'contacts' => SensitivePermissionKind.contacts,
      'location' => SensitivePermissionKind.location,
      'network' => SensitivePermissionKind.network,
      _ => SensitivePermissionKind.unknown,
    };
  }

  String get labelTr => switch (this) {
        SensitivePermissionKind.camera => 'Kamera',
        SensitivePermissionKind.microphone => 'Mikrofon',
        SensitivePermissionKind.contacts => 'Rehber',
        SensitivePermissionKind.location => 'Konum',
        SensitivePermissionKind.network => 'Ağ erişimi',
        SensitivePermissionKind.unknown => 'Diğer',
      };
}

enum AppPermissionRiskTier {
  low,
  medium,
  high;

  static AppPermissionRiskTier fromNative(String raw) {
    return switch (raw.toLowerCase()) {
      'high' => AppPermissionRiskTier.high,
      'medium' => AppPermissionRiskTier.medium,
      _ => AppPermissionRiskTier.low,
    };
  }

  static AppPermissionRiskTier fromScore(int score) {
    if (score >= 70) return AppPermissionRiskTier.high;
    if (score >= 40) return AppPermissionRiskTier.medium;
    return AppPermissionRiskTier.low;
  }
}

class AppPermissionReport {
  const AppPermissionReport({
    required this.packageId,
    required this.displayName,
    required this.permissions,
    required this.riskTier,
    required this.riskScore,
    this.networkBlocked = false,
  });

  final String packageId;
  final String displayName;
  final List<SensitivePermissionKind> permissions;
  final AppPermissionRiskTier riskTier;
  final int riskScore;
  final bool networkBlocked;

  bool get isRisky =>
      riskTier == AppPermissionRiskTier.high ||
      riskTier == AppPermissionRiskTier.medium;

  bool get hasNetworkAccess =>
      permissions.contains(SensitivePermissionKind.network);

  factory AppPermissionReport.fromMap(Map<String, dynamic> map) {
    final permsRaw = map['permissions'] as List<dynamic>? ?? const [];
    final perms = permsRaw
        .map((e) => SensitivePermissionKind.fromNative('$e'))
        .where((p) => p != SensitivePermissionKind.unknown)
        .toList(growable: false);
    final score = (map['riskScore'] as num?)?.toInt() ??
        _scoreFromLegacy('${map['risk'] ?? 'low'}', perms.length);
    return AppPermissionReport(
      packageId: '${map['packageId'] ?? ''}',
      displayName: '${map['displayName'] ?? map['packageId'] ?? 'App'}',
      permissions: perms,
      riskTier: AppPermissionRiskTier.fromNative('${map['risk'] ?? 'low'}'),
      riskScore: score,
      networkBlocked: map['networkBlocked'] == true,
    );
  }

  AppPermissionReport copyWith({bool? networkBlocked}) {
    return AppPermissionReport(
      packageId: packageId,
      displayName: displayName,
      permissions: permissions,
      riskTier: riskTier,
      riskScore: riskScore,
      networkBlocked: networkBlocked ?? this.networkBlocked,
    );
  }

  static int _scoreFromLegacy(String risk, int permCount) {
    return switch (risk.toLowerCase()) {
      'high' => 75 + permCount.clamp(0, 3) * 5,
      'medium' => 45 + permCount.clamp(0, 2) * 5,
      _ => 20 + permCount * 5,
    };
  }
}
