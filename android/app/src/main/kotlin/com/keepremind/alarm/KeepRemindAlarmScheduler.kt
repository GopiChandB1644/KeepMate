package com.keepremind.alarm

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

object KeepRemindAlarmScheduler {
    private const val TAG = "KeepRemindAlarmScheduler"

    fun scheduleAlarm(
        context: Context,
        alarm: KeepRemindAlarmModel
    ): Boolean {
        return try {
            val storage = KeepRemindAlarmStorage(context)
            // Cancel existing alarm with the same ID if any
            cancelAlarm(context, alarm.id)

            // Persist model in native storage
            storage.saveAlarm(alarm)

            // Register with AlarmManager
            scheduleWithAlarmManager(context, alarm)
            Log.d(TAG, "Successfully scheduled exact Alarm Mode reminder ID ${alarm.id} for ${alarm.medicineName} at ${alarm.triggerTimestamp}")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule alarm ID ${alarm.id}", e)
            false
        }
    }

    fun scheduleSnooze(
        context: Context,
        alarmId: Int,
        medicineId: String,
        medicineName: String,
        dosage: String,
        mealInstruction: String,
        doseTime: String,
        snoozeMinutes: Int
    ): Boolean {
        return try {
            val snoozeAlarmId = (alarmId.hashCode() + 77777).let { if (it < 0) -it else it }
            val triggerTimestamp = System.currentTimeMillis() + (snoozeMinutes * 60 * 1000L)

            val snoozeAlarm = KeepRemindAlarmModel(
                id = snoozeAlarmId,
                medicineId = medicineId,
                medicineName = medicineName,
                dosage = dosage,
                mealInstruction = mealInstruction,
                doseTime = doseTime,
                triggerTimestamp = triggerTimestamp,
                snoozeMinutes = snoozeMinutes,
                isSnooze = true
            )

            scheduleAlarm(context, snoozeAlarm)
            Log.d(TAG, "Successfully scheduled Snooze Alarm for medicine $medicineName in $snoozeMinutes mins (ID: $snoozeAlarmId)")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule snooze alarm", e)
            false
        }
    }

    fun scheduleWithAlarmManager(context: Context, alarm: KeepRemindAlarmModel) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val intent = Intent(context, KeepRemindAlarmReceiver::class.java).apply {
            action = KeepRemindAlarmReceiver.ACTION_TRIGGER_ALARM
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

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarm.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val canExact = canScheduleExactAlarms(context)
        if (canExact) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                alarm.triggerTimestamp,
                pendingIntent
            )
            Log.d(TAG, "AlarmManager.setExactAndAllowWhileIdle registered for timestamp ${alarm.triggerTimestamp}")
        } else {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                alarm.triggerTimestamp,
                pendingIntent
            )
            Log.w(TAG, "Exact alarms not allowed, fallback to setAndAllowWhileIdle used for timestamp ${alarm.triggerTimestamp}")
        }
    }

    fun cancelAlarm(context: Context, id: Int) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            val intent = Intent(context, KeepRemindAlarmReceiver::class.java).apply {
                action = KeepRemindAlarmReceiver.ACTION_TRIGGER_ALARM
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            if (pendingIntent != null && alarmManager != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }
            KeepRemindAlarmStorage(context).removeAlarm(id)
            Log.d(TAG, "Cancelled alarm ID $id")
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling alarm ID $id", e)
        }
    }

    fun cancelAlarmsForMedicine(context: Context, medicineId: String) {
        val storage = KeepRemindAlarmStorage(context)
        val alarms = storage.getAllAlarms().filter { it.medicineId == medicineId }
        for (alarm in alarms) {
            cancelAlarm(context, alarm.id)
        }
        storage.removeAlarmsForMedicine(medicineId)
        Log.d(TAG, "Cancelled all native alarms for medicineId $medicineId")
    }

    fun cancelAllAlarms(context: Context) {
        val storage = KeepRemindAlarmStorage(context)
        val alarms = storage.getAllAlarms()
        for (alarm in alarms) {
            cancelAlarm(context, alarm.id)
        }
        Log.d(TAG, "Cancelled all active alarms from system")
    }

    fun canScheduleExactAlarms(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            return alarmManager?.canScheduleExactAlarms() ?: false
        }
        return true
    }

    fun canUseFullScreenIntent(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            return notificationManager?.canUseFullScreenIntent() ?: false
        }
        return true
    }
}
