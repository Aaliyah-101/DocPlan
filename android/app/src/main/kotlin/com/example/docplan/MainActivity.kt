package com.example.docplan

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.media.AudioAttributes
import android.net.Uri
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ Force hardware acceleration for Google Maps
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )

        // ✅ Optimize for Google Maps rendering
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // ✅ Create notification channel for Android 8.0+
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val channelId = "emergency_alerts"
                val channelName = "Emergency Alerts"

                // ✅ Set custom sound URI
                val soundUri = Uri.parse("android.resource://$packageName/raw/emergency_alarm")

                val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()

                val channel = NotificationChannel(
                    channelId,
                    channelName,
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Plays loud emergency alarm for doctor notifications"
                    setSound(soundUri, audioAttributes)
                    enableLights(true)
                    enableVibration(true)
                    // ✅ Additional notification settings
                    lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                    setBypassDnd(true) // Bypass Do Not Disturb
                }

                val manager = getSystemService(NotificationManager::class.java)
                manager?.createNotificationChannel(channel)

                // ✅ Log success for debugging
                println("✅ Emergency notification channel created successfully")

            } catch (e: Exception) {
                // ✅ Handle any errors in notification channel creation
                println("❌ Error creating notification channel: ${e.message}")
                e.printStackTrace()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // ✅ Ensure hardware acceleration is maintained
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        // ✅ Clean up any resources
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}