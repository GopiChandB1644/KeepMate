import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../medicine_care/services/native_alarm_bridge.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../tracked_items/cubit/items_cubit.dart';
import '../../tracked_items/cubit/items_state.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'Settings',
        subtitle: 'Preferences & Storage',
        showBack: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // 1. App Identity Card (Calm, dignified brand header)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.cardBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppConstants.appName,
                                style: AppText.h2.copyWith(fontSize: 19),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'v${AppConstants.appVersion}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppConstants.appTagline,
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Status Banner ("Everything is Safe!" / "X Items Need Attention")
              Builder(
                builder: (context) {
                  ItemsState? itemsState;
                  try {
                    itemsState = context.watch<ItemsCubit>().state;
                  } catch (_) {
                    itemsState = null;
                  }

                  final urgent = itemsState?.urgentItems ?? const [];
                  final isSafe = urgent.isEmpty;
                  final attentionCount = (itemsState?.dueTodayCount ?? 0) +
                      (itemsState?.upcomingCount ?? 0) +
                      (itemsState?.expiredCount ?? 0);

                  final bannerBg = isSafe
                      ? AppColors.safeGreenSubtle
                      : AppColors.warningOrangeSubtle;
                  final bannerColor =
                      isSafe ? AppColors.safeGreen : AppColors.warningOrange;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bannerBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: bannerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: bannerColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isSafe
                                ? Icons.check_circle_rounded
                                : Icons.priority_high_rounded,
                            color: bannerColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSafe
                                    ? 'Everything is Safe!'
                                    : '$attentionCount Items Need Attention',
                                style: TextStyle(
                                  color: bannerColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSafe
                                    ? 'No bills or products expiring soon.'
                                    : 'Due today or upcoming in the next 7 days.',
                                style: AppText.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 3. Storage Info Section
              Text(
                'Device Storage',
                style: AppText.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.cardBorderColor),
                ),
                child: Column(
                  children: [
                    _statRow(
                      Icons.description_outlined,
                      'Items Tracked',
                      '${state.totalItemsCount} records',
                    ),
                    const Divider(height: 16),
                    _statRow(
                      Icons.folder_open_outlined,
                      'Documents Stored',
                      '${state.totalDocumentsCount} files',
                    ),
                    const Divider(height: 16),
                    _statRow(
                      Icons.storage_rounded,
                      'Storage Used',
                      state.formattedStorageUsed,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cleaning_services_rounded,
                            size: 16),
                        label: const Text('Clean Deleted Storage Cache'),
                        onPressed: () async {
                          final freed = await cubit.cleanOrphanedFiles();
                          if (context.mounted) {
                            final kb = (freed / 1024).toStringAsFixed(1);
                            showToast(
                              context,
                              freed > 0
                                  ? 'Cleaned up $kb KB of orphaned storage!'
                                  : 'Storage is already optimized!',
                              icon: Icons.check_circle_rounded,
                              type: ToastType.success,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Preferences Section
              Text(
                'Preferences',
                style: AppText.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Material(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.cardBorderColor),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text(
                          'Expiry & Due Reminders',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Receive alerts before bills or documents expire',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: state.notificationsEnabled,
                        onChanged: (val) => cubit.toggleNotifications(val),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time_rounded,
                            color: AppColors.warningOrange),
                        title: const Text(
                          'Daily Alert Time',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Notifications arrive at ${AppDateUtils.formatTime12Hour(state.preferredReminderTime)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          final parts = state.preferredReminderTime.split(':');
                          final initH = parts.isNotEmpty
                              ? (int.tryParse(parts[0]) ?? 9)
                              : 9;
                          final initM = parts.length > 1
                              ? (int.tryParse(parts[1]) ?? 0)
                              : 0;
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: initH, minute: initM),
                          );
                          if (picked != null) {
                            final h = picked.hour.toString().padLeft(2, '0');
                            final m = picked.minute.toString().padLeft(2, '0');
                            cubit.setReminderTime('$h:$m');
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined,
                            color: AppColors.freshCheckColor),
                        title: const Text(
                          'Send Test Alert',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Fire an instant notification to test heads-up banner & sound',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.send_rounded,
                            size: 18, color: AppColors.freshCheckColor),
                        onTap: () async {
                          final notif = context.read<NotificationService>();
                          await notif.showNotification(
                            id: 99999,
                            title: '🔔 KeepRemind: System Test',
                            body:
                                'Local notifications, exact alarms, and notification channels are working perfectly!',
                          );
                          if (context.mounted) {
                            showToast(
                              context,
                              'Test notification sent! Check your notification bar.',
                              icon: Icons.check_circle_rounded,
                              type: ToastType.success,
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.alarm_outlined,
                            color: AppColors.medicineCareColor),
                        title: const Text(
                          'Test Alarm Mode (3s Delay)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Triggers native full-screen alarm & continuous ring',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.play_circle_fill_rounded,
                            size: 20, color: AppColors.medicineCareColor),
                        onTap: () async {
                          final triggerTime =
                              DateTime.now().add(const Duration(seconds: 3));
                          final timeStr =
                              '${triggerTime.hour.toString().padLeft(2, '0')}:${triggerTime.minute.toString().padLeft(2, '0')}';
                          await NativeAlarmBridge().scheduleAlarm(
                            id: 999991,
                            medicineId: 'test-alarm-diag',
                            medicineName: 'Paracetamol',
                            dosage: '650 mg',
                            mealInstruction: 'After Food',
                            doseTime: timeStr,
                            triggerDateTime: triggerTime,
                            snoozeMinutes: 5,
                            maxDurationMinutes: 10,
                            vibrationEnabled: true,
                          );
                          if (context.mounted) {
                            showToast(
                              context,
                              'Alarm scheduled for 3s from now! Lock phone or wait.',
                              icon: Icons.alarm_on_rounded,
                              type: ToastType.success,
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined,
                            color: AppColors.vaultColor),
                        title: const Text(
                          'Appearance / Theme',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          state.themeMode.name.toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: DropdownButton<ThemeMode>(
                          value: state.themeMode,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                                value: ThemeMode.system, child: Text('System')),
                            DropdownMenuItem(
                                value: ThemeMode.light, child: Text('Light')),
                            DropdownMenuItem(
                                value: ThemeMode.dark, child: Text('Dark')),
                          ],
                          onChanged: (val) {
                            if (val != null) cubit.setThemeMode(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 5. Data Security & Backup Section
              Text(
                'Security & Backups',
                style: AppText.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Material(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.cardBorderColor),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.lock_reset_rounded,
                        color: AppColors.safeGreen),
                    title: const Text(
                      'Backup & Restore (.kmb)',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      state.lastBackupDate != null
                          ? 'Last backup: ${AppDateUtils.formatDisplay(DateTime.tryParse(state.lastBackupDate!))}'
                          : 'No backup created yet',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(AppRoutes.backupRestore),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: AppText.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppText.h3.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
