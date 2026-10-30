package ai.nexusshield.nexusshield_mobile

import android.content.Context

object AppBridgeStore {
    private const val PREFS = "nexus_app_bridge"
    private const val KEY = "bridged_packages"

    fun setBridged(context: Context, packageId: String, bridged: Boolean) {
        val set = prefs(context).getStringSet(KEY, mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        if (bridged) set.add(packageId) else set.remove(packageId)
        prefs(context).edit().putStringSet(KEY, set).apply()
    }

    fun isBridged(context: Context, packageId: String): Boolean =
        prefs(context).getStringSet(KEY, emptySet())?.contains(packageId) == true

    fun bridgedPackages(context: Context): Set<String> =
        prefs(context).getStringSet(KEY, emptySet()) ?: emptySet()

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
