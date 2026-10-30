enum AppCriticalityClass {
  finance,
  messaging,
  social,
  ai,
  other;

  String get labelTr => switch (this) {
        AppCriticalityClass.finance => 'Finans & Bankacılık',
        AppCriticalityClass.messaging => 'Kritik İletişim',
        AppCriticalityClass.social => 'Sosyal Medya & İçerik',
        AppCriticalityClass.ai => 'Yapay Zeka (AI)',
        AppCriticalityClass.other => 'Diğer',
      };
}

class AppCatalogEntry {
  const AppCatalogEntry({
    required this.packageId,
    required this.displayName,
    required this.criticality,
  });

  final String packageId;
  final String displayName;
  final AppCriticalityClass criticality;
}

abstract final class AppCatalog {
  static const _rules = <String, AppCriticalityClass>{
    'com.whatsapp': AppCriticalityClass.messaging,
    'org.telegram.messenger': AppCriticalityClass.messaging,
    'org.thoughtcrime.securesms': AppCriticalityClass.messaging,
    'com.instagram.android': AppCriticalityClass.social,
    'com.zhiliaoapp.musically': AppCriticalityClass.social,
    'com.twitter.android': AppCriticalityClass.social,
    'com.google.android.youtube': AppCriticalityClass.social,
    'com.openai.chatgpt': AppCriticalityClass.ai,
    'com.anthropic.claude': AppCriticalityClass.ai,
    'com.google.android.apps.bard': AppCriticalityClass.ai,
    'com.microsoft.copilot': AppCriticalityClass.ai,
    'com.garanti.cepsubesi': AppCriticalityClass.finance,
    'com.ykb.android': AppCriticalityClass.finance,
    'com.akbank.android.apps.akbank_direkt': AppCriticalityClass.finance,
    'com.tmobtech.vakifbank.mobile': AppCriticalityClass.finance,
    'com.ziraat.ziraatmobil': AppCriticalityClass.finance,
    'com.papara': AppCriticalityClass.finance,
  };

  static AppCriticalityClass classify(String packageId) {
    if (_rules.containsKey(packageId)) return _rules[packageId]!;
    final lower = packageId.toLowerCase();
    if (lower.contains('bank') ||
        lower.contains('finans') ||
        lower.contains('crypto') ||
        lower.contains('wallet')) {
      return AppCriticalityClass.finance;
    }
    if (lower.contains('chat') ||
        lower.contains('message') ||
        lower.contains('whatsapp')) {
      return AppCriticalityClass.messaging;
    }
    if (lower.contains('tiktok') ||
        lower.contains('instagram') ||
        lower.contains('facebook')) {
      return AppCriticalityClass.social;
    }
    if (lower.contains('openai') ||
        lower.contains('claude') ||
        lower.contains('gemini') ||
        lower.contains('copilot')) {
      return AppCriticalityClass.ai;
    }
    return AppCriticalityClass.other;
  }

  static String displayNameFor(String packageId, String fallback) {
    return _rules.containsKey(packageId) ? fallback : fallback;
  }
}
