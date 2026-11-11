import 'dart:convert';
import '../constants/app_constants.dart';
import 'backup_constants.dart';

class BackupManifest {
  final String appName;
  final String backupId;
  final String createdAt;
  final int formatVersion;
  final int schemaVersion;
  final int documentCount;
  final int itemCount;
  final String appVersion;
  final List<BackupDocumentEntry> documents;

  const BackupManifest({
    this.appName = AppConstants.appName,
    required this.backupId,
    required this.createdAt,
    this.formatVersion = BackupConstants.currentFormatVersion,
    this.schemaVersion = BackupConstants.currentSchemaVersion,
    required this.documentCount,
    required this.itemCount,
    this.appVersion = AppConstants.appVersion,
    required this.documents,
  });

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'backupId': backupId,
        'createdAt': createdAt,
        'formatVersion': formatVersion,
        'schemaVersion': schemaVersion,
        'documentCount': documentCount,
        'itemCount': itemCount,
        'appVersion': appVersion,
        'documents': documents.map((d) => d.toJson()).toList(),
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    final docsList = (json['documents'] as List<dynamic>? ?? [])
        .map((e) => BackupDocumentEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return BackupManifest(
      appName: json['appName'] as String? ?? AppConstants.appName,
      backupId: json['backupId'] as String,
      createdAt: json['createdAt'] as String,
      formatVersion: json['formatVersion'] as int? ?? BackupConstants.currentFormatVersion,
      schemaVersion: json['schemaVersion'] as int? ?? BackupConstants.currentSchemaVersion,
      documentCount: json['documentCount'] as int? ?? docsList.length,
      itemCount: json['itemCount'] as int? ?? 0,
      appVersion: json['appVersion'] as String? ?? AppConstants.appVersion,
      documents: docsList,
    );
  }

  String encode() => jsonEncode(toJson());

  factory BackupManifest.decode(String jsonString) =>
      BackupManifest.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}

class BackupDocumentEntry {
  final String id;
  final String fileName;
  final String relativePath;
  final String checksumSha256;
  final int fileSize;

  const BackupDocumentEntry({
    required this.id,
    required this.fileName,
    required this.relativePath,
    required this.checksumSha256,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'relativePath': relativePath,
        'checksumSha256': checksumSha256,
        'fileSize': fileSize,
      };

  factory BackupDocumentEntry.fromJson(Map<String, dynamic> json) => BackupDocumentEntry(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        relativePath: json['relativePath'] as String,
        checksumSha256: json['checksumSha256'] as String,
        fileSize: json['fileSize'] as int,
      );
}

