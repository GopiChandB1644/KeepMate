import '../../../../core/database/app_database.dart';
import '../../../../core/enums/item_enums.dart';
import '../../../../core/utils/date_utils.dart';

class TrackedItemEntity {
  final TrackedItem baseItem;
  final BillDetail? billDetails;
  final WarrantyDetail? warrantyDetails;
  final InsuranceDetail? insuranceDetails;
  final SubscriptionDetail? subscriptionDetails;
  final PurchaseDetail? purchaseDetails;
  final GroceryDetail? groceryDetails;
  final DocumentDetail? documentDetails;
  final List<ItemDocument> documents;
  final List<ReminderRule> reminderRules;

  const TrackedItemEntity({
    required this.baseItem,
    this.billDetails,
    this.warrantyDetails,
    this.insuranceDetails,
    this.subscriptionDetails,
    this.purchaseDetails,
    this.groceryDetails,
    this.documentDetails,
    this.documents = const [],
    this.reminderRules = const [],
  });

  String get id => baseItem.id;
  String get title => baseItem.title;
  String? get description => baseItem.description;

  ItemCategory get category => ItemCategory.fromCode(baseItem.category);
  ItemSubcategory get subcategory => ItemSubcategory.fromCode(baseItem.subcategory);

  DateTime? get expiryDate => AppDateUtils.parseDateOnly(baseItem.expiryDate);
  DateTime? get dueDate => AppDateUtils.parseDateOnly(baseItem.dueDate);
  DateTime? get purchaseDate => AppDateUtils.parseDateOnly(baseItem.purchaseDate);
  DateTime? get issueDate => AppDateUtils.parseDateOnly(baseItem.issueDate);
  DateTime? get startDate => AppDateUtils.parseDateOnly(baseItem.startDate);

  /// Effective tracking date (either expiry or payment due date)
  DateTime? get targetDate => expiryDate ?? dueDate;

  /// Dynamic derived status (calculates if it's expired today, upcoming, safe, completed, etc.)
  ItemStatus get status {
    final rawStatus = ItemStatus.fromCode(baseItem.status);
    if (rawStatus == ItemStatus.completed ||
        rawStatus == ItemStatus.consumed ||
        rawStatus == ItemStatus.discarded ||
        rawStatus == ItemStatus.archived) {
      return rawStatus;
    }
    return AppDateUtils.deriveStatus(targetDate: targetDate);
  }

  int? get daysRemaining {
    final t = targetDate;
    if (t == null) return null;
    return AppDateUtils.daysDifferenceFromToday(t);
  }

  String get relativeTimeLabel => AppDateUtils.getRelativeTimeLabel(targetDate);

  TrackedItemEntity copyWith({
    TrackedItem? baseItem,
    BillDetail? billDetails,
    WarrantyDetail? warrantyDetails,
    InsuranceDetail? insuranceDetails,
    SubscriptionDetail? subscriptionDetails,
    PurchaseDetail? purchaseDetails,
    GroceryDetail? groceryDetails,
    DocumentDetail? documentDetails,
    List<ItemDocument>? documents,
    List<ReminderRule>? reminderRules,
  }) {
    return TrackedItemEntity(
      baseItem: baseItem ?? this.baseItem,
      billDetails: billDetails ?? this.billDetails,
      warrantyDetails: warrantyDetails ?? this.warrantyDetails,
      insuranceDetails: insuranceDetails ?? this.insuranceDetails,
      subscriptionDetails: subscriptionDetails ?? this.subscriptionDetails,
      purchaseDetails: purchaseDetails ?? this.purchaseDetails,
      groceryDetails: groceryDetails ?? this.groceryDetails,
      documentDetails: documentDetails ?? this.documentDetails,
      documents: documents ?? this.documents,
      reminderRules: reminderRules ?? this.reminderRules,
    );
  }
}
