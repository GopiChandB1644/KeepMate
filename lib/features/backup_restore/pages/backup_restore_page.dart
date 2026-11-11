import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/backup_state.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showCreateBackupDialog() {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Protect Your Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a password to encrypt your backup file. You will need this password if you ever restore your data on this or a new phone.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter secret password',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final pwd = _passwordController.text.trim();
              if (pwd.length < 4) {
                showToast(
                  context,
                  'Password must be at least 4 characters',
                  icon: Icons.lock_outline_rounded,
                  type: ToastType.warning,
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<BackupCubit>().createBackup(password: pwd);
            },
            child: const Text('Create .kmb Backup'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndRestore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);

    if (!mounted) return;

    _passwordController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlock Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the password for ${file.uri.pathSegments.last}:'),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Backup password',
                prefixIcon: Icon(Icons.lock_open_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final pwd = _passwordController.text.trim();
              Navigator.pop(ctx);
              context.read<BackupCubit>().inspectBackupFile(file: file, password: pwd);
            },
            child: const Text('Inspect & Verify'),
          ),
        ],
      ),
    );
  }

  void _showRestorePreviewDialog(BackupState state) {
    final preview = state.preview!;
    final manifest = preview.manifest;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A valid KeepMate backup was verified! Restoring will sync all items, files, and reschedule your notifications.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _infoRow('Items to restore', '${manifest.itemCount}'),
                  _infoRow('Documents', '${manifest.documentCount}'),
                  _infoRow('Created on', AppDateUtils.formatDisplay(DateTime.tryParse(manifest.createdAt))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BackupCubit>().resetStatus();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BackupCubit>().confirmRestore();
            },
            child: const Text('Confirm Restore'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepMateAppBar(
        title: 'Backup & Restore',
        subtitle: 'Encrypted export & recovery',
      ),
      body: BlocConsumer<BackupCubit, BackupState>(
        listener: (context, state) {
          if (state.status == BackupOperationStatus.exportSuccess && state.exportedFile != null) {
            showToast(
              context,
              '✅ Backup created! You can now share or save it.',
              icon: Icons.shield_rounded,
              type: ToastType.success,
            );
          } else if (state.status == BackupOperationStatus.inspectSuccess && state.preview != null) {
            _showRestorePreviewDialog(state);
          } else if (state.status == BackupOperationStatus.restoreSuccess) {
            showToast(
              context,
              '🎉 Restore complete! All records & documents recovered.',
              icon: Icons.check_circle_rounded,
              type: ToastType.success,
            );
          } else if (state.status == BackupOperationStatus.failure && state.errorMessage != null) {
            showToast(
              context,
              state.errorMessage!,
              icon: Icons.error_outline_rounded,
              type: ToastType.error,
            );
          }
        },
        builder: (context, state) {
          final isBusy = state.status == BackupOperationStatus.exporting ||
              state.status == BackupOperationStatus.inspecting ||
              state.status == BackupOperationStatus.restoring;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Security Warning Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: Color(0xFFB45309), size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Local-First Privacy',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'KeepMate keeps 100% of your documents and data on your phone. To avoid losing data if you change phones, create an encrypted backup regularly.',
                            style: AppText.bodySmall.copyWith(color: const Color(0xFF78350F)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (isBusy) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    state.status == BackupOperationStatus.exporting
                        ? 'Creating encrypted .kmb backup...'
                        : state.status == BackupOperationStatus.restoring
                            ? 'Restoring records and files...'
                            : 'Inspecting backup...',
                    style: AppText.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Create Backup Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create New Backup', style: AppText.h3),
                    const SizedBox(height: 6),
                    Text(
                      'Packs all items, receipts, and photos into a password-protected .kmb file. You can email it to yourself or save to Google Drive.',
                      style: AppText.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isBusy ? null : _showCreateBackupDialog,
                      icon: const Icon(Icons.archive_rounded),
                      label: const Text('Create Encrypted Backup'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                    if (state.exportedFile != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.read<BackupCubit>().shareBackup(state.exportedFile!),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share / Save Last Backup File'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Restore Backup Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Restore from Backup', style: AppText.h3),
                    const SizedBox(height: 6),
                    Text(
                      'Select a .kmb file from your device to recover all items and documents.',
                      style: AppText.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isBusy ? null : _pickAndRestore,
                      icon: const Icon(Icons.unarchive_rounded),
                      label: const Text('Select .kmb File to Restore'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('Backup History', style: AppText.h3),
              const SizedBox(height: 10),

              if (state.history.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('No backups recorded yet on this device.'),
                )
              else
                ...state.history.map((record) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_rounded, color: AppColors.safeGreen),
                      title: Text('Backup ${record.backupId.substring(0, 8)}...'),
                      subtitle: Text(
                        '${(record.fileSize / 1024).toStringAsFixed(1)} KB • ${AppDateUtils.formatDisplay(DateTime.tryParse(record.createdAt))}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.safeGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Encrypted',
                          style: TextStyle(fontSize: 11, color: AppColors.safeGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

