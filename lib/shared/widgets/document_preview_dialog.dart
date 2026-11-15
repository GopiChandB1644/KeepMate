import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/app_database.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text.dart';
import 'app_toast.dart';

class DocumentPreviewDialog extends StatelessWidget {
  final File file;
  final ItemDocument document;
  final VoidCallback? onDelete;

  const DocumentPreviewDialog({
    super.key,
    required this.file,
    required this.document,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required File file,
    required ItemDocument document,
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DocumentPreviewDialog(
        file: file,
        document: document,
        onDelete: onDelete,
      ),
    );
  }

  bool get _isPdf => document.fileName.toLowerCase().endsWith('.pdf');

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      final xfile = XFile(file.path, name: document.fileName);
      await Share.shareXFiles([xfile], text: document.fileName);
    } catch (e) {
      if (context.mounted) {
        showToast(
          context,
          'Could not open share sheet: $e',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (_isPdf ? AppColors.dangerRed : AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
              color: _isPdf ? AppColors.dangerRed : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: AppText.h3.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_formatSize(document.fileSize)} • ${_isPdf ? "PDF Document" : "Image"}',
                  style: AppText.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              if (_isPdf) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 64,
                        color: AppColors.dangerRed,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'PDF Document Ready',
                        style: AppText.h3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Saved securely in local storage.\nOpen in external viewer or share with other apps.',
                        textAlign: TextAlign.center,
                        style: AppText.bodySmall,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () => _shareFile(context),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('Open / Share Document'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 340),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.file(
                        file,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          alignment: Alignment.center,
                          color: AppColors.surfaceRaised,
                          child: const Text('Unable to load image preview'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (onDelete != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w600)),
          ),
        if (!_isPdf)
          TextButton.icon(
            onPressed: () => _shareFile(context),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Share'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
