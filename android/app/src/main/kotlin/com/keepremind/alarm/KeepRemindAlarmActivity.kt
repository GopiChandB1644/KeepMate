package com.keepremind.alarm

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import com.keepremind.R
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class KeepRemindAlarmActivity : Activity() {
    companion object {
        private const val TAG = "KeepRemindAlarmActivity"
    }

    private var alarmId: Int = 0
    private var medicineId: String = ""
    private var medicineName: String = ""
    private var dosage: String = ""
    private var mealInstruction: String = ""
    private var doseTime: String = ""
    private var snoozeMinutes: Int = 5

    private val stopReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.d(TAG, "Received ALARM_STOPPED broadcast, finishing activity")
            finish()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "KeepRemindAlarmActivity onCreate")

        configureLockScreenFlags()
        setContentView(R.layout.activity_alarm)

        extractIntentData(intent)
        bindViews()

        val filter = IntentFilter("com.keepremind.alarm.ALARM_STOPPED")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(stopReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(stopReceiver, filter)
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        extractIntentData(intent)
        bindViews()
    }

    private fun configureLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    private fun extractIntentData(intent: Intent?) {
        if (intent == null) return
        alarmId = intent.getIntExtra(KeepRemindAlarmService.EXTRA_ALARM_ID, 0)
        medicineId = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEDICINE_ID) ?: ""
        medicineName = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEDICINE_NAME) ?: "Medicine"
        dosage = intent.getStringExtra(KeepRemindAlarmService.EXTRA_DOSAGE) ?: ""
        mealInstruction = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEAL_INSTRUCTION) ?: ""
        doseTime = intent.getStringExtra(KeepRemindAlarmService.EXTRA_DOSE_TIME) ?: ""
        snoozeMinutes = intent.getIntExtra(KeepRemindAlarmService.EXTRA_SNOOZE_MINUTES, 5)
    }

    private fun bindViews() {
        val tvTime = findViewById<TextView>(R.id.tv_alarm_time)
        val tvMedName = findViewById<TextView>(R.id.tv_medicine_name)
        val tvMedDetails = findViewById<TextView>(R.id.tv_medicine_details)
        val btnTaken = findViewById<Button>(R.id.btn_taken)
        val btnSnooze = findViewById<Button>(R.id.btn_snooze)
        val btnStop = findViewById<Button>(R.id.btn_stop)

        tvTime.text = formatDoseTime(doseTime)
        tvMedName.text = medicineName
        tvMedDetails.text = if (dosage.isNotEmpty()) "$dosage • $mealInstruction" else mealInstruction

        btnSnooze.text = "⏰ SNOOZE ($snoozeMinutes min)"

        btnTaken.setOnClickListener {
            handleActionTaken()
        }

        btnSnooze.setOnClickListener {
            handleActionSnooze()
        }

        btnStop.setOnClickListener {
            handleActionStop()
        }
    }

    private fun formatDoseTime(rawTime: String): String {
        return try {
            val parts = rawTime.split(":")
            if (parts.size == 2) {
                val hour = parts[0].toInt()
                val min = parts[1].toInt()
                val isPm = hour >= 12
                val displayHour = when {
                    hour == 0 -> 12
                    hour > 12 -> hour - 12
                    else -> hour
                }
                String.format(Locale.getDefault(), "%02d:%02d %s", displayHour, min, if (isPm) "PM" else "AM")
            } else {
                SimpleDateFormat("hh:mm a", Locale.getDefault()).format(Date())
            }
        } catch (_: Exception) {
            rawTime
        }
    }

    private fun handleActionTaken() {
        Log.d(TAG, "Action: MARK AS TAKEN for medicine $medicineId ($medicineName)")
        // 1. Stop service
        stopAlarmService()

        // 2. Queue action into persistent storage for Flutter sync
        val todayStr = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        KeepRemindAlarmStorage(this).queuePendingAction(
            action = "taken",
            medicineId = medicineId,
            doseTime = doseTime,
            scheduledDate = todayStr
        )

        // 3. Finish activity
        finish()
    }

    private fun handleActionSnooze() {
        Log.d(TAG, "Action: SNOOZE for $snoozeMinutes minutes for medicine $medicineId")
        // 1. Stop active ringing
        stopAlarmService()

        // 2. Schedule snooze alarm via Scheduler
        KeepRemindAlarmScheduler.scheduleSnooze(
            context = this,
            alarmId = alarmId,
            medicineId = medicineId,
            medicineName = medicineName,
            dosage = dosage,
            mealInstruction = mealInstruction,
            doseTime = doseTime,
            snoozeMinutes = snoozeMinutes
        )

        // 3. Finish activity
        finish()
    }

    private fun handleActionStop() {
        Log.d(TAG, "Action: STOP/SILENCE alarm for medicine $medicineId")
        // Stop active ringing and dismiss
        stopAlarmService()
        finish()
    }

    private fun stopAlarmService() {
        val stopIntent = Intent(this, KeepRemindAlarmService::class.java).apply {
            action = KeepRemindAlarmService.ACTION_STOP_ALARM
        }
        startService(stopIntent)
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(stopReceiver)
        } catch (_: Exception) {}
    }
}
