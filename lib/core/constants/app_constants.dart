class AppConstants {
  AppConstants._();

  static const String appName = 'KeepRemind';
  static const String appTagline = 'Everything important. One place. Never forgotten.';
  static const String appVersion = '1.0.0';

  // Backup constants
  static const String kmbExtension = '.kmb';
  static const String kmbMagicHeader = 'KMB1';
  static const int kmbFormatVersion = 1;
  static const int databaseSchemaVersion = 1;

  // Folder names
  static const String documentsDirName = 'documents';
  static const String backupsDirName = 'backups';
  static const String stagingDirName = 'staging';

  // Notification Channels
  static const String reminderChannelId = 'keepremind_reminders';
  static const String reminderChannelName = 'Important Reminders';
  static const String reminderChannelDescription = 'Alerts for upcoming expiries, due dates, and document renewals.';
}

