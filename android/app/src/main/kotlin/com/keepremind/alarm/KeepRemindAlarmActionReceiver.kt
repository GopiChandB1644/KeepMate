package com.keepremind.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class KeepRemindAlarmActionReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "KeepRemindAlarmActionReceiver"
        const val ACTION_TAKEN = "com.keepremind.alarm.ACTION_TAKEN"
        const val ACTION_SNOOZE = "com.keepremind.alarm.ACTION_SNOOZE"
        const val ACTION_STOP = "com.keepremind.alarm.ACTION_STOP"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action != ACTION_TAKEN && action != ACTION_SNOOZE && action != ACTION_STOP) {
            Log.w(TAG, "Ignored unexpected action: $action")
            return
        }
        val alarmId = intent.getIntExtra(KeepRemindAlarmService.EXTRA_ALARM_ID, 0)
        val medicineId = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEDICINE_ID) ?: ""
        val doseTime = intent.getStringExtra(KeepRemindAlarmService.EXTRA_DOSE_TIME) ?: ""

        Log.d(TAG, "KeepRemindAlarmActionReceiver received action: $action for alarm $alarmId ($medicineId)")

        // Stop the active ringing service first
        stopAlarmService(context)

        when (action) {
            ACTION_TAKEN -> {
                val todayStr = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                KeepRemindAlarmStorage(context).queuePendingAction(
                    action = "taken",
                    medicineId = medicineId,
                    doseTime = doseTime,
                    scheduledDate = todayStr
                )
                Log.d(TAG, "Notification action TAKEN recorded for medicine $medicineId")
            }
            ACTION_SNOOZE -> {
                val medicineName = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEDICINE_NAME) ?: "Medicine"
                val dosage = intent.getStringExtra(KeepRemindAlarmService.EXTRA_DOSAGE) ?: ""
                val mealInstruction = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEAL_INSTRUCTION) ?: ""
                val snoozeMinutes = intent.getIntExtra(KeepRemindAlarmService.EXTRA_SNOOZE_MINUTES, 5)

                KeepRemindAlarmScheduler.scheduleSnooze(
                    context = context,
                    alarmId = alarmId,
                    medicineId = medicineId,
                    medicineName = medicineName,
                    dosage = dosage,
                    mealInstruction = mealInstruction,
                    doseTime = doseTime,
                    snoozeMinutes = snoozeMinutes
                )
                Log.d(TAG, "Notification action SNOOZE ($snoozeMinutes mins) scheduled for medicine $medicineId")
            }
            ACTION_STOP -> {
                Log.d(TAG, "Notification action STOP processed for medicine $medicineId")
            }
        }
    }

    private fun stopAlarmService(context: Context) {
        val stopIntent = Intent(context, KeepRemindAlarmService::class.java).apply {
            action = KeepRemindAlarmService.ACTION_STOP_ALARM
        }
        context.startService(stopIntent)
    }
}
