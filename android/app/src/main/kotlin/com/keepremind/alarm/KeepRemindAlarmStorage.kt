package com.keepremind.alarm

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

class KeepRemindAlarmStorage(context: Context) {
    companion object {
        private const val TAG = "KeepRemindAlarmStorage"
        private const val PREFS_NAME = "keepremind_alarm_storage"
        private const val KEY_ALARMS = "active_alarms"
        private const val KEY_PENDING_ACTIONS = "pending_actions"
    }

    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    @Synchronized
    fun saveAlarm(alarm: KeepRemindAlarmModel) {
        val alarms = getAllAlarms().toMutableList()
        alarms.removeAll { it.id == alarm.id }
        alarms.add(alarm)
        saveAllAlarms(alarms)
        Log.d(TAG, "Saved alarm ID ${alarm.id} for medicine ${alarm.medicineName} at ${alarm.triggerTimestamp}")
    }

    @Synchronized
    fun removeAlarm(id: Int) {
        val alarms = getAllAlarms().toMutableList()
        val removed = alarms.removeAll { it.id == id }
        if (removed) {
            saveAllAlarms(alarms)
            Log.d(TAG, "Removed alarm ID $id from storage")
        }
    }

    @Synchronized
    fun removeAlarmsForMedicine(medicineId: String) {
        val alarms = getAllAlarms().toMutableList()
        val countBefore = alarms.size
        alarms.removeAll { it.medicineId == medicineId }
        if (alarms.size < countBefore) {
            saveAllAlarms(alarms)
            Log.d(TAG, "Removed ${countBefore - alarms.size} alarms for medicineId $medicineId")
        }
    }

    @Synchronized
    fun getAlarm(id: Int): KeepRemindAlarmModel? {
        return getAllAlarms().firstOrNull { it.id == id }
    }

    @Synchronized
    fun getAllAlarms(): List<KeepRemindAlarmModel> {
        val jsonStr = prefs.getString(KEY_ALARMS, null) ?: return emptyList()
        val list = mutableListOf<KeepRemindAlarmModel>()
        try {
            val jsonArray = JSONArray(jsonStr)
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                list.add(KeepRemindAlarmModel.fromJson(obj))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing saved alarms", e)
        }
        return list
    }

    private fun saveAllAlarms(alarms: List<KeepRemindAlarmModel>) {
        val jsonArray = JSONArray()
        for (alarm in alarms) {
            jsonArray.put(alarm.toJson())
        }
        prefs.edit().putString(KEY_ALARMS, jsonArray.toString()).apply()
    }

    // Pending Actions Queue for synchronization with Flutter/SQLite
    @Synchronized
    fun queuePendingAction(action: String, medicineId: String, doseTime: String, scheduledDate: String) {
        val actions = getPendingActions().toMutableList()
        val actionItem = mapOf(
            "actionId" to UUID.randomUUID().toString(),
            "action" to action,
            "medicineId" to medicineId,
            "doseTime" to doseTime,
            "scheduledDate" to scheduledDate,
            "timestamp" to System.currentTimeMillis()
        )
        actions.add(actionItem)
        saveAllActions(actions)
        Log.d(TAG, "Queued pending action '$action' for medicine $medicineId, date $scheduledDate $doseTime")
    }

    @Synchronized
    fun getPendingActions(): List<Map<String, Any>> {
        val jsonStr = prefs.getString(KEY_PENDING_ACTIONS, null) ?: return emptyList()
        val list = mutableListOf<Map<String, Any>>()
        try {
            val jsonArray = JSONArray(jsonStr)
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val map = mutableMapOf<String, Any>()
                val keys = obj.keys()
                while (keys.hasNext()) {
                    val key = keys.next()
                    map[key] = obj.get(key)
                }
                list.add(map)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing pending actions", e)
        }
        return list
    }

    @Synchronized
    fun removePendingAction(actionId: String) {
        val actions = getPendingActions().toMutableList()
        actions.removeAll { it["actionId"] == actionId }
        saveAllActions(actions)
    }

    @Synchronized
    fun clearPendingActions() {
        prefs.edit().remove(KEY_PENDING_ACTIONS).apply()
    }

    private fun saveAllActions(actions: List<Map<String, Any>>) {
        val jsonArray = JSONArray()
        for (action in actions) {
            val obj = JSONObject(action)
            jsonArray.put(obj)
        }
        prefs.edit().putString(KEY_PENDING_ACTIONS, jsonArray.toString()).apply()
    }
}
