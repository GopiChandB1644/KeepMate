package com.keepremind.alarm

import org.json.JSONObject

data class KeepRemindAlarmModel(
    val id: Int,
    val medicineId: String,
    val medicineName: String,
    val dosage: String,
    val mealInstruction: String,
    val doseTime: String,
    val triggerTimestamp: Long,
    val snoozeMinutes: Int = 5,
    val maxDurationMinutes: Int = 10,
    val vibrationEnabled: Boolean = true,
    val soundUri: String? = null,
    val isSnooze: Boolean = false
) {
    fun toJson(): JSONObject {
        val json = JSONObject()
        json.put("id", id)
        json.put("medicineId", medicineId)
        json.put("medicineName", medicineName)
        json.put("dosage", dosage)
        json.put("mealInstruction", mealInstruction)
        json.put("doseTime", doseTime)
        json.put("triggerTimestamp", triggerTimestamp)
        json.put("snoozeMinutes", snoozeMinutes)
        json.put("maxDurationMinutes", maxDurationMinutes)
        json.put("vibrationEnabled", vibrationEnabled)
        json.put("soundUri", soundUri ?: "")
        json.put("isSnooze", isSnooze)
        return json
    }

    companion object {
        fun fromJson(json: JSONObject): KeepRemindAlarmModel {
            return KeepRemindAlarmModel(
                id = json.getInt("id"),
                medicineId = json.getString("medicineId"),
                medicineName = json.getString("medicineName"),
                dosage = json.optString("dosage", ""),
                mealInstruction = json.optString("mealInstruction", ""),
                doseTime = json.optString("doseTime", "08:00"),
                triggerTimestamp = json.getLong("triggerTimestamp"),
                snoozeMinutes = json.optInt("snoozeMinutes", 5),
                maxDurationMinutes = json.optInt("maxDurationMinutes", 10),
                vibrationEnabled = json.optBoolean("vibrationEnabled", true),
                soundUri = json.optString("soundUri").takeIf { it.isNotEmpty() },
                isSnooze = json.optBoolean("isSnooze", false)
            )
        }
    }
}
