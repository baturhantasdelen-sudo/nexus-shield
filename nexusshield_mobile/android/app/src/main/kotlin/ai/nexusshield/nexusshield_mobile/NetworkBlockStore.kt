package ai.nexusshield.nexusshield_mobile

import android.content.Context

object NetworkBlockStore {
    private const val PREFS = "nexus_network_block"
    private const val KEY = "blocked_packages"

    fun setBlocked(context: Context, packageId: String, blocked: Boolean) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val set = prefs.getStringSet(KEY, mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        if (blocked) {
            set.add(packageId)
        } else {
            set.remove(packageId)
        }
        prefs.edit().putStringSet(KEY, set).apply()
    }

    fun isBlocked(context: Context, packageId: String): Boolean {
        val set = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getStringSet(KEY, emptySet()) ?: emptySet()
        return set.contains(packageId)
    }

    fun blockedPackages(context: Context): Set<String> =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getStringSet(KEY, emptySet()) ?: emptySet()
}
