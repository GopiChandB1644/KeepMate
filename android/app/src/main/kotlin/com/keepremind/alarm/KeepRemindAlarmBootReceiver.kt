package com.keepremind.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import java.util.Calendar

class KeepRemindAlarmBootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "KeepRemindAlarmBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d(TAG, "KeepRemindAlarmBootReceiver received action: $action")

        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED &&
            action != "android.intent.action.QUICKBOOT_POWERON" &&
            action != "com.htc.intent.action.QUICKBOOT_POWERON") {
            return
        }

        val storage = KeepRemindAlarmStorage(context)
        val allAlarms = storage.getAllAlarms()
        Log.d(TAG, "Reboot recovery started: ${allAlarms.size} stored alarm(s) found")

        val now = System.currentTimeMillis()
        var recoveredCount = 0

        for (alarm in allAlarms) {
            try {
                if (alarm.triggerTimestamp > now) {
                    // Future alarm: re-schedule as is
                    KeepRemindAlarmScheduler.scheduleWithAlarmManager(context, alarm)
                    recoveredCount++
                } else if (!alarm.isSnooze) {
                    // Recurring daily alarm that passed while off: roll over to next occurrence
                    val parts = alarm.doseTime.split(":")
                    if (parts.size == 2) {
                        val cal = Calendar.getInstance().apply {
                            set(Calendar.HOUR_OF_DAY, parts[0].toInt())
                            set(Calendar.MINUTE, parts[1].toInt())
                            set(Calendar.SECOND, 0)
                            set(Calendar.MILLISECOND, 0)
                        }
                        if (cal.timeInMillis <= now) {
                            cal.add(Calendar.DAY_OF_YEAR, 1)
                        }
                        val updated = alarm.copy(triggerTimestamp = cal.timeInMillis)
                        storage.saveAlarm(updated)
                        KeepRemindAlarmScheduler.scheduleWithAlarmManager(context, updated)
                        recoveredCount++
                        Log.d(TAG, "Rolled over past alarm ID ${alarm.id} to ${cal.time}")
                    }
                } else {
                    // Expired snooze alarm: discard safely
                    storage.removeAlarm(alarm.id)
                    Log.d(TAG, "Discarded expired snooze alarm ID ${alarm.id}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error recovering alarm ID ${alarm.id}", e)
            }
        }

        Log.d(TAG, "Reboot recovery complete: $recoveredCount alarm(s) successfully re-registered.")
    }
}
