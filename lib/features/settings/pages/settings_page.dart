import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../backup_restore/pages/backup_restore_page.dart';
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
                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppConstants.appTagline,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    _statRow(Icons.description_rounded, 'Items Tracked', '${state.totalItemsCount} records'),
                    const Divider(),
                    _statRow(Icons.folder_open_rounded, 'Documents Stored', '${state.totalDocumentsCount} files'),
                    const Divider(),
                    _statRow(Icons.storage_rounded, 'Storage Used', state.formattedStorageUsed),
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
                        secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                        title: const Text('Expiry & Due Reminders'),
                        subtitle: const Text('Receive alerts before bills or documents expire'),
                        value: state.notificationsEnabled,
                        onChanged: (val) => cubit.toggleNotifications(val),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time_filled_rounded, color: AppColors.warningOrange),
                        title: const Text('Daily Alert Time'),
                        subtitle: Text('Notifications arrive at ${state.preferredReminderTime} AM'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
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
                        leading: const Icon(Icons.dark_mode_rounded, color: AppColors.vaultColor),
                        title: const Text('Appearance / Theme'),
                        subtitle: Text(state.themeMode.name.toUpperCase()),
                        trailing: DropdownButton<ThemeMode>(
                          value: state.themeMode,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                            DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                            DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
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
                    leading: const Icon(Icons.lock_reset_rounded, color: AppColors.safeGreen),
                    title: const Text('Backup & Restore (.kmb)'),
                    subtitle: Text(state.lastBackupDate != null
                        ? 'Last backup: ${AppDateUtils.formatDisplay(DateTime.tryParse(state.lastBackupDate!))}'
                        : 'No backup created yet'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BackupRestorePage()),
                      );
                    },
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
