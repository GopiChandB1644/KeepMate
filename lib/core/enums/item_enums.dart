enum ItemCategory {
  lifePocket('life_pocket', 'LifePocket', 'Bills, Warranties & Subscriptions'),
  freshCheck('fresh_check', 'FreshCheck', 'Groceries & Expiries'),
  docAlert('doc_alert', 'DocAlert', 'Personal & Vehicle Documents');

  final String code;
  final String displayName;
  final String subtitle;
  const ItemCategory(this.code, this.displayName, this.subtitle);

  static ItemCategory fromCode(String code) {
    return ItemCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ItemCategory.lifePocket,
    );
  }
}

enum ItemSubcategory {
  bill('bill', 'Bill', 'Electricity, Gas, WiFi'),
  warranty('warranty', 'Warranty', 'Gadgets & Home Appliances'),
  insurance('insurance', 'Insurance', 'Health, Life & Motor'),
  subscription('subscription', 'Subscription', 'Streaming & Software'),
  purchase('purchase', 'Purchase / Invoice', 'Receipts & Proof of Buy'),
  grocery('grocery', 'Grocery / Food', 'Milk, Bread, Veggies & Medicines'),
  document('document', 'Official Document', 'Licence, Passport, RC & PUC');

  final String code;
  final String displayName;
  final String description;
  const ItemSubcategory(this.code, this.displayName, this.description);

  static ItemSubcategory fromCode(String code) {
    return ItemSubcategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ItemSubcategory.bill,
    );
  }
}

enum ItemStatus {
  active('active', 'Safe / Active', 0xFF16A95A),
  upcoming('upcoming', 'Due Soon', 0xFFE08600),
  dueToday('due_today', 'Due Today!', 0xFFE5484D),
  expired('expired', 'Expired / Overdue', 0xFFE5484D),
  completed('completed', 'Paid / Completed', 0xFF2F86E8),
  consumed('consumed', 'Consumed', 0xFF6C7382),
  discarded('discarded', 'Discarded', 0xFF6C7382),
  archived('archived', 'Archived', 0xFF8A919F);

  final String code;
  final String label;
  final int colorValue;
  const ItemStatus(this.code, this.label, this.colorValue);

  static ItemStatus fromCode(String code) {
    return ItemStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ItemStatus.active,
    );
  }
}

enum StorageLocation {
  fridge('fridge', 'Fridge ❄️'),
  freezer('freezer', 'Freezer 🧊'),
  pantry('pantry', 'Pantry / Shelf 🥫'),
  medicineBox('medicine_box', 'Medicine Box 💊'),
  cabinet('cabinet', 'Kitchen Cabinet 🍽️'),
  other('other', 'Other Place 📦');

  final String code;
  final String label;
  const StorageLocation(this.code, this.label);

  static StorageLocation fromCode(String code) {
    return StorageLocation.values.firstWhere(
      (e) => e.code == code,
      orElse: () => StorageLocation.pantry,
    );
  }
}

