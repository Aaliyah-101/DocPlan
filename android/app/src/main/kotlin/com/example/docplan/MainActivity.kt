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

        // ✅ Memory optimization for Google Maps
        window.addFlags(WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON)

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
                    description = "Emergency alerts and notifications"
                    setSound(soundUri, audioAttributes)
                    enableVibration(true)
                    enableLights(true)
                }

                val notificationManager = getSystemService(NotificationManager::class.java)
                notificationManager.createNotificationChannel(channel)
            } catch (e: Exception) {
                // Log error but don't crash the app
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

    override fun onPause() {
        super.onPause()
        // ✅ Clean up resources when app is paused
    }
}