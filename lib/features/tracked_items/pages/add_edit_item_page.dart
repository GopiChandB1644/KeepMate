import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../core/storage/local_file_storage.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/services/lost_data_service.dart';
import '../../document_scanner/services/ocr_parser_service.dart';
import '../../../shared/widgets/widgets.dart';
import '../cubit/items_cubit.dart';
import '../domain/entities/tracked_item_entity.dart';

class AddEditItemPage extends StatefulWidget {
  final TrackedItemEntity? existingItem;
  final ItemSubcategory? initialSubcategory;

  const AddEditItemPage({
    super.key,
    this.existingItem,
    this.initialSubcategory,
  });

  @override
  State<AddEditItemPage> createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final _formKey = GlobalKey<FormState>();

  late ItemSubcategory _selectedSubcategory;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _providerOrSellerController;
  late final TextEditingController _docNumberController;
  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _amountController;
  late final TextEditingController _quantityController;

  DateTime? _selectedTargetDate;
  DateTime? _selectedStartDate;
  StorageLocation _selectedStorage = StorageLocation.pantry;
  String _quantityUnit = 'units';
  final String _billingCycle = 'monthly';

  final List<int> _reminderOffsets = [7, 1];
  final List<File> _attachedFiles = [];
  bool _isSaving = false;
  bool _isExtractingText = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _selectedSubcategory = item?.subcategory ?? widget.initialSubcategory ?? ItemSubcategory.bill;

    _titleController = TextEditingController(text: item?.title ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _providerOrSellerController = TextEditingController(
      text: item?.billDetails?.providerName ??
          item?.warrantyDetails?.seller ??
          item?.insuranceDetails?.provider ??
          item?.purchaseDetails?.seller ??
          item?.subscriptionDetails?.serviceName ??
          '',
    );
    _docNumberController = TextEditingController(
      text: item?.insuranceDetails?.policyNumber ??
          item?.documentDetails?.documentNumber ??
          item?.billDetails?.accountNumber ??
          item?.groceryDetails?.batchNumber ??
          '',
    );
    _vehicleNumberController = TextEditingController(
      text: item?.insuranceDetails?.vehicleNumber ?? '',
    );
    _amountController = TextEditingController(
      text: item?.billDetails?.amount?.toString() ??
          item?.warrantyDetails?.purchaseAmount?.toString() ??
          item?.insuranceDetails?.premiumAmount?.toString() ??
          item?.subscriptionDetails?.amount?.toString() ??
          item?.purchaseDetails?.purchaseAmount?.toString() ??
          '',
    );
    _quantityController = TextEditingController(
      text: item?.groceryDetails?.quantityRemaining.toString() ?? '1',
    );

    _selectedTargetDate = item?.targetDate;
    _selectedStartDate = item?.startDate;

    if (item?.groceryDetails != null) {
      _selectedStorage = StorageLocation.fromCode(item!.groceryDetails!.storageLocation);
      _quantityUnit = item.groceryDetails!.quantityUnit;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLostData();
      LostDataService.instance.recoveredFileNotifier.addListener(_onRecoveredFileChanged);
    });
  }

  void _onRecoveredFileChanged() {
    final file = LostDataService.instance.recoveredFileNotifier.value;
    if (file != null && mounted) {
      LostDataService.instance.clearRecoveredFile();
      _processAttachedFile(file);
    }
  }

  Future<void> _checkLostData() async {
    try {
      final response = await ImagePicker().retrieveLostData();
      if (response.isEmpty) return;
      final file = response.file;
      if (file != null && mounted) {
        final compressed = await ImageCompressor.compress(file.path, purpose: ImagePurpose.document);
        await _processAttachedFile(File(compressed));
      }
    } catch (e) {
      debugPrint('retrieveLostData error: $e');
    }
  }

  @override
  void dispose() {
    LostDataService.instance.recoveredFileNotifier.removeListener(_onRecoveredFileChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _providerOrSellerController.dispose();
    _docNumberController.dispose();
    _vehicleNumberController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  ItemCategory get _categoryForSubcategory {
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
      case ItemSubcategory.warranty:
      case ItemSubcategory.insurance:
      case ItemSubcategory.subscription:
      case ItemSubcategory.purchase:
        return ItemCategory.lifePocket;
      case ItemSubcategory.grocery:
        return ItemCategory.freshCheck;
      case ItemSubcategory.document:
        return ItemCategory.docAlert;
    }
  }

  Future<void> _pickAttachment() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Attach Photo or Document', style: AppText.h3),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Take a Photo'),
                subtitle: const Text('Capture document, bill, or item with camera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 2000,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    final compressed = await ImageCompressor.compress(picked.path, purpose: ImagePurpose.document);
                    await _processAttachedFile(File(compressed));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select photo from gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 2000,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    final compressed = await ImageCompressor.compress(picked.path, purpose: ImagePurpose.document);
                    await _processAttachedFile(File(compressed));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.dangerRed),
                title: const Text('Upload PDF Document'),
                subtitle: const Text('Select PDF bill, receipt, or policy'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.single.path != null) {
                    await _processAttachedFile(File(result.files.single.path!));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processAttachedFile(File file) async {
    setState(() {
      _attachedFiles.add(file);
      _isExtractingText = true;
    });

    showToast(
      context,
      'Reading document & extracting details...',
      icon: Icons.document_scanner_rounded,
      type: ToastType.info,
      duration: const Duration(seconds: 4),
    );

    try {
      final rawText = await OcrParserService.extractText(file);
      if (!mounted) return;

      if (rawText.trim().isEmpty) {
        setState(() {
          _isExtractingText = false;
        });
        showToast(
          context,
          'Document attached. No readable text found — please enter details manually.',
          icon: Icons.info_outline_rounded,
          type: ToastType.warning,
        );
        return;
      }

      final parser = const OcrParserService();
      final parsed = parser.parse(text: rawText, expectedSubcategory: _selectedSubcategory);

      setState(() {
        if (_titleController.text.trim().isEmpty && parsed.title != null) {
          _titleController.text = parsed.title!;
        }
        if (_providerOrSellerController.text.trim().isEmpty && parsed.providerOrSeller != null) {
          _providerOrSellerController.text = parsed.providerOrSeller!;
        }
        if (_docNumberController.text.trim().isEmpty && parsed.documentOrPolicyNumber != null) {
          _docNumberController.text = parsed.documentOrPolicyNumber!;
        }
        if (_vehicleNumberController.text.trim().isEmpty && parsed.vehicleNumber != null) {
          _vehicleNumberController.text = parsed.vehicleNumber!;
        }
        if (_amountController.text.trim().isEmpty && parsed.amount != null) {
          _amountController.text = parsed.amount!.toStringAsFixed(parsed.amount! % 1 == 0 ? 0 : 2);
        }
        if (_selectedTargetDate == null && parsed.expiryDate != null) {
          _selectedTargetDate = parsed.expiryDate;
        }
        if (_selectedStartDate == null && parsed.startDate != null) {
          _selectedStartDate = parsed.startDate;
        }
        if (parsed.detectedSubcategory != null &&
            _selectedSubcategory == ItemSubcategory.bill &&
            parsed.detectedSubcategory != _selectedSubcategory) {
          _selectedSubcategory = parsed.detectedSubcategory!;
        }
        _isExtractingText = false;
      });

      if (parsed.detectedFields.isNotEmpty) {
        showToast(
          context,
          '✨ Auto-filled: ${parsed.detectedFields.join(', ')}',
          icon: Icons.auto_awesome_rounded,
          type: ToastType.success,
          duration: const Duration(seconds: 4),
        );
      } else {
        showToast(
          context,
          'Document attached. Please review and fill details.',
          icon: Icons.check_circle_outline_rounded,
          type: ToastType.info,
        );
      }
    } catch (e) {
      debugPrint('Text extraction failed: $e');
      if (mounted) {
        setState(() {
          _isExtractingText = false;
        });
        showToast(
          context,
          'Document attached. (Extraction note: $e)',
          icon: Icons.error_outline_rounded,
          type: ToastType.warning,
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? now.add(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2045),
    );
    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  void _applyQuickDatePreset(int days) {
    setState(() {
      _selectedTargetDate = DateTime.now().add(Duration(days: days));
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTargetDate == null) {
      showToast(
        context,
        'Please select an expiry or due date',
        icon: Icons.event_busy_rounded,
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);
    final cubit = context.read<ItemsCubit>();
    final fileStorage = context.read<LocalFileStorage>();
    final uuid = const Uuid();

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final itemId = widget.existingItem?.id ?? uuid.v4();
    final targetDateStr = AppDateUtils.formatDateOnly(_selectedTargetDate!);
    final startDateStr = _selectedStartDate != null ? AppDateUtils.formatDateOnly(_selectedStartDate!) : null;

    final baseItem = TrackedItemsCompanion(
      id: drift.Value(itemId),
      category: drift.Value(_categoryForSubcategory.code),
      subcategory: drift.Value(_selectedSubcategory.code),
      title: drift.Value(_titleController.text.trim()),
      description: drift.Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
      purchaseDate: drift.Value(startDateStr),
      issueDate: drift.Value(startDateStr),
      startDate: drift.Value(startDateStr),
      dueDate: drift.Value(targetDateStr),
      expiryDate: drift.Value(targetDateStr),
      status: const drift.Value('active'),
      createdAt: drift.Value(widget.existingItem?.baseItem.createdAt ?? nowIso),
      updatedAt: drift.Value(nowIso),
    );

    // Prepare Category Details
    BillDetailsCompanion? bill;
    WarrantyDetailsCompanion? warranty;
    InsuranceDetailsCompanion? insurance;
    SubscriptionDetailsCompanion? subscription;
    PurchaseDetailsCompanion? purchase;
    GroceryDetailsCompanion? grocery;
    DocumentDetailsCompanion? document;

    final parsedAmount = double.tryParse(_amountController.text.trim());

    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        bill = BillDetailsCompanion(
          itemId: drift.Value(itemId),
          providerName: drift.Value(_providerOrSellerController.text.trim().isEmpty ? _titleController.text.trim() : _providerOrSellerController.text.trim()),
          accountNumber: drift.Value(_docNumberController.text.trim().isEmpty ? null : _docNumberController.text.trim()),
          amount: drift.Value(parsedAmount),
          paymentStatus: const drift.Value('pending'),
        );
        break;
      case ItemSubcategory.warranty:
        warranty = WarrantyDetailsCompanion(
          itemId: drift.Value(itemId),
          productName: drift.Value(_titleController.text.trim()),
          seller: drift.Value(_providerOrSellerController.text.trim().isEmpty ? null : _providerOrSellerController.text.trim()),
          purchaseAmount: drift.Value(parsedAmount),
        );
        break;
      case ItemSubcategory.insurance:
        insurance = InsuranceDetailsCompanion(
          itemId: drift.Value(itemId),
          provider: drift.Value(_providerOrSellerController.text.trim().isEmpty ? 'Insurance Provider' : _providerOrSellerController.text.trim()),
          policyNumber: drift.Value(_docNumberController.text.trim().isEmpty ? null : _docNumberController.text.trim()),
          vehicleNumber: drift.Value(_vehicleNumberController.text.trim().isEmpty ? null : _vehicleNumberController.text.trim()),
          premiumAmount: drift.Value(parsedAmount),
        );
        break;
      case ItemSubcategory.subscription:
        subscription = SubscriptionDetailsCompanion(
          itemId: drift.Value(itemId),
          serviceName: drift.Value(_titleController.text.trim()),
          billingCycle: drift.Value(_billingCycle),
          amount: drift.Value(parsedAmount),
        );
        break;
      case ItemSubcategory.purchase:
        purchase = PurchaseDetailsCompanion(
          itemId: drift.Value(itemId),
          productName: drift.Value(_titleController.text.trim()),
          seller: drift.Value(_providerOrSellerController.text.trim().isEmpty ? null : _providerOrSellerController.text.trim()),
          purchaseAmount: drift.Value(parsedAmount),
        );
        break;
      case ItemSubcategory.grocery:
        grocery = GroceryDetailsCompanion(
          itemId: drift.Value(itemId),
          productName: drift.Value(_titleController.text.trim()),
          batchNumber: drift.Value(_docNumberController.text.trim().isEmpty ? null : _docNumberController.text.trim()),
          storageLocation: drift.Value(_selectedStorage.code),
          quantityRemaining: drift.Value(double.tryParse(_quantityController.text.trim()) ?? 1.0),
          quantityUnit: drift.Value(_quantityUnit),
        );
        break;
      case ItemSubcategory.document:
        document = DocumentDetailsCompanion(
          itemId: drift.Value(itemId),
          documentNumber: drift.Value(_docNumberController.text.trim().isEmpty ? null : _docNumberController.text.trim()),
          issuingAuthority: drift.Value(_providerOrSellerController.text.trim().isEmpty ? null : _providerOrSellerController.text.trim()),
          documentType: drift.Value(_selectedSubcategory.displayName),
        );
        break;
    }

    // Save attached files
    final docCompanions = <ItemDocumentsCompanion>[];
    for (final file in _attachedFiles) {
      try {
        final stored = await fileStorage.saveFile(sourceFile: file);
        docCompanions.add(ItemDocumentsCompanion.insert(
          id: uuid.v4(),
          itemId: drift.Value(itemId),
          fileName: stored.fileName,
          relativePath: stored.relativePath,
          mimeType: stored.fileName.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
          fileSize: stored.fileSize,
          checksumSha256: stored.checksum,
          source: 'user_attachment',
          createdAt: nowIso,
        ));
      } catch (_) {}
    }

    if (widget.existingItem != null) {
      await cubit.updateItem(
        item: baseItem,
        bill: bill,
        warranty: warranty,
        insurance: insurance,
        subscription: subscription,
        purchase: purchase,
        grocery: grocery,
        document: document,
        newDocuments: docCompanions,
        reminderOffsets: _reminderOffsets,
      );
    } else {
      await cubit.addItem(
        item: baseItem,
        bill: bill,
        warranty: warranty,
        insurance: insurance,
        subscription: subscription,
        purchase: purchase,
        grocery: grocery,
        document: document,
        documents: docCompanions,
        reminderOffsets: _reminderOffsets,
      );
    }

    setState(() => _isSaving = false);
    if (mounted) {
      showToast(
        context,
        widget.existingItem != null ? 'Item updated successfully!' : 'Item saved successfully!',
        icon: Icons.check_circle_rounded,
        type: ToastType.success,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Scaffold(
      appBar: KeepMateAppBar(
        title: isEditing ? 'Edit Details' : 'Add New Item',
        subtitle: isEditing ? 'Update item details' : 'Enter details or attach document / photo',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. Choose Item Type (Subcategory Chips)
              if (!isEditing) ...[
                Text('What are you tracking?', style: AppText.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ItemSubcategory.values.map((sub) {
                    final isSel = _selectedSubcategory == sub;
                    return ChoiceChip(
                      label: Text(sub.displayName),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedSubcategory = sub;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // 2. Scan / Attach Document Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Have a photo or bill?', style: AppText.h3),
                          Text('Take a snap to auto-fill details!', style: AppText.bodySmall),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isExtractingText ? null : _pickAttachment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        minimumSize: Size.zero,
                      ),
                      child: _isExtractingText
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Add File'),
                    ),
                  ],
                ),
              ),

              if (_isExtractingText) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reading document and auto-filling form details...',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_attachedFiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _attachedFiles.map((f) {
                    return Chip(
                      avatar: const Icon(Icons.attachment_rounded, size: 16),
                      label: Text(f.uri.pathSegments.last, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        setState(() {
                          _attachedFiles.remove(f);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              // 3. Name / Title
              Text('Name / Title *', style: AppText.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: _selectedSubcategory == ItemSubcategory.bill
                      ? 'e.g. Electricity Bill, WiFi'
                      : _selectedSubcategory == ItemSubcategory.grocery
                          ? 'e.g. Fresh Milk, Tomatoes'
                          : _selectedSubcategory == ItemSubcategory.insurance
                              ? 'e.g. Car Insurance, Health Plan'
                              : 'e.g. Laptop Warranty, Driving Licence',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
              ),

              const SizedBox(height: 20),

              // 4. Expiry or Due Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedSubcategory == ItemSubcategory.bill ? 'Payment Due Date *' : 'Expiry Date *',
                    style: AppText.label,
                  ),
                  if (_selectedTargetDate != null)
                    Text(
                      AppDateUtils.getRelativeTimeLabel(_selectedTargetDate),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTargetDate != null
                            ? AppDateUtils.formatDisplay(_selectedTargetDate)
                            : 'Select date from calendar',
                        style: AppText.bodyLarge,
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                ),
              ),

              // Quick preset chips
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(label: const Text('Tomorrow'), onPressed: () => _applyQuickDatePreset(1)),
                    const SizedBox(width: 6),
                    ActionChip(label: const Text('In 3 Days'), onPressed: () => _applyQuickDatePreset(3)),
                    const SizedBox(width: 6),
                    ActionChip(label: const Text('In 1 Week'), onPressed: () => _applyQuickDatePreset(7)),
                    const SizedBox(width: 6),
                    ActionChip(label: const Text('In 1 Month'), onPressed: () => _applyQuickDatePreset(30)),
                    const SizedBox(width: 6),
                    ActionChip(label: const Text('In 1 Year'), onPressed: () => _applyQuickDatePreset(365)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. Category-Specific Extra Fields
              if (_selectedSubcategory == ItemSubcategory.bill ||
                  _selectedSubcategory == ItemSubcategory.insurance ||
                  _selectedSubcategory == ItemSubcategory.subscription) ...[
                Text('Amount (₹)', style: AppText.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'e.g. 1500'),
                ),
                const SizedBox(height: 16),
              ],

              if (_selectedSubcategory == ItemSubcategory.insurance) ...[
                Text('Vehicle Registration Number', style: AppText.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _vehicleNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'e.g. KA01AB1234'),
                ),
                const SizedBox(height: 16),
              ],

              if (_selectedSubcategory == ItemSubcategory.grocery) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity', style: AppText.label),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '1'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Storage Location', style: AppText.label),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<StorageLocation>(
                            initialValue: _selectedStorage,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                            items: StorageLocation.values.map((loc) {
                              return DropdownMenuItem(value: loc, child: Text(loc.label));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStorage = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 6. Reminder Preferences
              Text('Automatic Reminder Alerts', style: AppText.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [30, 7, 3, 1, 0].map((days) {
                  final isChecked = _reminderOffsets.contains(days);
                  final label = days == 0 ? 'On due date' : '$days days before';
                  return FilterChip(
                    label: Text(label),
                    selected: isChecked,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _reminderOffsets.add(days);
                        } else {
                          _reminderOffsets.remove(days);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // 7. Save Action
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safeGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(isEditing ? 'Save Changes' : 'Save & Remember', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
