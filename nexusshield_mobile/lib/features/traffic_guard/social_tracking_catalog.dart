/// Known behavioral / recommendation API hosts (education + local DNS watchlist).
abstract final class SocialTrackingCatalog {
  static const socialPackages = {
    'com.instagram.android': 'Instagram',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.ss.android.ugc.trill': 'TikTok',
    'com.twitter.android': 'X',
    'com.facebook.katana': 'Facebook',
    'com.facebook.orca': 'Messenger',
    'com.snapchat.android': 'Snapchat',
  };

  static const trackingDomains = [
    'graph.facebook.com',
    'analytics.tiktok.com',
    'metrics.instagram.com',
    'api.recommendations.instagram.com',
    'ads-api.twitter.com',
    'sdk.snapchat.com',
    'firebaselogging.googleapis.com',
    'app-measurement.com',
  ];

  static String? labelForPackage(String packageId) =>
      socialPackages[packageId];

  static bool isSocialPackage(String packageId) =>
      socialPackages.containsKey(packageId);
}
