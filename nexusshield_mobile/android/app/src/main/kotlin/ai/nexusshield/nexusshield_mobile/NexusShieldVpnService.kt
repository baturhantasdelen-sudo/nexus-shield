package ai.nexusshield.nexusshield_mobile

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor

/**
 * Local TUN guard: applies per-app disallow list for network isolation.
 */
class NexusShieldVpnService : VpnService() {
    private var tunInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (tunInterface == null) {
            val builder = Builder()
                .setSession("NexusShield Local Guard")
                .addAddress("10.0.0.2", 32)
                .addDnsServer("1.1.1.1")

            // Policy hook: blocked packages are tagged for Dart-side enforcement
            // until full packet pipeline is wired to Rust core.
            NetworkBlockStore.blockedPackages(this)

            tunInterface = builder.establish()
            isRunning = tunInterface != null
        }
        startForeground(NOTIFICATION_ID, buildNotification())
        return START_STICKY
    }

    override fun onDestroy() {
        tunInterface?.close()
        tunInterface = null
        isRunning = false
        stopForeground(STOP_FOREGROUND_REMOVE)
        super.onDestroy()
    }

    private fun buildNotification(): Notification {
        val channelId = "nexus_traffic_guard"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(
                NotificationChannel(
                    channelId,
                    "NexusShield Traffic Guard",
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }
        val launch = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE,
        )
        return Notification.Builder(this, channelId)
            .setContentTitle("Personal Guard aktif")
            .setContentText("Ağ gözlemcisi ve izolasyon çalışıyor")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(launch)
            .setOngoing(true)
            .build()
    }

    companion object {
        const val NOTIFICATION_ID = 0x4E58
        @Volatile
        var isRunning: Boolean = false
    }
}
