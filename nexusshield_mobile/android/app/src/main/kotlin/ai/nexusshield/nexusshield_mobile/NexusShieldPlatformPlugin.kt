package ai.nexusshield.nexusshield_mobile

import android.app.Activity
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.VpnService
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object NexusShieldPlatformPlugin {
    private const val METHOD = "com.nexusshield.guard/platform"
    private const val EVENTS = "com.nexusshield.guard/events"

    private val sensitivePermissions = listOf(
        android.Manifest.permission.CAMERA,
        android.Manifest.permission.RECORD_AUDIO,
        android.Manifest.permission.READ_CONTACTS,
        android.Manifest.permission.ACCESS_FINE_LOCATION,
        android.Manifest.permission.ACCESS_COARSE_LOCATION,
    )

    private var eventSink: EventChannel.EventSink? = null
    private var packageReceiver: BroadcastReceiver? = null
    private var activityRef: Activity? = null
    private var pendingVpnResult: MethodChannel.Result? = null

    const val VPN_PREPARE_REQUEST = 0x4E58

    fun attachActivity(activity: Activity) {
        activityRef = activity
    }

    fun onActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode != VPN_PREPARE_REQUEST) return
        val result = pendingVpnResult ?: return
        pendingVpnResult = null
        val activity = activityRef ?: run {
            result.success(mapOf("granted" to false, "active" to false))
            return
        }
        if (resultCode == Activity.RESULT_OK) {
            startVpnService(activity.applicationContext)
            result.success(mapOf("granted" to true, "active" to true))
        } else {
            result.success(mapOf("granted" to false, "active" to false))
        }
    }

    fun registerWith(flutterEngine: FlutterEngine, context: Context) {
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, METHOD).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanInstalledAppPermissions" -> {
                    try {
                        result.success(scanInstalledAppPermissions(context))
                    } catch (e: Exception) {
                        result.error("scan_failed", e.message, null)
                    }
                }
                "getWifiSecuritySnapshot" -> {
                    result.success(getWifiSecuritySnapshot(context))
                }
                "syncCallBlockList" -> {
                    val numbers =
                        call.argument<List<String>>("numbers") ?: emptyList()
                    CallBlockStore.save(context, numbers)
                    result.success(null)
                }
                "getRemoteAccessSignals" -> {
                    result.success(getRemoteAccessSignals(context))
                }
                "openAppSettings" -> {
                    val packageId = call.argument<String>("packageId")
                    if (packageId.isNullOrBlank()) {
                        result.error("invalid_args", "packageId required", null)
                    } else {
                        openAppSettings(context, packageId)
                        result.success(null)
                    }
                }
                "setPackageNetworkBlocked" -> {
                    val packageId = call.argument<String>("packageId")
                    val blocked = call.argument<Boolean>("blocked") ?: false
                    if (packageId.isNullOrBlank()) {
                        result.error("invalid_args", "packageId required", null)
                    } else {
                        NetworkBlockStore.setBlocked(context, packageId, blocked)
                        result.success(null)
                    }
                }
                "getTrafficGuardSnapshot" -> {
                    result.success(getTrafficGuardSnapshot(context))
                }
                "startLocalTrafficGuard" -> {
                    result.success(startLocalTrafficGuard(context))
                }
                "requestVpnConsent" -> {
                    requestVpnConsent(result)
                }
                "openUsageAccessSettings" -> {
                    openUsageAccessSettings(context)
                    result.success(null)
                }
                "stopLocalTrafficGuard" -> {
                    context.stopService(Intent(context, NexusShieldVpnService::class.java))
                    result.success(null)
                }
                "getBankingShieldSnapshot" -> {
                    result.success(getBankingShieldSnapshot(context))
                }
                "scanInstalledAiClients" -> {
                    result.success(scanInstalledAiClients(context))
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, EVENTS).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                registerPackageReceiver(context)
            }

            override fun onCancel(arguments: Any?) {
                unregisterPackageReceiver(context)
                eventSink = null
            }
        })
    }

    private fun registerPackageReceiver(context: Context) {
        if (packageReceiver != null) return
        packageReceiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                val pkg = intent?.data?.schemeSpecificPart ?: return
                val type = when (intent.action) {
                    Intent.ACTION_PACKAGE_ADDED -> "package_added"
                    Intent.ACTION_PACKAGE_REMOVED -> "package_removed"
                    Intent.ACTION_PACKAGE_CHANGED -> "package_changed"
                    else -> "package_changed"
                }
                eventSink?.success(mapOf("type" to type, "packageId" to pkg))
            }
        }
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addAction(Intent.ACTION_PACKAGE_CHANGED)
            addDataScheme("package")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(packageReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            context.registerReceiver(packageReceiver, filter)
        }
    }

    private fun unregisterPackageReceiver(context: Context) {
        packageReceiver?.let {
            context.unregisterReceiver(it)
            packageReceiver = null
        }
    }

    private fun scanInstalledAppPermissions(context: Context): List<Map<String, Any>> {
        val pm = context.packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val out = mutableListOf<Map<String, Any>>()
        for (app in apps) {
            if (app.packageName == context.packageName) continue
            if (app.flags and ApplicationInfo.FLAG_SYSTEM != 0 &&
                app.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP == 0
            ) {
                continue
            }
            val granted = mutableListOf<String>()
            for (perm in sensitivePermissions) {
                val status = pm.checkPermission(perm, app.packageName)
                if (status == PackageManager.PERMISSION_GRANTED) {
                    granted.add(permissionLabel(perm))
                }
            }
            if (requestsInternet(pm, app.packageName)) {
                granted.add("network")
            }
            val score = computeRiskScore(granted)
            val risk = when {
                score >= 70 -> "high"
                score >= 40 -> "medium"
                else -> "low"
            }
            out.add(
                mapOf(
                    "packageId" to app.packageName,
                    "displayName" to pm.getApplicationLabel(app).toString(),
                    "permissions" to granted,
                    "risk" to risk,
                    "riskScore" to score,
                    "networkBlocked" to NetworkBlockStore.isBlocked(context, app.packageName),
                ),
            )
        }
        return out.sortedByDescending { (it["riskScore"] as Int) }.take(500)
    }

    private fun requestsInternet(pm: PackageManager, packageId: String): Boolean {
        return try {
            @Suppress("DEPRECATION")
            val info = pm.getPackageInfo(packageId, PackageManager.GET_PERMISSIONS)
            info.requestedPermissions?.contains(android.Manifest.permission.INTERNET) == true
        } catch (_: Exception) {
            true
        }
    }

    private fun computeRiskScore(permissions: List<String>): Int {
        var score = 0
        if (permissions.contains("camera")) score += 22
        if (permissions.contains("microphone")) score += 22
        if (permissions.contains("contacts")) score += 18
        if (permissions.contains("location")) score += 20
        if (permissions.contains("network")) score += 8
        if (permissions.contains("camera") && permissions.contains("microphone")) score += 15
        return score.coerceIn(0, 100)
    }

    private fun openAppSettings(context: Context, packageId: String) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = android.net.Uri.parse("package:$packageId")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    private fun getForegroundPackage(context: Context): String? {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return null
        val end = System.currentTimeMillis()
        val begin = end - 120_000
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_BEST, begin, end)
            ?: return null
        return stats.maxByOrNull { it.lastTimeUsed }?.packageName
    }

    private fun getTrafficGuardSnapshot(context: Context): Map<String, Any> {
        val foreground = getForegroundPackage(context) ?: ""
        val blocked = NetworkBlockStore.blockedPackages(context).toList()
        return mapOf(
            "foregroundPackage" to foreground,
            "blockedPackages" to blocked,
            "vpnActive" to NexusShieldVpnService.isRunning,
            "usageStatsGranted" to hasUsageStatsAccess(context),
        )
    }

    private fun hasUsageStatsAccess(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                context.packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                context.packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun startVpnService(context: Context) {
        val intent = Intent(context, NexusShieldVpnService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    private fun startLocalTrafficGuard(context: Context): Map<String, Any> {
        val prepare = VpnService.prepare(context)
        if (prepare != null) {
            return mapOf("needsVpnConsent" to true, "active" to false)
        }
        startVpnService(context)
        return mapOf("needsVpnConsent" to false, "active" to true)
    }

    private fun requestVpnConsent(result: MethodChannel.Result) {
        val activity = activityRef
        if (activity == null) {
            result.error("no_activity", "Activity not available for VPN consent", null)
            return
        }
        val prepare = VpnService.prepare(activity)
        if (prepare == null) {
            startVpnService(activity.applicationContext)
            result.success(mapOf("granted" to true, "active" to true))
            return
        }
        pendingVpnResult = result
        @Suppress("DEPRECATION")
        activity.startActivityForResult(prepare, VPN_PREPARE_REQUEST)
    }

    private fun openUsageAccessSettings(context: Context) {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    private fun getBankingShieldSnapshot(context: Context): Map<String, Any> {
        val remote = getRemoteAccessSignals(context)
        val foreground = getForegroundPackage(context) ?: ""
        val banking = isBankingPackage(foreground)
        return mapOf(
            "foregroundPackage" to foreground,
            "bankingAppActive" to banking,
            "screenCaptureActive" to remote["screenCaptureActive"]!!,
            "overlayAppsCount" to remote["overlayAppsCount"]!!,
            "suspiciousAccessibilityCount" to remote["suspiciousAccessibilityCount"]!!,
            "detail" to remote["detail"]!!,
        )
    }

    private fun isBankingPackage(packageId: String): Boolean {
        if (packageId.isBlank()) return false
        val markers = listOf("bank", "finans", "garanti", "yapikredi", "isbank", "akbank", "ziraat", "vakif", "enpara", "papara")
        val lower = packageId.lowercase()
        return markers.any { lower.contains(it) }
    }

    private val aiClientPackages = mapOf(
        "com.openai.chatgpt" to "ChatGPT",
        "com.anthropic.claude" to "Claude",
        "com.google.android.apps.bard" to "Gemini",
        "com.google.android.apps.genai.gemini" to "Gemini",
        "com.microsoft.copilot" to "Copilot",
        "com.deepseek.chat" to "DeepSeek",
    )

    private fun scanInstalledAiClients(context: Context): List<Map<String, Any>> {
        val pm = context.packageManager
        return aiClientPackages.mapNotNull { (pkg, label) ->
            val installed = try {
                pm.getPackageInfo(pkg, 0)
                true
            } catch (_: Exception) {
                false
            }
            if (!installed) return@mapNotNull null
            mapOf(
                "packageId" to pkg,
                "displayName" to label,
                "canAutoExtractKeys" to false,
                "importHint" to "API anahtarını ilgili uygulamadan kopyalayıp Vault'a güvenle yapıştırın.",
            )
        }
    }

    private fun permissionLabel(perm: String): String = when (perm) {
        android.Manifest.permission.CAMERA -> "camera"
        android.Manifest.permission.RECORD_AUDIO -> "microphone"
        android.Manifest.permission.READ_CONTACTS -> "contacts"
        android.Manifest.permission.ACCESS_FINE_LOCATION,
        android.Manifest.permission.ACCESS_COARSE_LOCATION,
        -> "location"
        else -> "unknown"
    }

    private fun getWifiSecuritySnapshot(context: Context): Map<String, Any> {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork
        val caps = network?.let { cm.getNetworkCapabilities(it) }
        val onWifi = caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true

        if (!onWifi) {
            return mapOf(
                "connected" to false,
                "ssid" to "—",
                "encryption" to "UNKNOWN",
                "captivePortalSuspect" to false,
                "dnsHijackSuspect" to false,
                "arpPoisonSuspect" to false,
                "recommendVpnTunnel" to false,
                "detail" to "Wi‑Fi dışı bağlantı veya kapalı radyo",
            )
        }

        val wm = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        @Suppress("DEPRECATION")
        val info = wm.connectionInfo
        var ssid = info.ssid?.replace("\"", "") ?: "Wi‑Fi"
        if (ssid == "<unknown ssid>") ssid = "Wi‑Fi"

        var encryption = "WPA2"
        var open = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val scan = wm.scanResults.firstOrNull { it.SSID == ssid || it.SSID == info.ssid?.replace("\"", "") }
            val capabilities = scan?.capabilities ?: ""
            encryption = when {
                capabilities.contains("WPA3") -> "WPA3"
                capabilities.contains("WPA2") -> "WPA2"
                capabilities.contains("WPA") -> "WPA"
                capabilities.contains("WEP") -> "WEP"
                else -> "OPEN"
            }
            open = encryption == "OPEN"
        }

        val dnsSuspect = ssid.lowercase().contains("free") || ssid.lowercase().contains("public")
        val arpSuspect = open
        val captive = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_CAPTIVE_PORTAL) == true

        return mapOf(
            "connected" to true,
            "ssid" to ssid,
            "encryption" to encryption,
            "captivePortalSuspect" to captive,
            "dnsHijackSuspect" to dnsSuspect,
            "arpPoisonSuspect" to arpSuspect,
            "recommendVpnTunnel" to (open || dnsSuspect || captive),
            "detail" to when {
                open -> "Açık (şifresiz) ağ — VPN önerilir"
                dnsSuspect -> "Halka açık SSID deseni — DNS riski"
                captive -> "Captive portal algılandı"
                else -> "$encryption şifreleme"
            },
        )
    }

    private fun getRemoteAccessSignals(context: Context): Map<String, Any> {
        val accessibility = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: ""
        val services = accessibility.split(":").filter { it.isNotBlank() }
        val suspicious = services.count { !it.contains(context.packageName) }

        val overlayCount = countOverlayCapableApps(context)

        return mapOf(
            "screenCaptureActive" to false,
            "suspiciousAccessibilityCount" to suspicious,
            "overlayAppsCount" to overlayCount,
            "detail" to if (suspicious > 0) {
                "$suspicious erişilebilirlik servisi etkin"
            } else {
                "Belirgin uzaktan erişim sinyali yok"
            },
        )
    }

    private fun countOverlayCapableApps(context: Context): Int {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val pm = context.packageManager
        var count = 0
        for (app in pm.getInstalledApplications(PackageManager.GET_META_DATA)) {
            if (app.packageName == context.packageName) continue
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_SYSTEM_ALERT_WINDOW,
                    app.uid,
                    app.packageName,
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_SYSTEM_ALERT_WINDOW,
                    app.uid,
                    app.packageName,
                )
            }
            if (mode == AppOpsManager.MODE_ALLOWED) count++
        }
        return count
    }
}

object CallBlockStore {
    private const val PREFS = "nexus_call_block"
    private const val KEY = "numbers"

    fun save(context: Context, numbers: List<String>) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putStringSet(KEY, numbers.toSet())
            .apply()
    }

    fun load(context: Context): Set<String> =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getStringSet(KEY, emptySet()) ?: emptySet()

    fun isBlocked(context: Context, number: String?): Boolean {
        if (number.isNullOrBlank()) return false
        val normalized = number.filter { it.isDigit() || it == '+' }
        return load(context).any { blocked ->
            val b = blocked.filter { it.isDigit() || it == '+' }
            normalized.endsWith(b.takeLast(10)) || b.endsWith(normalized.takeLast(10))
        }
    }
}
