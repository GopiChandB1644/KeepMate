# Persistent Android Alarm Mode: Implementation & Architecture Report

**Application:** KeepRemind (com.keepremind)  
**Module:** MedicineCare & Cross-Platform Reminder Engine  
**Feature Branch:** `feature/persistent-alarm-mode`  
**Schema Version:** 3 (Drift SQLite)  
**Target Platform:** Android (API 26 through API 36 / Android 16) & iOS  
**Test Status:** 88 / 88 Unit & Widget Tests Passing | 0 Linter Warnings | Physically Verified on Android 16 Hardware  

---

## 1. Executive Summary & Architecture Overview

KeepRemind provides four core reminder modules: **LifePocket**, **FreshCheck**, **DocAlert**, and **MedicineCare**. For medical adherence, standard brief notifications can easily be missed or dismissed if a user is asleep, away from their phone, or in a noisy environment.

To solve this, KeepRemind introduces **Dual Reminder Modes** for medicine schedules:
1. **Notification Mode**: Preserves standard low-overhead Android/iOS notification banners, playing the selected alert tone once and scheduling through the existing `NotificationService` and `flutter_local_notifications` engine.
2. **Alarm Mode**: A persistent, native Android alarm system that behaves like the native system clock app. It wakes the device from deep Doze mode at the exact scheduled second, rings continuously using the native `MediaPlayer` on the alarm audio stream, applies a rhythmic vibration pattern, displays a full-screen lock-screen interface (`KeepRemindAlarmActivity`), provides an ongoing high-priority fallback notification, and safely synchronizes all taken/snoozed dose actions back to Drift SQLite without requiring continuous background Dart isolates.

```
                              ┌──────────────────────────────────────┐
                              │          KeepRemind Flutter          │
                              │  (Add/Edit Medicine UI & Drift DB)   │
                              └──────────────────┬───────────────────┘
                                                 │
                                                 │ Reminder Mode Check
                       ┌─────────────────────────┴─────────────────────────┐
                       ▼                                                   ▼
            [ Notification Mode ]                                   [ Alarm Mode ]
                       │                                                   │
         NotificationService.dart                               NativeAlarmBridge.dart
        (flutter_local_notifications)                           (MethodChannel 'com.keepremind.app/alarm_manager')
                       │                                                   │
           Asia/Calcutta Zoned Time                                        │
                       ▼                                                   ▼
         Android AlarmManager PendingIntent                  MainActivity.kt Channel Dispatch
                       │                                                   │
                       │                                    KeepRemindAlarmScheduler.kt
                       │                                    (AlarmManager.setExactAndAllowWhileIdle)
                       │                                                   │
                       │                                                   ▼
                       │                                    KeepRemindAlarmStorage.kt
                       │                                    (Persistent JSON in SharedPreferences)
                       │                                                   │
                       │                        ┌──────────────────────────┴──────────────────────────┐
                       │                        │                    At Alarm Time                    │
                       │                        │               KeepRemindAlarmReceiver               │
                       │                        └──────────────────────────┬──────────────────────────┘
                       │                                                   │ Acquires WakeLock
                       │                                                   ▼
                       │                                       KeepRemindAlarmService
                       │                                 (Foreground Service: mediaPlayback)
                       │                                                   │
                       │                   ┌───────────────────────────────┴───────────────────────────────┐
                       │                   ▼                                                               ▼
                       │      KeepRemindAlarmAudioPlayer                                       KeepRemindAlarmActivity
                       │  - Looping MediaPlayer (STREAM_ALARM)                             - Fullscreen over Lock Screen
                       │  - Continuous Rhythmic Vibration                                  - Stop / Snooze / Taken Actions
                       │  - Audio Focus Management                                         - Auto-dismiss after 10m timeout
                       │                   │                                                               │
                       │                   └───────────────────────────────┬───────────────────────────────┘
                       │                                                   │ User Taps Action
                       │                                                   ▼
                       │                                      KeepRemindAlarmStorage.kt
                       │                                      (Writes to pending_actions queue)
                       │                                                   │
                       │                                                   ▼
                       │                                      Flutter App Starts / Resumes
                       │                                                   │
                       └───────────────────────────────────►  syncPendingNativeActions()
                                                              (Ingests to Drift SQLite Medicine Table)
```

---

## 2. Native Android Architecture & Implementation

All native alarm logic is encapsulated inside `android/app/src/main/kotlin/com/keepremind/alarm/` to guarantee zero dependency on a running Dart VM or Flutter background engine during alarm firing and audio playback.

### 2.1 File Directory Structure
```
android/app/src/main/
├── AndroidManifest.xml
├── kotlin/com/keepremind/
│   ├── MainActivity.kt
│   └── alarm/
│       ├── KeepRemindAlarmActionReceiver.kt
│       ├── KeepRemindAlarmActivity.kt
│       ├── KeepRemindAlarmAudioPlayer.kt
│       ├── KeepRemindAlarmBootReceiver.kt
│       ├── KeepRemindAlarmModel.kt
│       ├── KeepRemindAlarmReceiver.kt
│       ├── KeepRemindAlarmScheduler.kt
│       ├── KeepRemindAlarmService.kt
│       └── KeepRemindAlarmStorage.kt
└── res/
    ├── drawable/
    │   ├── bg_alarm_card.xml
    │   ├── bg_btn_snooze.xml
    │   ├── bg_btn_stop.xml
    │   └── bg_btn_taken.xml
    ├── layout/
    │   └── activity_alarm.xml
    └── values/
        └── styles.xml
```

### 2.2 Component Responsibilities

1. **`KeepRemindAlarmModel.kt`**:
   - Represents the complete alarm payload including `id`, `medicineId`, `medicineName`, `dosage`, `mealInstruction`, `doseTime`, `triggerTimestamp`, `snoozeMinutes`, `maxDurationMinutes`, `vibrationEnabled`, `soundUri`, and `isSnooze`.
   - Includes custom JSON serialization and deserialization (`toJson()` / `fromJson()`) avoiding heavy reflection libraries.

2. **`KeepRemindAlarmStorage.kt`**:
   - Thread-safe persistent storage using private Android `SharedPreferences` (`keepremind_alarm_storage.xml`).
   - Maintains active alarms list for reboot recovery and rollover.
   - Maintains an offline `pending_actions` queue (`actionId`, `action`, `medicineId`, `doseTime`, `scheduledDate`, `timestamp`) so user interactions (e.g., Mark as Taken on the lock screen) are never lost even if the app process was dead.

3. **`KeepRemindAlarmScheduler.kt`**:
   - Interfaces directly with `android.app.AlarmManager`.
   - Uses `AlarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, ...)` to ensure on-time trigger during Android Doze mode.
   - Provides `scheduleAlarm()`, `cancelAlarm()`, and permission checks (`hasExactAlarmPermission()`, `hasFullScreenPermission()`).
   - Automatically handles rollover calculation when scheduling for upcoming days.

4. **`KeepRemindAlarmReceiver.kt`**:
   - Extends `BroadcastReceiver`. Receives the explicit `ACTION_TRIGGER_ALARM` intent from `AlarmManager`.
   - Acquires a temporary `PowerManager.WakeLock` (`KEEP_REMIND:AlarmReceiverLock`) with a 60-second timeout.
   - Dispatches an explicit foreground service start command to `KeepRemindAlarmService`.
   - Automatically rolls recurring non-snooze alarms forward 24 hours in `KeepRemindAlarmStorage` and schedules the next day's alarm with `AlarmManager`.

5. **`KeepRemindAlarmService.kt`**:
   - Android `ForegroundService` with `android:foregroundServiceType="mediaPlayback"`.
   - Maintains a partial wake lock for the duration of the ringing session.
   - Displays an ongoing, high-priority notification (`CATEGORY_ALARM`, Priority Max) with `fullScreenIntent` pointing to `KeepRemindAlarmActivity`.
   - Provides direct action intents on the notification:
     - `com.keepremind.alarm.ACTION_STOP`
     - `com.keepremind.alarm.ACTION_SNOOZE`
     - `com.keepremind.alarm.ACTION_TAKEN`
   - Spawns a native `Handler` timeout matching `maxDurationMinutes` (default 10 minutes) that automatically silences the alarm and posts a missed dose status if unanswered.

6. **`KeepRemindAlarmAudioPlayer.kt`**:
   - Plays alarm audio in an infinite loop using `android.media.MediaPlayer`.
   - Sets `AudioAttributes.USAGE_ALARM` and `AudioAttributes.CONTENT_TYPE_SONIFICATION` on `AudioManager.STREAM_ALARM`.
   - Acquires transient audio focus with ducking behavior.
   - Plays fallback system alarm (`RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)`) or system notification ringtone if custom tone is absent.
   - Drives rhythmic pattern vibration (`0, 800, 400, 800, 400, 800, 1000`) using `Vibrator` / `VibratorManager`.

7. **`KeepRemindAlarmActivity.kt`**:
   - Full-screen native UI (`activity_alarm.xml`) launched automatically over the lock screen.
   - Configured with `setShowWhenLocked(true)`, `setTurnScreenOn(true)`, and `FLAG_KEEP_SCREEN_ON`.
   - Styled with high-contrast dark theme (`#0F172A` background, `#10B981` primary green, `#EF4444` destructive stop).
   - Displays large readable clock, medicine name, dosage, meal instruction, and live pulsing indicator.
   - Renders three action buttons:
     - **✓ MARK AS TAKEN**: Silences alarm, records taken action in persistent offline queue, cancels notification, and finishes.
     - **⏰ SNOOZE (X min)**: Silences alarm, schedules an exact snooze alarm for `now + snoozeMinutes`, removes current notification, and finishes.
     - **SILENCE / STOP**: Silences audio and vibration, leaves dose pending for manual confirmation, and finishes.

8. **`KeepRemindAlarmActionReceiver.kt`**:
   - Handles background broadcasts when the user interacts with the notification actions instead of the full-screen activity.
   - Routes action to `KeepRemindAlarmService` and records offline actions identically.

9. **`KeepRemindAlarmBootReceiver.kt`**:
   - Listens for `Intent.ACTION_BOOT_COMPLETED` and `Intent.ACTION_MY_PACKAGE_REPLACED`.
   - Iterates through all active alarms saved in `KeepRemindAlarmStorage`.
   - Re-registers every exact alarm with `AlarmManager` immediately on startup, before any user launches the Flutter app.

---

## 3. Database Schema Migration (Version 2 to 3)

### 3.1 Migration Strategy
The Drift SQLite database was updated from `schemaVersion => 2` to `schemaVersion => 3`. Five new columns were introduced to the `medicines` table:

```dart
// lib/core/database/tables/medicine_tables.dart
TextColumn get reminderMode => text().withDefault(const Constant('notification'))();
TextColumn get alarmSound => text().nullable()();
BoolColumn get vibrationEnabled => boolean().withDefault(const Constant(true))();
IntColumn get snoozeDurationMinutes => integer().withDefault(const Constant(5))();
IntColumn get maximumRingingDurationMinutes => integer().withDefault(const Constant(10))();
```

In `lib/core/database/app_database.dart`:
```dart
@override
int get schemaVersion => 3;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
  },
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      // Version 2 migrations (Caregiver & Dose Logs)
      await m.createTable(caregiverContacts);
      await m.createTable(doseLogs);
    }
    if (from < 3) {
      // Version 3 migrations (Persistent Alarm Mode)
      await m.addColumn(medicines, medicines.reminderMode);
      await m.addColumn(medicines, medicines.alarmSound);
      await m.addColumn(medicines, medicines.vibrationEnabled);
      await m.addColumn(medicines, medicines.snoozeDurationMinutes);
      await m.addColumn(medicines, medicines.maximumRingingDurationMinutes);
    }
  },
);
```
Code generation was performed cleanly via `dart run build_runner build --delete-conflicting-outputs`. Existing database rows automatically default to `'notification'` mode, preserving 100% backward compatibility.

---

## 4. MethodChannel Bridge & Data Synchronization

### 4.1 Channel Specification
- **Channel Name:** `com.keepremind.app/alarm_manager`
- **Native Implementation:** `android/app/src/main/kotlin/com/keepremind/MainActivity.kt`
- **Dart Interface:** `lib/features/medicine_care/services/native_alarm_bridge.dart`

| Method | Arguments | Native Handler Action | Return |
| :--- | :--- | :--- | :--- |
| `scheduleAlarm` | `Map<String, dynamic>` (id, medicineId, medicineName, dosage, mealInstruction, doseTime, timestampMillis, snoozeMinutes, maxDurationMinutes, vibrationEnabled, soundUri) | `KeepRemindAlarmScheduler.scheduleAlarm(...)` | `bool` |
| `cancelAlarm` | `int id` | `KeepRemindAlarmScheduler.cancelAlarm(id)` | `bool` |
| `stopAlarm` | None | Stops current running `KeepRemindAlarmService` | `bool` |
| `getPendingActions` | None | Reads JSON array from `KeepRemindAlarmStorage.getPendingActions()` | `List<Map<String, dynamic>>` |
| `clearPendingAction` | `String actionId` | Removes action from `KeepRemindAlarmStorage` queue | `bool` |
| `hasExactAlarmPermission` | None | Queries `AlarmManager.canScheduleExactAlarms()` | `bool` |
| `hasFullScreenPermission` | None | Queries `NotificationManager.canUseFullScreenIntent()` | `bool` |

### 4.2 Offline Action Synchronization
When a user marks a dose as taken on the native lock screen activity or notification:
1. Kotlin native code records a JSON record into `keepremind_alarm_storage.xml`.
2. When the Flutter app opens or resumes:
   - `MedicineCubit.syncPendingNativeActions()` is invoked.
   - It queries `NativeAlarmBridge.getPendingActions()`.
   - For each pending action of type `taken`:
     - Checks if a `dose_log` already exists for that medicine, dose time, and scheduled date.
     - If not, inserts a new `DoseLog` record into Drift SQLite marked as `DoseStatus.taken`.
     - Calls `NativeAlarmBridge.clearPendingAction(actionId)` to acknowledge receipt.
   - Re-emits updated state, instantly updating today's taken counters and history charts.

---

## 5. Scheduling Flow: Notification Mode vs. Alarm Mode

In `MedicineNotificationService.dart`, reminder scheduling branches based on `medicine.reminderMode`:

```dart
if (medicine.reminderMode == MedicineReminderMode.alarm) {
  // 1. Ensure no duplicate standard notification fires
  await _notificationService.cancelNotification(scheduleId);
  // 2. Schedule exact native alarm
  await NativeAlarmBridge.scheduleAlarm(
    id: scheduleId,
    medicineId: medicine.id,
    medicineName: medicine.name,
    dosage: medicine.dosage,
    mealInstruction: medicine.instructions,
    doseTime: doseTime,
    scheduledDateTime: scheduledDateTime,
    snoozeMinutes: medicine.snoozeDurationMinutes,
    maxDurationMinutes: medicine.maximumRingingDurationMinutes,
    vibrationEnabled: medicine.vibrationEnabled,
  );
} else {
  // 1. Ensure no orphan native alarm exists
  await NativeAlarmBridge.cancelAlarm(scheduleId);
  // 2. Schedule standard zoned notification with IST timezone
  await _notificationService.scheduleZonedNotification(
    id: scheduleId,
    title: 'Time for medicine: ${medicine.name}',
    body: '${medicine.dosage} • ${medicine.instructions}...',
    scheduledDate: tz.TZDateTime.from(scheduledDateTime, tz.local),
    ...
  );
}
```

### Deletion & Updates
When a medicine is edited or deleted, `cancelMedicineSchedules` systematically invokes:
1. `_notificationService.cancelNotification(scheduleId)`
2. `NativeAlarmBridge.cancelAlarm(scheduleId)`
This guarantees zero phantom alarms or duplicate alerts under any circumstance.

---

## 6. Android Manifest & Permissions Compliance

### 6.1 Permissions Declared
```xml
<!-- Exact Alarms & Timing -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.VIBRATE"/>

<!-- Full Screen Lock Screen Display -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>

<!-- Android 14+ Foreground Media Playback -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>

<!-- Device Reboot Auto-Recovery -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### 6.2 Component Declarations
- **`KeepRemindAlarmService`**: `android:foregroundServiceType="mediaPlayback"`, `android:exported="false"`.
- **`KeepRemindAlarmActivity`**: `android:showWhenLocked="true"`, `android:turnScreenOn="true"`, `android:exported="false"`, `android:theme="@style/AlarmTheme"`.
- **`KeepRemindAlarmReceiver`**: `android:exported="false"`.
- **`KeepRemindAlarmActionReceiver`**: `android:exported="false"`.
- **`KeepRemindAlarmBootReceiver`**: `android:exported="true"` with intent-filters for `BOOT_COMPLETED` and `MY_PACKAGE_REPLACED`.

All runtime receivers and services are unexported (`exported="false"`) preventing unauthorized external applications from injecting alarms or stopping active alerts.

---

## 7. Verification & Testing Matrix

### 7.1 Automated Tests Summary
- **Total Test Suite:** 88 tests passing (`flutter test`).
- **Linter Status:** 0 errors, 0 warnings (`flutter analyze`).
- **Dedicated Alarm Mode Unit Tests:** `test/unit/persistent_alarm_mode_test.dart` (6 automated test cases):
  1. Default reminder mode initializes to `MedicineReminderMode.notification`.
  2. Entity parses `MedicineReminderMode.alarm` correctly with custom snooze and max ringing durations.
  3. `scheduleMedicineSchedules` routes Alarm Mode medicine to `NativeAlarmBridge` and cancels duplicate local notifications.
  4. `scheduleMedicineSchedules` routes Notification Mode medicine to `NotificationService` and cancels orphan alarms.
  5. `cancelMedicineSchedules` clears both notification and native alarm systems.
  6. Drift database Schema Version 3 migrations upgrade cleanly and retain existing rows.

### 7.2 Physical Hardware Verification
- **Device Tested:** Android 16 (API 36) Physical Hardware (`adb-10BE230DK20003Y-QFWz6H._adb-tls-connect._tcp`).
- **Package Tested:** `com.keepremind`.

| Test Scenario | Procedure | Observed Result | Status |
| :--- | :--- | :--- | :--- |
| **Instant Test Alarm Trigger** | Tapped "Test Alarm Mode (3s Delay)" in Settings | `scheduleAlarm ID 999991` returned `true`. After 3s delay, AlarmManager fired `RTC_WAKEUP`. | **PASS** |
| **Lock-Screen Presentation** | Device on lock screen / foreground when alarm fired | `KeepRemindAlarmActivity` launched immediately over lock screen with large clock, medicine name ("Paracetamol"), dosage, and high-contrast styling. | **PASS** |
| **Audio & Vibration** | Monitored audio stream and device haptics | Infinite looping `MediaPlayer` on `STREAM_ALARM` with rhythmic haptic vibration pattern. | **PASS** |
| **Mark as Taken Action** | Tapped "✓ MARK AS TAKEN" on full-screen UI | Audio and vibration immediately stopped. Activity finished cleanly. Action saved to `keepremind_alarm_storage.xml`. | **PASS** |
| **Data Sync on App Launch** | Force-stopped app and relaunched | `syncPendingNativeActions()` ingested the offline taken action into SQLite, cleared the pending queue (`pending_actions: []`), and refreshed UI. | **PASS** |
| **Notification Fallback Actions** | Verified background notification actions | High-priority notification displayed with STOP, SNOOZE, and MARK AS TAKEN action buttons. | **PASS** |
| **Snooze Functionality** | Tapped "⏰ SNOOZE (5 min)" | Current alert stopped; new exact alarm scheduled for `now + 5 minutes`. | **PASS** |
| **Auto-Timeout Protection** | Allowed test alarm to ring unhandled | At max ringing duration (10 min), native handler silenced audio, removed lock-screen UI, and retained missed notification. | **PASS** |
| **Add/Edit Medicine UI** | Opened Add Medicine screen | Interactive Reminder Mode selector (Notification vs Alarm), Vibrate switch, Snooze picker (5, 10, 15 min), and Max Ringing duration chips rendered and persisted. | **PASS** |

---

## 8. Edge Cases & Android Platform Safeguards

1. **App Force-Stop by User:**
   - As per Android OS security design, when a user manually force-stops an app via Android App Info, the OS suspends all AlarmManager intents until the user manually relaunches the application. KeepRemind stores all schedules in SQLite and re-reconciles all active alarms on subsequent app launch.
2. **Aggressive OEM Battery Optimization (Xiaomi, Vivo, Huawei, Samsung):**
   - KeepRemind requests `SCHEDULE_EXACT_ALARM`. For devices with aggressive background app killer policies, the Settings page directs users to whitelist KeepRemind from battery optimization to ensure zero alarm delays.
3. **Audio Routing During Phone Calls:**
   - `KeepRemindAlarmAudioPlayer` requests transient audio focus with ducking. During phone calls, the alarm tone ducks to avoid deafening the user while maintaining audible awareness.
4. **Volume Control:**
   - Audio is pinned strictly to `AudioManager.STREAM_ALARM`. Even if the device ringer or media volume is muted or on vibrate, the alarm stream volume controls the loudness.

---

## 9. Conclusion

The persistent Android Alarm Mode implementation provides KeepRemind with a clinical-grade medication alerting pipeline. By separating standard notifications from persistent alarms and eliminating background Dart VM execution, the architecture guarantees low battery consumption, rock-solid lock-screen reliability, and 100% data integrity with Drift SQLite.
