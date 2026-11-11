import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/storage/local_file_storage.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> with WidgetsBindingObserver {
  final AppDatabase database;
  final LocalFileStorage fileStorage;

  SettingsCubit({
    required this.database,
    required this.fileStorage,
  }) : super(const SettingsState()) {
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}
    loadSettings();
  }

  @override
  void didChangePlatformBrightness() {
    if (state.themeMode == ThemeMode.system) {
      AppColors.updateTheme(ThemeMode.system);
      emit(state.copyWith());
    }
  }

  @override
  Future<void> close() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    return super.close();
  }

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final settings = await database.select(database.appSettings).get();
      final map = {for (var s in settings) s.settingKey: s.settingValue};

      final themeMode = _parseThemeMode(map['theme_mode']);
      final notifEnabled = map['notifications_enabled'] != 'false';
      final remTime = map['reminder_time'] ?? '09:00';

      final storageBytes = await fileStorage.calculateDocumentsStorageUsed();
      final itemsCount = await database.select(database.trackedItems).get();
      final docsCount = await database.select(database.itemDocuments).get();
      final backups = await (database.select(database.backupHistory)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .get();

      final lastBackup = backups.isNotEmpty ? backups.first.createdAt : null;

      AppColors.updateTheme(themeMode);

      emit(state.copyWith(
        themeMode: themeMode,
        notificationsEnabled: notifEnabled,
        preferredReminderTime: remTime,
        storageBytesUsed: storageBytes,
        totalItemsCount: itemsCount.length,
        totalDocumentsCount: docsCount.length,
        lastBackupDate: lastBackup,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    AppColors.updateTheme(mode);
    emit(state.copyWith(themeMode: mode));
    await _saveSetting('theme_mode', mode.name);
  }

  Future<void> toggleNotifications(bool enabled) async {
    emit(state.copyWith(notificationsEnabled: enabled));
    await _saveSetting('notifications_enabled', enabled ? 'true' : 'false');
  }

  Future<void> setReminderTime(String time) async {
    emit(state.copyWith(preferredReminderTime: time));
    await _saveSetting('reminder_time', time);
  }

  Future<void> _saveSetting(String key, String value) async {
    await database.into(database.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            id: key,
            settingKey: key,
            settingValue: value,
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  }

  ThemeMode _parseThemeMode(String? val) {
    if (val == 'dark') return ThemeMode.dark;
    if (val == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }
}
