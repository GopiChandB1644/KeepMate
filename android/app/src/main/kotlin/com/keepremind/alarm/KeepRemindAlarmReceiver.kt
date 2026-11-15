package com.keepremind.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log
import androidx.core.content.ContextCompat
import java.util.Calendar

class KeepRemindAlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "KeepRemindAlarmReceiver"
        const val ACTION_TRIGGER_ALARM = "com.keepremind.alarm.ACTION_TRIGGER_ALARM"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d(TAG, "KeepRemindAlarmReceiver received action: $action")

        if (action != ACTION_TRIGGER_ALARM) return

        val alarmId = intent.getIntExtra(KeepRemindAlarmService.EXTRA_ALARM_ID, 0)
        if (alarmId == 0) {
            Log.e(TAG, "Received alarm trigger with invalid ID 0")
            return
        }

        val storage = KeepRemindAlarmStorage(context)
        var alarm = storage.getAlarm(alarmId)
        if (alarm == null) {
            val medName = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEDICINE_NAME)
            if (!medName.isNullOrEmpty()) {
                alarm = KeepRemindAlarmModel(
                    id = alarmId,
                    medicineId = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEDICINE_ID) ?: "",
                    medicineName = medName,
                    dosage = intent.getStringExtra(KeepRemindAlarmService.EXTRA_DOSAGE) ?: "",
                    mealInstruction = intent.getStringExtra(KeepRemindAlarmService.EXTRA_MEAL_INSTRUCTION) ?: "",
                    doseTime = intent.getStringExtra(KeepRemindAlarmService.EXTRA_DOSE_TIME) ?: "08:00",
                    triggerTimestamp = System.currentTimeMillis(),
                    snoozeMinutes = intent.getIntExtra(KeepRemindAlarmService.EXTRA_SNOOZE_MINUTES, 5),
                    maxDurationMinutes = intent.getIntExtra(KeepRemindAlarmService.EXTRA_MAX_DURATION_MINUTES, 10),
                    vibrationEnabled = intent.getBooleanExtra(KeepRemindAlarmService.EXTRA_VIBRATION, true)
                )
            } else {
                Log.w(TAG, "Alarm with ID $alarmId was not found in storage (cancelled or deleted). Skipping.")
                return
            }
        }

        Log.d(TAG, "Alarm validated for medicine: ${alarm.medicineName} (${alarm.medicineId}) at ${alarm.doseTime}")

        // 1. Acquire short wake lock to guarantee service starts safely
        val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val wakeLock = pm?.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "KeepRemind:ReceiverWakeLock"
        )
        wakeLock?.acquire(30 * 1000L)

        // 2. If it's a recurring daily alarm, schedule tomorrow's occurrence
        if (!alarm.isSnooze) {
            scheduleNextOccurrence(context, alarm, storage)
        } else {
            // Remove one-off snooze alarm from storage now that it fired
            storage.removeAlarm(alarm.id)
        }

        // 3. Start foreground alarm service
        val serviceIntent = Intent(context, KeepRemindAlarmService::class.java).apply {
            this.action = KeepRemindAlarmService.ACTION_START_ALARM
            putExtra(KeepRemindAlarmService.EXTRA_ALARM_ID, alarm.id)
            putExtra(KeepRemindAlarmService.EXTRA_MEDICINE_ID, alarm.medicineId)
            putExtra(KeepRemindAlarmService.EXTRA_MEDICINE_NAME, alarm.medicineName)
            putExtra(KeepRemindAlarmService.EXTRA_DOSAGE, alarm.dosage)
            putExtra(KeepRemindAlarmService.EXTRA_MEAL_INSTRUCTION, alarm.mealInstruction)
            putExtra(KeepRemindAlarmService.EXTRA_DOSE_TIME, alarm.doseTime)
            putExtra(KeepRemindAlarmService.EXTRA_SNOOZE_MINUTES, alarm.snoozeMinutes)
            putExtra(KeepRemindAlarmService.EXTRA_MAX_DURATION_MINUTES, alarm.maxDurationMinutes)
            putExtra(KeepRemindAlarmService.EXTRA_VIBRATION, alarm.vibrationEnabled)
            putExtra(KeepRemindAlarmService.EXTRA_SOUND_URI, alarm.soundUri)
        }

        try {
            ContextCompat.startForegroundService(context, serviceIntent)
            Log.d(TAG, "Dispatched startForegroundService for alarm ID ${alarm.id}")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting KeepRemindAlarmService", e)
        } finally {
            if (wakeLock?.isHeld == true) {
                wakeLock.release()
            }
        }
    }

    private fun scheduleNextOccurrence(context: Context, alarm: KeepRemindAlarmModel, storage: KeepRemindAlarmStorage) {
        try {
            val parts = alarm.doseTime.split(":")
            if (parts.size == 2) {
                val cal = Calendar.getInstance().apply {
                    add(Calendar.DAY_OF_YEAR, 1)
                    set(Calendar.HOUR_OF_DAY, parts[0].toInt())
                    set(Calendar.MINUTE, parts[1].toInt())
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
                val nextTimestamp = cal.timeInMillis
                val updatedAlarm = alarm.copy(triggerTimestamp = nextTimestamp)
                storage.saveAlarm(updatedAlarm)
                KeepRemindAlarmScheduler.scheduleWithAlarmManager(context, updatedAlarm)
                Log.d(TAG, "Re-scheduled recurring alarm ID ${alarm.id} for tomorrow at ${cal.time}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to re-schedule next occurrence for alarm ${alarm.id}", e)
        }
    }
}
