package ai.nexusshield.nexusshield_mobile

import android.content.Context

/** Per-app DLP policy flags (outbound block, clipboard, background). */
object AppDlpStore {
    private const val PREFS = "nexus_app_dlp"
    private const val OUTBOUND = "outbound_block"
    private const val CLIPBOARD = "clipboard_block"
    private const val BACKGROUND = "background_restrict"

    fun setOutboundBlocked(context: Context, packageId: String, blocked: Boolean) {
        toggleSet(context, OUTBOUND, packageId, blocked)
        if (blocked) {
            NetworkBlockStore.setBlocked(context, packageId, true)
        }
    }

    fun setClipboardBlocked(context: Context, packageId: String, blocked: Boolean) {
        toggleSet(context, CLIPBOARD, packageId, blocked)
    }

    fun setBackgroundRestricted(context: Context, packageId: String, restricted: Boolean) {
        toggleSet(context, BACKGROUND, packageId, restricted)
    }

    fun snapshot(context: Context, packageId: String): Map<String, Boolean> {
        return mapOf(
            "outboundBlocked" to inSet(context, OUTBOUND, packageId),
            "clipboardBlocked" to inSet(context, CLIPBOARD, packageId),
            "backgroundRestricted" to inSet(context, BACKGROUND, packageId),
        )
    }

    fun outboundBlockedPackages(context: Context): Set<String> =
        prefs(context).getStringSet(OUTBOUND, emptySet()) ?: emptySet()

    private fun toggleSet(context: Context, key: String, packageId: String, on: Boolean) {
        val set = prefs(context).getStringSet(key, mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        if (on) set.add(packageId) else set.remove(packageId)
        prefs(context).edit().putStringSet(key, set).apply()
    }

    private fun inSet(context: Context, key: String, packageId: String): Boolean {
        return prefs(context).getStringSet(key, emptySet())?.contains(packageId) == true
    }

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
