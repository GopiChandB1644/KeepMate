import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String preferredReminderTime;
  final int storageBytesUsed;
  final int totalItemsCount;
  final int totalDocumentsCount;
  final String? lastBackupDate;
  final bool isLoading;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.preferredReminderTime = '09:00',
    this.storageBytesUsed = 0,
    this.totalItemsCount = 0,
    this.totalDocumentsCount = 0,
    this.lastBackupDate,
    this.isLoading = false,
  });

  String get formattedStorageUsed {
    if (storageBytesUsed < 1024) return '$storageBytesUsed B';
    if (storageBytesUsed < 1024 * 1024) return '${(storageBytesUsed / 1024).toStringAsFixed(1)} KB';
    return '${(storageBytesUsed / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? preferredReminderTime,
    int? storageBytesUsed,
    int? totalItemsCount,
    int? totalDocumentsCount,
    String? lastBackupDate,
    bool? isLoading,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredReminderTime: preferredReminderTime ?? this.preferredReminderTime,
      storageBytesUsed: storageBytesUsed ?? this.storageBytesUsed,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      totalDocumentsCount: totalDocumentsCount ?? this.totalDocumentsCount,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

