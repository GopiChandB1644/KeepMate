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
            padding: const EdgeInsets.all(20),
            children: [
              // App Identity Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppConstants.appTagline,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Status Banner ("Everything is Safe!" / "X Items Need Attention")
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

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSafe
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [
                                const Color(0xFFF59E0B),
                                const Color(0xFFDC2626)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isSafe
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFDC2626))
                              .withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSafe
                                ? Icons.check_circle_rounded
                                : Icons.priority_high_rounded,
                            color: Colors.white,
                            size: 30,
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isSafe
                                    ? 'No bills or products expiring soon.'
                                    : 'Due today or upcoming in the next 7 days.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
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

              const SizedBox(height: 24),

              // Storage Info Section
              Text('Device Storage', style: AppText.h3),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _statRow(Icons.description_rounded, 'Items Tracked',
                        '${state.totalItemsCount} records'),
                    const Divider(),
                    _statRow(Icons.folder_open_rounded, 'Documents Stored',
                        '${state.totalDocumentsCount} files'),
                    const Divider(),
                    _statRow(Icons.storage_rounded, 'Storage Used',
                        state.formattedStorageUsed),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cleaning_services_rounded,
                            size: 18),
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

              const SizedBox(height: 24),

              // Preferences Section
              Text('Preferences', style: AppText.h3),
              const SizedBox(height: 10),
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.primary),
                        title: const Text('Expiry & Due Reminders'),
                        subtitle: const Text(
                            'Receive alerts before bills or documents expire'),
                        value: state.notificationsEnabled,
                        onChanged: (val) => cubit.toggleNotifications(val),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time_filled_rounded,
                            color: AppColors.warningOrange),
                        title: const Text('Daily Alert Time'),
                        subtitle: Text(
                            'Notifications arrive at ${AppDateUtils.formatTime12Hour(state.preferredReminderTime)}'),
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
                        leading: const Icon(Icons.notifications_active_outlined,
                            color: AppColors.freshCheckColor),
                        title: const Text('Send Test Alert'),
                        subtitle: const Text(
                            'Fire an instant notification to test heads-up banner & sound'),
                        trailing: const Icon(Icons.send_rounded,
                            size: 20, color: AppColors.freshCheckColor),
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
                        leading: const Icon(Icons.alarm_rounded,
                            color: AppColors.medicineCareColor),
                        title: const Text('Test Alarm Mode (3s Delay)'),
                        subtitle: const Text(
                            'Triggers native full-screen alarm & continuous ring'),
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
                        leading: const Icon(Icons.dark_mode_rounded,
                            color: AppColors.vaultColor),
                        title: const Text('Appearance / Theme'),
                        subtitle: Text(state.themeMode.name.toUpperCase()),
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

              const SizedBox(height: 24),

              // Data Security & Backup Section
              Text('Security & Backups', style: AppText.h3),
              const SizedBox(height: 10),
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.lock_reset_rounded,
                        color: AppColors.safeGreen),
                    title: const Text('Backup & Restore (.kmb)'),
                    subtitle: Text(state.lastBackupDate != null
                        ? 'Last backup: ${AppDateUtils.formatDisplay(DateTime.tryParse(state.lastBackupDate!))}'
                        : 'No backup created yet'),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: AppText.bodyMedium),
          const Spacer(),
          Text(value, style: AppText.h3),
        ],
      ),
    );
  }
}
