package com.keepremind.alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import com.keepremind.R

class KeepRemindAlarmService : Service() {
    companion object {
        private const val TAG = "KeepRemindAlarmService"
        const val CHANNEL_ID = "keepremind_alarm_channel"
        const val CHANNEL_NAME = "Medicine Alarms"
        const val NOTIFICATION_ID = 888888

        const val ACTION_START_ALARM = "com.keepremind.alarm.ACTION_START_ALARM"
        const val ACTION_STOP_ALARM = "com.keepremind.alarm.ACTION_STOP_ALARM"

        const val EXTRA_ALARM_ID = "alarm_id"
        const val EXTRA_MEDICINE_ID = "medicine_id"
        const val EXTRA_MEDICINE_NAME = "medicine_name"
        const val EXTRA_DOSAGE = "dosage"
        const val EXTRA_MEAL_INSTRUCTION = "meal_instruction"
        const val EXTRA_DOSE_TIME = "dose_time"
        const val EXTRA_SNOOZE_MINUTES = "snooze_minutes"
        const val EXTRA_MAX_DURATION_MINUTES = "max_duration_minutes"
        const val EXTRA_VIBRATION = "vibration_enabled"
        const val EXTRA_SOUND_URI = "sound_uri"

        var isRunning = false
            private set
    }

    private var audioPlayer: KeepRemindAlarmAudioPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private val handler = Handler(Looper.getMainLooper())
    private var timeoutRunnable: Runnable? = null

    private var currentAlarmId: Int = 0
    private var currentMedicineId: String = ""
    private var currentMedicineName: String = ""
    private var currentDosage: String = ""
    private var currentMealInstruction: String = ""
    private var currentDoseTime: String = ""
    private var currentSnoozeMinutes: Int = 5
    private var currentMaxDurationMinutes: Int = 10

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "KeepRemindAlarmService created")
        audioPlayer = KeepRemindAlarmAudioPlayer(this)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) return START_NOT_STICKY

        val action = intent.action
        Log.d(TAG, "onStartCommand received action: $action")

        if (action == ACTION_STOP_ALARM) {
            stopAlarm()
            return START_NOT_STICKY
        }

        if (action == ACTION_START_ALARM) {
            currentAlarmId = intent.getIntExtra(EXTRA_ALARM_ID, 0)
            currentMedicineId = intent.getStringExtra(EXTRA_MEDICINE_ID) ?: ""
            currentMedicineName = intent.getStringExtra(EXTRA_MEDICINE_NAME) ?: "Medicine"
            currentDosage = intent.getStringExtra(EXTRA_DOSAGE) ?: ""
            currentMealInstruction = intent.getStringExtra(EXTRA_MEAL_INSTRUCTION) ?: ""
            currentDoseTime = intent.getStringExtra(EXTRA_DOSE_TIME) ?: ""
            currentSnoozeMinutes = intent.getIntExtra(EXTRA_SNOOZE_MINUTES, 5)
            currentMaxDurationMinutes = intent.getIntExtra(EXTRA_MAX_DURATION_MINUTES, 10)
            val vibration = intent.getBooleanExtra(EXTRA_VIBRATION, true)
            val soundUri = intent.getStringExtra(EXTRA_SOUND_URI)

            acquireWakeLock()
            isRunning = true

            // 1. Build and show Foreground Notification with Full Screen Intent
            val notification = buildAlarmNotification()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val serviceType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
                } else {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_NONE
                }
                startForeground(NOTIFICATION_ID, notification, serviceType)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }

            // 2. Start continuous audio and vibration
            audioPlayer?.start(vibration, soundUri)

            // 3. Set native maximum ringing duration safeguard
            scheduleMaxDurationTimeout(currentMaxDurationMinutes)

            // 4. Launch Full Screen Activity if permitted
            launchAlarmActivity()
        }

        return START_NOT_STICKY
    }

    private fun acquireWakeLock() {
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager
            wakeLock = pm?.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "KeepRemind:AlarmServiceWakeLock"
            )?.apply {
                acquire(15 * 60 * 1000L) // 15 minutes max safeguard
            }
            Log.d(TAG, "WakeLock acquired for alarm ringing")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to acquire WakeLock", e)
        }
    }

    private fun scheduleMaxDurationTimeout(maxMinutes: Int) {
        timeoutRunnable?.let { handler.removeCallbacks(it) }
        val durationMillis = maxMinutes * 60 * 1000L
        timeoutRunnable = Runnable {
            Log.d(TAG, "Maximum ringing duration of $maxMinutes minutes reached. Silencing alarm automatically.")
            stopAlarm()
        }
        handler.postDelayed(timeoutRunnable!!, durationMillis)
        Log.d(TAG, "Scheduled auto-stop timeout in $maxMinutes minutes ($durationMillis ms)")
    }

    private fun launchAlarmActivity() {
        try {
            val activityIntent = Intent(this, KeepRemindAlarmActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra(EXTRA_ALARM_ID, currentAlarmId)
                putExtra(EXTRA_MEDICINE_ID, currentMedicineId)
                putExtra(EXTRA_MEDICINE_NAME, currentMedicineName)
                putExtra(EXTRA_DOSAGE, currentDosage)
                putExtra(EXTRA_MEAL_INSTRUCTION, currentMealInstruction)
                putExtra(EXTRA_DOSE_TIME, currentDoseTime)
                putExtra(EXTRA_SNOOZE_MINUTES, currentSnoozeMinutes)
            }
            startActivity(activityIntent)
            Log.d(TAG, "Launched KeepRemindAlarmActivity from Service")
        } catch (e: Exception) {
            Log.w(TAG, "Could not start Activity directly, relying on fullScreenIntent", e)
        }
    }

    private fun buildAlarmNotification(): Notification {
        // Full Screen Activity Intent
        val fullScreenIntent = Intent(this, KeepRemindAlarmActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_ALARM_ID, currentAlarmId)
            putExtra(EXTRA_MEDICINE_ID, currentMedicineId)
            putExtra(EXTRA_MEDICINE_NAME, currentMedicineName)
            putExtra(EXTRA_DOSAGE, currentDosage)
            putExtra(EXTRA_MEAL_INSTRUCTION, currentMealInstruction)
            putExtra(EXTRA_DOSE_TIME, currentDoseTime)
            putExtra(EXTRA_SNOOZE_MINUTES, currentSnoozeMinutes)
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            currentAlarmId,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Notification Action: Mark Taken
        val takenIntent = Intent(this, KeepRemindAlarmActionReceiver::class.java).apply {
            action = KeepRemindAlarmActionReceiver.ACTION_TAKEN
            putExtra(EXTRA_ALARM_ID, currentAlarmId)
            putExtra(EXTRA_MEDICINE_ID, currentMedicineId)
            putExtra(EXTRA_DOSE_TIME, currentDoseTime)
        }
        val takenPendingIntent = PendingIntent.getBroadcast(
            this,
            currentAlarmId + 1000,
            takenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Notification Action: Snooze
        val snoozeIntent = Intent(this, KeepRemindAlarmActionReceiver::class.java).apply {
            action = KeepRemindAlarmActionReceiver.ACTION_SNOOZE
            putExtra(EXTRA_ALARM_ID, currentAlarmId)
            putExtra(EXTRA_MEDICINE_ID, currentMedicineId)
            putExtra(EXTRA_MEDICINE_NAME, currentMedicineName)
            putExtra(EXTRA_DOSAGE, currentDosage)
            putExtra(EXTRA_MEAL_INSTRUCTION, currentMealInstruction)
            putExtra(EXTRA_DOSE_TIME, currentDoseTime)
            putExtra(EXTRA_SNOOZE_MINUTES, currentSnoozeMinutes)
        }
        val snoozePendingIntent = PendingIntent.getBroadcast(
            this,
            currentAlarmId + 2000,
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Notification Action: Stop
        val stopIntent = Intent(this, KeepRemindAlarmActionReceiver::class.java).apply {
            action = KeepRemindAlarmActionReceiver.ACTION_STOP
            putExtra(EXTRA_ALARM_ID, currentAlarmId)
        }
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            currentAlarmId + 3000,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("⏰ Alarm: $currentMedicineName")
            .setContentText("$currentDosage • $currentMealInstruction (Tap to open)")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(fullScreenPendingIntent)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .addAction(0, "✓ TAKEN", takenPendingIntent)
            .addAction(0, "⏰ SNOOZE", snoozePendingIntent)
            .addAction(0, "✕ STOP", stopPendingIntent)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val alarmSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "High-priority alarm notifications that play continuously"
                setSound(alarmSoundUri, audioAttributes)
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 800, 400, 800, 400, 800, 1000)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setBypassDnd(true)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun stopAlarm() {
        Log.d(TAG, "Stopping KeepRemindAlarmService")
        timeoutRunnable?.let { handler.removeCallbacks(it) }
        audioPlayer?.stop()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        isRunning = false
        stopSelf()

        // Inform any running activity to close
        sendBroadcast(Intent("com.keepremind.alarm.ALARM_STOPPED"))
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "KeepRemindAlarmService onDestroy")
        timeoutRunnable?.let { handler.removeCallbacks(it) }
        audioPlayer?.stop()
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing wakeLock", e)
        }
        isRunning = false
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
