import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../core/notifications/reminder_scheduler.dart';
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
  final String? initialTitle;
  final StorageLocation? initialStorageLocation;

  const AddEditItemPage({
    super.key,
    this.existingItem,
    this.initialSubcategory,
    this.initialTitle,
    this.initialStorageLocation,
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
    _selectedSubcategory =
        item?.subcategory ?? widget.initialSubcategory ?? ItemSubcategory.bill;

    if (widget.initialStorageLocation != null) {
      _selectedStorage = widget.initialStorageLocation!;
    }

    _titleController =
        TextEditingController(text: item?.title ?? widget.initialTitle ?? '');
    _descriptionController =
        TextEditingController(text: item?.description ?? '');
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
      _selectedStorage =
          StorageLocation.fromCode(item!.groceryDetails!.storageLocation);
      _quantityUnit = item.groceryDetails!.quantityUnit;
    }

    if (item == null) {
      _reminderOffsets.clear();
      _reminderOffsets
          .addAll(ReminderScheduler.getDefaultOffsets(_selectedSubcategory));
    } else {
      _reminderOffsets.clear();
      _reminderOffsets.addAll(item.reminderRules.map((r) => r.offsetDays));
      if (_reminderOffsets.isEmpty) {
        _reminderOffsets
            .addAll(ReminderScheduler.getDefaultOffsets(_selectedSubcategory));
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLostData();
      LostDataService.instance.recoveredFileNotifier
          .addListener(_onRecoveredFileChanged);
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
        final compressed = await ImageCompressor.compress(file.path,
            purpose: ImagePurpose.document);
        await _processAttachedFile(File(compressed));
      }
    } catch (e) {
      debugPrint('retrieveLostData error: $e');
    }
  }

  @override
  void dispose() {
    LostDataService.instance.recoveredFileNotifier
        .removeListener(_onRecoveredFileChanged);
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

  Color get _categoryThemeColor {
    switch (_categoryForSubcategory) {
      case ItemCategory.lifePocket:
        return AppColors.lifePocketColor;
      case ItemCategory.freshCheck:
        return AppColors.freshCheckColor;
      case ItemCategory.docAlert:
        return AppColors.docAlertColor;
      case ItemCategory.medicineCare:
        return AppColors.medicineCareColor;
    }
  }

  IconData get _categoryIcon {
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        return Icons.receipt_long_rounded;
      case ItemSubcategory.warranty:
        return Icons.verified_user_rounded;
      case ItemSubcategory.insurance:
        return Icons.health_and_safety_rounded;
      case ItemSubcategory.subscription:
        return Icons.subscriptions_rounded;
      case ItemSubcategory.purchase:
        return Icons.shopping_bag_rounded;
      case ItemSubcategory.grocery:
        return Icons.apple_rounded;
      case ItemSubcategory.document:
        return Icons.badge_rounded;
    }
  }

  String get _appBarTitle {
    if (widget.existingItem != null) {
      return 'Edit ${_selectedSubcategory.displayName}';
    }
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        return 'Add Bill / Receipt';
      case ItemSubcategory.warranty:
        return 'Add Warranty';
      case ItemSubcategory.subscription:
        return 'Add Subscription';
      case ItemSubcategory.insurance:
        return 'Add Insurance Policy';
      case ItemSubcategory.purchase:
        return 'Add Purchase / Invoice';
      case ItemSubcategory.grocery:
        return 'Add Food / Grocery';
      case ItemSubcategory.document:
        return 'Add Official Document';
    }
  }

  String get _appBarSubtitle {
    if (widget.existingItem != null) {
      return 'Update details & reminders';
    }
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        return 'Scan bill or enter payment due date';
      case ItemSubcategory.warranty:
        return 'Scan receipt or enter warranty details';
      case ItemSubcategory.subscription:
        return 'Track recurring payments & renewal date';
      case ItemSubcategory.insurance:
        return 'Scan policy or enter coverage expiry';
      case ItemSubcategory.purchase:
        return 'Save purchase proof & return deadline';
      case ItemSubcategory.grocery:
        return 'Track food expiry & storage location';
      case ItemSubcategory.document:
        return 'Scan official ID or document validity';
    }
  }

  String get _scanBannerTitle {
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        return 'Have a bill or receipt?';
      case ItemSubcategory.warranty:
        return 'Have an invoice or warranty card?';
      case ItemSubcategory.subscription:
        return 'Have a subscription invoice?';
      case ItemSubcategory.insurance:
        return 'Have a policy document or card?';
      case ItemSubcategory.purchase:
        return 'Have a store receipt or invoice?';
      case ItemSubcategory.grocery:
        return 'Have a grocery label or receipt?';
      case ItemSubcategory.document:
        return 'Have your document or card?';
    }
  }

  String get _scanBannerSubtitle {
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        return 'Snap photo or upload PDF to auto-fill due date & amount';
      case ItemSubcategory.warranty:
        return 'Snap photo or upload invoice to auto-fill warranty dates';
      case ItemSubcategory.subscription:
        return 'Snap receipt to auto-fill service & renewal date';
      case ItemSubcategory.insurance:
        return 'Snap photo or upload PDF to auto-fill policy details';
      case ItemSubcategory.purchase:
        return 'Snap receipt to auto-fill store & purchase price';
      case ItemSubcategory.grocery:
        return 'Snap package label to read product & expiry date';
      case ItemSubcategory.document:
        return 'Snap DL, RC, or Passport to auto-fill ID numbers & dates';
    }
  }

  String get _titleFieldLabel {
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        return 'Bill Name *';
      case ItemSubcategory.warranty:
        return 'Product / Item Name *';
      case ItemSubcategory.subscription:
        return 'Service / Platform Name *';
      case ItemSubcategory.insurance:
        return 'Policy / Plan Name *';
      case ItemSubcategory.purchase:
        return 'Product / Store Name *';
      case ItemSubcategory.grocery:
        return 'Food / Item Name *';
      case ItemSubcategory.document:
        return 'Document Name *';
    }
  }

  String get _titleFieldHint {
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        return 'e.g. Electricity Bill, WiFi, Water';
      case ItemSubcategory.warranty:
        return 'e.g. MacBook Pro, Samsung TV, Refrigerator';
      case ItemSubcategory.subscription:
        return 'e.g. Netflix, Spotify, Gym Membership';
      case ItemSubcategory.insurance:
        return 'e.g. Car Insurance, Family Health Plan';
      case ItemSubcategory.purchase:
        return 'e.g. Nike Shoes, Wireless Earbuds';
      case ItemSubcategory.grocery:
        return 'e.g. Fresh Milk, Brown Bread, Tomatoes';
      case ItemSubcategory.document:
        return 'e.g. Driving Licence, Vehicle RC, Passport';
    }
  }

  String get _targetDateFieldLabel {
    switch (_selectedSubcategory) {
      case ItemSubcategory.bill:
        return 'Payment Due Date *';
      case ItemSubcategory.subscription:
        return 'Next Payment Date *';
      default:
        return 'Expiry Date *';
    }
  }

  List<Map<String, dynamic>> get _quickDatePresets {
    switch (_selectedSubcategory) {
      case ItemSubcategory.grocery:
        return [
          {'label': 'Tomorrow', 'days': 1},
          {'label': 'In 3 Days', 'days': 3},
          {'label': 'In 1 Week', 'days': 7},
          {'label': 'In 2 Weeks', 'days': 14},
          {'label': 'In 1 Month', 'days': 30},
        ];
      case ItemSubcategory.bill:
      case ItemSubcategory.subscription:
        return [
          {'label': 'Tomorrow', 'days': 1},
          {'label': 'In 3 Days', 'days': 3},
          {'label': 'In 1 Week', 'days': 7},
          {'label': 'In 15 Days', 'days': 15},
          {'label': 'In 1 Month', 'days': 30},
        ];
      case ItemSubcategory.warranty:
      case ItemSubcategory.insurance:
      case ItemSubcategory.document:
      case ItemSubcategory.purchase:
        return [
          {'label': 'In 6 Months', 'days': 180},
          {'label': 'In 1 Year', 'days': 365},
          {'label': 'In 2 Years', 'days': 730},
          {'label': 'In 3 Years', 'days': 1095},
          {'label': 'In 5 Years', 'days': 1825},
        ];
    }
  }

  List<int> get _availableReminderOffsets {
    switch (_selectedSubcategory) {
      case ItemSubcategory.grocery:
        return [7, 3, 2, 1, 0];
      case ItemSubcategory.bill:
      case ItemSubcategory.subscription:
        return [15, 7, 3, 1, 0];
      case ItemSubcategory.warranty:
      case ItemSubcategory.insurance:
      case ItemSubcategory.document:
      case ItemSubcategory.purchase:
        return [60, 30, 15, 7, 1];
    }
  }

  void _onSubcategoryChanged(ItemSubcategory sub) {
    setState(() {
      _selectedSubcategory = sub;
      if (widget.existingItem == null) {
        _reminderOffsets.clear();
        _reminderOffsets.addAll(ReminderScheduler.getDefaultOffsets(sub));
      }
    });
  }

  Future<void> _pickAttachment() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Attach Photo or Document', style: AppText.h3),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.primary),
                title: const Text('Take a Photo'),
                subtitle:
                    const Text('Capture document, bill, or item with camera'),
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
                        purpose: ImagePurpose.document);
                    await _processAttachedFile(File(compressed));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.secondary),
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
                    final compressed = await ImageCompressor.compress(
                        picked.path,
                        purpose: ImagePurpose.document);
                    await _processAttachedFile(File(compressed));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppColors.dangerRed),
                title: const Text('Upload PDF Document'),
                subtitle: const Text('Select PDF bill, receipt, or policy'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'PDF'],
                    withData: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    final pickedFile = result.files.single;
                    File? fileToProcess;
                    if (pickedFile.path != null &&
                        File(pickedFile.path!).existsSync()) {
                      fileToProcess = File(pickedFile.path!);
                    } else if (pickedFile.bytes != null) {
                      final tempDir = await getTemporaryDirectory();
                      final safeName = pickedFile.name
                          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
                      final tempFile = File('${tempDir.path}/$safeName');
                      await tempFile.writeAsBytes(pickedFile.bytes!);
                      fileToProcess = tempFile;
                    }
                    if (fileToProcess != null) {
                      await _processAttachedFile(fileToProcess);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isGenericTitle(String text) {
    final lower = text.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'bill' ||
        lower == 'item' ||
        lower == 'new item' ||
        lower == 'document' ||
        lower == 'receipt';
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
      debugPrint('AddEditItemPage: Extracted text length: ${rawText.length}');
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
      final parsed = parser.parse(
          text: rawText, expectedSubcategory: _selectedSubcategory);

      setState(() {
        if (parsed.title != null &&
            (_titleController.text.trim().isEmpty ||
                _isGenericTitle(_titleController.text))) {
          _titleController.text = parsed.title!;
        }
        if (parsed.providerOrSeller != null) {
          _providerOrSellerController.text = parsed.providerOrSeller!;
        }
        if (parsed.documentOrPolicyNumber != null) {
          _docNumberController.text = parsed.documentOrPolicyNumber!;
        }
        if (parsed.vehicleNumber != null) {
          _vehicleNumberController.text = parsed.vehicleNumber!;
          if (_docNumberController.text.trim().isEmpty) {
            _docNumberController.text = parsed.vehicleNumber!;
          }
        }
        if (parsed.amount != null) {
          _amountController.text =
              parsed.amount!.toStringAsFixed(parsed.amount! % 1 == 0 ? 0 : 2);
        }
        if (parsed.expiryDate != null) {
          _selectedTargetDate = parsed.expiryDate;
        }
        if (parsed.startDate != null) {
          _selectedStartDate = parsed.startDate;
        }
        if (parsed.detectedSubcategory != null) {
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
          duration: const Duration(seconds: 5),
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
      firstDate: DateTime(1990),
      lastDate: DateTime(2055),
    );
    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(2055),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
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
    final startDateStr = _selectedStartDate != null
        ? AppDateUtils.formatDateOnly(_selectedStartDate!)
        : null;

    final baseItem = TrackedItemsCompanion(
      id: drift.Value(itemId),
      category: drift.Value(_categoryForSubcategory.code),
      subcategory: drift.Value(_selectedSubcategory.code),
      title: drift.Value(_titleController.text.trim()),
      description: drift.Value(_descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim()),
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
          providerName: drift.Value(
              _providerOrSellerController.text.trim().isEmpty
                  ? _titleController.text.trim()
                  : _providerOrSellerController.text.trim()),
          accountNumber: drift.Value(_docNumberController.text.trim().isEmpty
              ? null
              : _docNumberController.text.trim()),
          amount: drift.Value(parsedAmount),
          paymentStatus: const drift.Value('pending'),
        );
        break;
      case ItemSubcategory.warranty:
        warranty = WarrantyDetailsCompanion(
          itemId: drift.Value(itemId),
          productName: drift.Value(_titleController.text.trim()),
          seller: drift.Value(_providerOrSellerController.text.trim().isEmpty
              ? null
              : _providerOrSellerController.text.trim()),
          purchaseAmount: drift.Value(parsedAmount),
        );
        break;
      case ItemSubcategory.insurance:
        insurance = InsuranceDetailsCompanion(
          itemId: drift.Value(itemId),
          provider: drift.Value(_providerOrSellerController.text.trim().isEmpty
              ? 'Insurance Provider'
              : _providerOrSellerController.text.trim()),
          policyNumber: drift.Value(_docNumberController.text.trim().isEmpty
              ? null
              : _docNumberController.text.trim()),
          vehicleNumber: drift.Value(
              _vehicleNumberController.text.trim().isEmpty
                  ? null
                  : _vehicleNumberController.text.trim()),
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
          seller: drift.Value(_providerOrSellerController.text.trim().isEmpty
              ? null
              : _providerOrSellerController.text.trim()),
          purchaseAmount: drift.Value(parsedAmount),
        );
        break;
      case ItemSubcategory.grocery:
        grocery = GroceryDetailsCompanion(
          itemId: drift.Value(itemId),
          productName: drift.Value(_titleController.text.trim()),
          batchNumber: drift.Value(_docNumberController.text.trim().isEmpty
              ? null
              : _docNumberController.text.trim()),
          storageLocation: drift.Value(_selectedStorage.code),
          quantityRemaining: drift.Value(
              double.tryParse(_quantityController.text.trim()) ?? 1.0),
          quantityUnit: drift.Value(_quantityUnit),
        );
        break;
      case ItemSubcategory.document:
        final docNum = _docNumberController.text.trim().isNotEmpty
            ? _docNumberController.text.trim()
            : (_vehicleNumberController.text.trim().isNotEmpty
                ? _vehicleNumberController.text.trim()
                : null);
        document = DocumentDetailsCompanion(
          itemId: drift.Value(itemId),
          documentNumber: drift.Value(docNum),
          issuingAuthority: drift.Value(
              _providerOrSellerController.text.trim().isEmpty
                  ? null
                  : _providerOrSellerController.text.trim()),
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
          mimeType: stored.fileName.toLowerCase().endsWith('.pdf')
              ? 'application/pdf'
              : 'image/jpeg',
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
        widget.existingItem != null
            ? 'Item updated successfully!'
            : 'Item saved successfully!',
        icon: Icons.check_circle_rounded,
        type: ToastType.success,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return AppScaffold(
      appBar: KeepRemindAppBar(
        title: _appBarTitle,
        subtitle: _appBarSubtitle,
        showBack: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. Focused Category & Selected Type Badge (No unrelated clutter!)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _categoryThemeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _categoryThemeColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _categoryThemeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_categoryIcon,
                          color: _categoryThemeColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _categoryForSubcategory.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _categoryThemeColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedSubcategory.displayName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isEditing)
                      PopupMenuButton<ItemSubcategory>(
                        tooltip: 'Change Type',
                        icon: Icon(Icons.swap_horiz_rounded,
                            color: _categoryThemeColor),
                        onSelected: _onSubcategoryChanged,
                        itemBuilder: (context) {
                          return ItemSubcategory.values.map((sub) {
                            return PopupMenuItem(
                              value: sub,
                              child: Row(
                                children: [
                                  if (sub == _selectedSubcategory)
                                    const Icon(Icons.check_rounded,
                                        size: 16, color: AppColors.primary)
                                  else
                                    const SizedBox(width: 16),
                                  const SizedBox(width: 8),
                                  Text(sub.displayName),
                                ],
                              ),
                            );
                          }).toList();
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Scan / Attach Document Banner (Tailored to selected type!)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _categoryThemeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _categoryThemeColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _categoryThemeColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.document_scanner_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_scanBannerTitle, style: AppText.h3),
                          const SizedBox(height: 2),
                          Text(_scanBannerSubtitle, style: AppText.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isExtractingText ? null : _pickAttachment,
                      icon: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: Colors.white),
                      label: _isExtractingText
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Scan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _categoryThemeColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ],
                ),
              ),

              if (_isExtractingText) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reading document and auto-filling form details...',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
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
                      label: Text(f.uri.pathSegments.last,
                          style: const TextStyle(fontSize: 12)),
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
              Text(_titleFieldLabel, style: AppText.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: _titleFieldHint,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter a name'
                    : null,
              ),

              const SizedBox(height: 20),

              // 4. Target Date (Due Date or Expiry Date)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_targetDateFieldLabel, style: AppText.label),
                  if (_selectedTargetDate != null)
                    Text(
                      AppDateUtils.getRelativeTimeLabel(_selectedTargetDate),
                      style: TextStyle(
                          color: _categoryThemeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: context.surfaceRaisedColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          color: _categoryThemeColor),
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

              // Quick preset chips tailored to this subcategory
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickDatePresets.map((preset) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(preset['label'] as String),
                        onPressed: () =>
                            _applyQuickDatePreset(preset['days'] as int),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // 5. Category-Specific Fields (Only relevant fields!)
              // Start / Purchase / Issue Date (NOT for grocery or subscription)
              if (_selectedSubcategory != ItemSubcategory.grocery &&
                  _selectedSubcategory != ItemSubcategory.subscription) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedSubcategory == ItemSubcategory.document
                          ? 'Issue / Registration Date'
                          : _selectedSubcategory == ItemSubcategory.warranty ||
                                  _selectedSubcategory ==
                                      ItemSubcategory.purchase
                              ? 'Purchase Date'
                              : 'Bill Date',
                      style: AppText.label,
                    ),
                    if (_selectedStartDate != null)
                      TextButton(
                        onPressed: () =>
                            setState(() => _selectedStartDate = null),
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero),
                        child: Text('Clear',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickStartDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.surfaceRaisedColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.cardBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded,
                            color: _categoryThemeColor, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedStartDate != null
                              ? AppDateUtils.formatDisplay(_selectedStartDate)
                              : 'Select date (optional)',
                          style: _selectedStartDate != null
                              ? AppText.bodyLarge
                              : AppText.bodySmall,
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Identifier / Document / Policy Number (NOT for grocery or subscription)
              if (_selectedSubcategory != ItemSubcategory.grocery &&
                  _selectedSubcategory != ItemSubcategory.subscription) ...[
                Text(
                  _selectedSubcategory == ItemSubcategory.document
                      ? 'Document / Registration Number'
                      : _selectedSubcategory == ItemSubcategory.insurance
                          ? 'Policy Number'
                          : _selectedSubcategory == ItemSubcategory.bill
                              ? 'Account / Service / Consumer Number'
                              : 'Invoice / Serial Number',
                  style: AppText.label,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _docNumberController,
                  decoration: InputDecoration(
                    hintText: _selectedSubcategory == ItemSubcategory.document
                        ? 'e.g. AP04TE1234, DL-12345678'
                        : _selectedSubcategory == ItemSubcategory.insurance
                            ? 'e.g. POL-987654321'
                            : _selectedSubcategory == ItemSubcategory.bill
                                ? 'e.g. Unique Service No, CA No'
                                : 'e.g. INV-100234',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Provider / Seller / Authority (NOT for grocery)
              if (_selectedSubcategory != ItemSubcategory.grocery) ...[
                Text(
                  _selectedSubcategory == ItemSubcategory.document
                      ? 'Issuing Authority / Issuer'
                      : _selectedSubcategory == ItemSubcategory.insurance
                          ? 'Insurance Provider / Company'
                          : _selectedSubcategory == ItemSubcategory.bill
                              ? 'Biller / Service Provider'
                              : _selectedSubcategory ==
                                      ItemSubcategory.subscription
                                  ? 'Platform / Company'
                                  : 'Seller / Store / Brand',
                  style: AppText.label,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _providerOrSellerController,
                  decoration: InputDecoration(
                    hintText: _selectedSubcategory == ItemSubcategory.document
                        ? 'e.g. Transport Department, UIDAI'
                        : _selectedSubcategory == ItemSubcategory.insurance
                            ? 'e.g. HDFC Ergo, Star Health'
                            : _selectedSubcategory == ItemSubcategory.bill
                                ? 'e.g. APCPDCL, BESCOM, Airtel'
                                : _selectedSubcategory ==
                                        ItemSubcategory.subscription
                                    ? 'e.g. Netflix, Spotify, Amazon'
                                    : 'e.g. Amazon, Croma, Apple',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Vehicle Registration Number (ONLY for Insurance & Vehicle Documents)
              if (_selectedSubcategory == ItemSubcategory.insurance ||
                  _selectedSubcategory == ItemSubcategory.document) ...[
                Text('Vehicle Registration Number', style: AppText.label),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _vehicleNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      hintText: 'e.g. AP04TE1234, KA01AB1234 (optional)'),
                  onChanged: (val) {
                    if (_selectedSubcategory == ItemSubcategory.document &&
                        _docNumberController.text.trim().isEmpty) {
                      _docNumberController.text = val;
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Amount (₹) (For Bills, Warranties, Subscriptions, Insurance, Purchases)
              if (_selectedSubcategory == ItemSubcategory.bill ||
                  _selectedSubcategory == ItemSubcategory.insurance ||
                  _selectedSubcategory == ItemSubcategory.subscription ||
                  _selectedSubcategory == ItemSubcategory.warranty ||
                  _selectedSubcategory == ItemSubcategory.purchase) ...[
                Text(
                  _selectedSubcategory == ItemSubcategory.insurance
                      ? 'Premium Amount (₹)'
                      : _selectedSubcategory == ItemSubcategory.bill
                          ? 'Bill Amount (₹)'
                          : _selectedSubcategory == ItemSubcategory.subscription
                              ? 'Recurring Amount (₹)'
                              : 'Amount / Price (₹)',
                  style: AppText.label,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(hintText: 'e.g. 1500 (optional)'),
                ),
                const SizedBox(height: 16),
              ],

              // Grocery-Specific: Quantity & Storage Location
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
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12)),
                            items: StorageLocation.values.map((loc) {
                              return DropdownMenuItem(
                                  value: loc, child: Text(loc.label));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStorage = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 6. Automatic Reminder Preferences
              Text('Automatic Reminder Alerts', style: AppText.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableReminderOffsets.map((days) {
                  final isChecked = _reminderOffsets.contains(days);
                  final label = days == 0
                      ? (_selectedSubcategory == ItemSubcategory.bill
                          ? 'On due date'
                          : 'On expiry day')
                      : '$days days before';
                  return FilterChip(
                    label: Text(label),
                    selected: isChecked,
                    selectedColor: _categoryThemeColor.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isChecked
                          ? _categoryThemeColor
                          : AppColors.textPrimary,
                      fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                    ),
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
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.check_circle_rounded,
                        color: Colors.white),
                label: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Save & Set Reminder',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safeGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
