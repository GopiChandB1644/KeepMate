class BackupConstants {
  BackupConstants._();

  static const String magic = 'KMB1';
  static const int currentFormatVersion = 1;
  static const int currentSchemaVersion = 1;
  static const int saltLength = 16;
  static const int ivLength = 16;
  static const int pbkdf2Iterations = 10000;
  static const String manifestFileName = 'manifest.json';
  static const String databaseFileName = 'keepmate_data.json';
  static const String preferencesFileName = 'preferences.json';
}

