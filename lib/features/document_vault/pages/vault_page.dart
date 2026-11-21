import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/storage/file_path_resolver.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../shared/widgets/widgets.dart';
import '../cubit/vault_cubit.dart';
import '../cubit/vault_state.dart';

class VaultPage extends StatelessWidget {
  const VaultPage({super.key});

  Future<void> _pickAndUpload(BuildContext context) async {
    final cubit = context.read<VaultCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('Add File to Vault', style: AppText.h3),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Capture document with camera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 2000,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    final compressed = await ImageCompressor.compress(
                      picked.path,
                      purpose: ImagePurpose.document,
                    );
                    await cubit.uploadDocument(
                      file: File(compressed),
                      source: 'camera',
                    );
                  }
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.safeGreenSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Choose Photo from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Pick existing image from device'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 2000,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    final compressed = await ImageCompressor.compress(
                      picked.path,
                      purpose: ImagePurpose.document,
                    );
                    await cubit.uploadDocument(
                      file: File(compressed),
                      source: 'gallery',
                    );
                  }
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.dangerRedSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppColors.dangerRed,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Select PDF Document',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Upload PDF document'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.single.path != null) {
                    await cubit.uploadDocument(
                      file: File(result.files.single.path!),
                      source: 'pdf_picker',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _previewDocument(BuildContext context, ItemDocument doc) async {
    try {
      final file = await FilePathResolver.resolveRelativePath(doc.relativePath);
      if (!context.mounted) return;
      if (await file.exists()) {
        if (!context.mounted) return;
        await DocumentPreviewDialog.show(
          context: context,
          file: file,
          document: doc,
          onDelete: () {
            context.read<VaultCubit>().deleteDocument(doc);
            showToast(
              context,
              'Document removed from vault',
              icon: Icons.delete_outline_rounded,
              type: ToastType.info,
            );
          },
        );
      } else {
        if (!context.mounted) return;
        showToast(
          context,
          'File not found on local storage',
          icon: Icons.error_outline_rounded,
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      showToast(
        context,
        'Failed to open file: $e',
        icon: Icons.error_outline_rounded,
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KeepRemindAppBar(
        title: 'Document Vault',
        subtitle: 'Secure local storage',
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickAndUpload(context),
        backgroundColor: AppColors.vaultColor,
        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: const Text(
          'Add Document',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      body: BlocBuilder<VaultCubit, VaultState>(
        builder: (context, state) {
          final docs = state.filteredDocuments;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: TextField(
                  onChanged: (val) => context.read<VaultCubit>().search(val),
                  decoration: InputDecoration(
                    hintText: 'Search files in vault...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    fillColor: AppColors.surface,
                  ),
                ),
              ),
              if (docs.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${docs.length} stored documents',
                        style: AppText.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: AppColors.safeGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Encrypted On-Device',
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.safeGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: docs.isEmpty
                    ? EmptyStateView(
                        icon: Icons.folder_zip_outlined,
                        title: 'Vault is empty',
                        description:
                            'Store insurance policies, receipts, IDs and bills securely on your device.',
                        actionLabel: 'Upload First Document',
                        onAction: () => _pickAndUpload(context),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final isPdf =
                              doc.fileName.toLowerCase().endsWith('.pdf');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: context.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: context.cardBorderColor),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _previewDocument(context, doc),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: (isPdf
                                                  ? AppColors.dangerRed
                                                  : AppColors.primary)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isPdf
                                              ? Icons.picture_as_pdf_rounded
                                              : Icons.image_rounded,
                                          color: isPdf
                                              ? AppColors.dangerRed
                                              : AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc.fileName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppText.h3
                                                  .copyWith(fontSize: 15),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${(doc.fileSize / 1024).toStringAsFixed(1)} KB • Stored Locally',
                                              style: AppText.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 20,
                                        ),
                                        tooltip: 'View Document',
                                        onPressed: () =>
                                            _previewDocument(context, doc),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
