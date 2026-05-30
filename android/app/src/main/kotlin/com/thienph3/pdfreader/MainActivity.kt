package com.thienph3.pdfreader

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.thienph3.pdfreader/intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.thienph3.pdfreader/tts")
            .setMethodCallHandler { call, result ->
                if (call.method == "openTtsSettings") {
                    try {
                        val intent = Intent("com.android.settings.TTS_SETTINGS")
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            startActivity(Intent(Settings.ACTION_SETTINGS))
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("ERROR", e2.message, null)
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getOpenedFile") {
                    val path = handleIntent(intent)
                    result.success(path)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun handleIntent(intent: Intent?): String? {
        if (intent == null) return null
        if (intent.action != Intent.ACTION_VIEW) return null

        val uri = intent.data ?: return null

        // If it's a file:// URI, return path directly
        if (uri.scheme == "file") {
            return uri.path
        }

        // For content:// URIs, copy to app cache
        try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val fileName = "opened_${System.currentTimeMillis()}.pdf"
            val outFile = File(cacheDir, fileName)
            FileOutputStream(outFile).use { output ->
                inputStream.copyTo(output)
            }
            inputStream.close()
            return outFile.absolutePath
        } catch (e: Exception) {
            return null
        }
    }
}
