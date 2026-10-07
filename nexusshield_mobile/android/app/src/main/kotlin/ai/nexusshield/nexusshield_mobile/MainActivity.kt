package ai.nexusshield.nexusshield_mobile

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NexusShieldPlatformPlugin.registerWith(flutterEngine, applicationContext)
        NexusShieldPlatformPlugin.attachActivity(this)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        NexusShieldPlatformPlugin.onActivityResult(requestCode, resultCode)
    }
}
