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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add File to Vault', style: AppText.h3),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Take a Photo / Scan'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1920,
                    maxHeight: 1920,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    final compressed = await ImageCompressor.compress(picked.path, purpose: ImagePurpose.document);
                    await cubit.uploadDocument(file: File(compressed), source: 'camera');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                title: const Text('Choose Photo from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1920,
                    maxHeight: 1920,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    final compressed = await ImageCompressor.compress(picked.path, purpose: ImagePurpose.document);
                    await cubit.uploadDocument(file: File(compressed), source: 'gallery');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.dangerRed),
                title: const Text('Select PDF Document'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.single.path != null) {
                    await cubit.uploadDocument(file: File(result.files.single.path!), source: 'pdf_picker');
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
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(doc.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
            content: doc.fileName.toLowerCase().endsWith('.pdf')
                ? const Text('PDF file ready. Previewing document from local storage.')
                : Image.file(file),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<VaultCubit>().deleteDocument(doc);
                },
                child: const Text('Delete', style: TextStyle(color: AppColors.dangerRed)),
              ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ],
          ),
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
      appBar: const KeepMateAppBar(
        title: 'Document Vault',
        subtitle: 'Secure local storage',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickAndUpload(context),
        backgroundColor: AppColors.vaultColor,
        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: const Text('Add Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<VaultCubit, VaultState>(
        builder: (context, state) {
          final docs = state.filteredDocuments;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (val) => context.read<VaultCubit>().search(val),
                  decoration: InputDecoration(
                    hintText: 'Search files in vault...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    fillColor: AppColors.surface,
                  ),
                ),
              ),
              Expanded(
                child: docs.isEmpty
                    ? EmptyStateView(
                        icon: Icons.folder_zip_rounded,
                        title: 'Vault is empty',
                        description: 'Store insurance policies, receipts, IDs and bills securely on your device.',
                        actionLabel: 'Upload First Document',
                        onAction: () => _pickAndUpload(context),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final isPdf = doc.fileName.toLowerCase().endsWith('.pdf');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isPdf ? AppColors.dangerRed : AppColors.primary).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                                  color: isPdf ? AppColors.dangerRed : AppColors.primary,
                                ),
                              ),
                              title: Text(doc.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${(doc.fileSize / 1024).toStringAsFixed(1)} KB • Stored Locally'),
                              trailing: const Icon(Icons.visibility_rounded),
                              onTap: () => _previewDocument(context, doc),
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
