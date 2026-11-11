// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrackedItemsTable extends TrackedItems
    with TableInfo<$TrackedItemsTable, TrackedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subcategoryMeta =
      const VerificationMeta('subcategory');
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
      'subcategory', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<String> purchaseDate = GeneratedColumn<String>(
      'purchase_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _issueDateMeta =
      const VerificationMeta('issueDate');
  @override
  late final GeneratedColumn<String> issueDate = GeneratedColumn<String>(
      'issue_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiryDateMeta =
      const VerificationMeta('expiryDate');
  @override
  late final GeneratedColumn<String> expiryDate = GeneratedColumn<String>(
      'expiry_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _previousItemIdMeta =
      const VerificationMeta('previousItemId');
  @override
  late final GeneratedColumn<String> previousItemId = GeneratedColumn<String>(
      'previous_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        subcategory,
        title,
        description,
        purchaseDate,
        issueDate,
        startDate,
        dueDate,
        expiryDate,
        status,
        metadataJson,
        previousItemId,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_items';
  @override
  VerificationContext validateIntegrity(Insertable<TrackedItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
          _subcategoryMeta,
          subcategory.isAcceptableOrUnknown(
              data['subcategory']!, _subcategoryMeta));
    } else if (isInserting) {
      context.missing(_subcategoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    }
    if (data.containsKey('issue_date')) {
      context.handle(_issueDateMeta,
          issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
          _expiryDateMeta,
          expiryDate.isAcceptableOrUnknown(
              data['expiry_date']!, _expiryDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('previous_item_id')) {
      context.handle(
          _previousItemIdMeta,
          previousItemId.isAcceptableOrUnknown(
              data['previous_item_id']!, _previousItemIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subcategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subcategory'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      purchaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_date']),
      issueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issue_date']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date']),
      expiryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expiry_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      previousItemId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}previous_item_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TrackedItemsTable createAlias(String alias) {
    return $TrackedItemsTable(attachedDatabase, alias);
  }
}

class TrackedItem extends DataClass implements Insertable<TrackedItem> {
  final String id;
  final String category;
  final String subcategory;
  final String title;
  final String? description;
  final String? purchaseDate;
  final String? issueDate;
  final String? startDate;
  final String? dueDate;
  final String? expiryDate;
  final String status;
  final String metadataJson;
  final String? previousItemId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  const TrackedItem(
      {required this.id,
      required this.category,
      required this.subcategory,
      required this.title,
      this.description,
      this.purchaseDate,
      this.issueDate,
      this.startDate,
      this.dueDate,
      this.expiryDate,
      required this.status,
      required this.metadataJson,
      this.previousItemId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['subcategory'] = Variable<String>(subcategory);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<String>(purchaseDate);
    }
    if (!nullToAbsent || issueDate != null) {
      map['issue_date'] = Variable<String>(issueDate);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<String>(expiryDate);
    }
    map['status'] = Variable<String>(status);
    map['metadata_json'] = Variable<String>(metadataJson);
    if (!nullToAbsent || previousItemId != null) {
      map['previous_item_id'] = Variable<String>(previousItemId);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  TrackedItemsCompanion toCompanion(bool nullToAbsent) {
    return TrackedItemsCompanion(
      id: Value(id),
      category: Value(category),
      subcategory: Value(subcategory),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      issueDate: issueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(issueDate),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      status: Value(status),
      metadataJson: Value(metadataJson),
      previousItemId: previousItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousItemId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TrackedItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedItem(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String>(json['subcategory']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      purchaseDate: serializer.fromJson<String?>(json['purchaseDate']),
      issueDate: serializer.fromJson<String?>(json['issueDate']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      expiryDate: serializer.fromJson<String?>(json['expiryDate']),
      status: serializer.fromJson<String>(json['status']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      previousItemId: serializer.fromJson<String?>(json['previousItemId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String>(subcategory),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'purchaseDate': serializer.toJson<String?>(purchaseDate),
      'issueDate': serializer.toJson<String?>(issueDate),
      'startDate': serializer.toJson<String?>(startDate),
      'dueDate': serializer.toJson<String?>(dueDate),
      'expiryDate': serializer.toJson<String?>(expiryDate),
      'status': serializer.toJson<String>(status),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'previousItemId': serializer.toJson<String?>(previousItemId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  TrackedItem copyWith(
          {String? id,
          String? category,
          String? subcategory,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> purchaseDate = const Value.absent(),
          Value<String?> issueDate = const Value.absent(),
          Value<String?> startDate = const Value.absent(),
          Value<String?> dueDate = const Value.absent(),
          Value<String?> expiryDate = const Value.absent(),
          String? status,
          String? metadataJson,
          Value<String?> previousItemId = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          Value<String?> deletedAt = const Value.absent()}) =>
      TrackedItem(
        id: id ?? this.id,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        issueDate: issueDate.present ? issueDate.value : this.issueDate,
        startDate: startDate.present ? startDate.value : this.startDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
        status: status ?? this.status,
        metadataJson: metadataJson ?? this.metadataJson,
        previousItemId:
            previousItemId.present ? previousItemId.value : this.previousItemId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  TrackedItem copyWithCompanion(TrackedItemsCompanion data) {
    return TrackedItem(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      subcategory:
          data.subcategory.present ? data.subcategory.value : this.subcategory,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      expiryDate:
          data.expiryDate.present ? data.expiryDate.value : this.expiryDate,
      status: data.status.present ? data.status.value : this.status,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      previousItemId: data.previousItemId.present
          ? data.previousItemId.value
          : this.previousItemId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedItem(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('issueDate: $issueDate, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('status: $status, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('previousItemId: $previousItemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      category,
      subcategory,
      title,
      description,
      purchaseDate,
      issueDate,
      startDate,
      dueDate,
      expiryDate,
      status,
      metadataJson,
      previousItemId,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedItem &&
          other.id == this.id &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.title == this.title &&
          other.description == this.description &&
          other.purchaseDate == this.purchaseDate &&
          other.issueDate == this.issueDate &&
          other.startDate == this.startDate &&
          other.dueDate == this.dueDate &&
          other.expiryDate == this.expiryDate &&
          other.status == this.status &&
          other.metadataJson == this.metadataJson &&
          other.previousItemId == this.previousItemId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TrackedItemsCompanion extends UpdateCompanion<TrackedItem> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> subcategory;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> purchaseDate;
  final Value<String?> issueDate;
  final Value<String?> startDate;
  final Value<String?> dueDate;
  final Value<String?> expiryDate;
  final Value<String> status;
  final Value<String> metadataJson;
  final Value<String?> previousItemId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const TrackedItemsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.status = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.previousItemId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackedItemsCompanion.insert({
    required String id,
    required String category,
    required String subcategory,
    required String title,
    this.description = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    required String status,
    this.metadataJson = const Value.absent(),
    this.previousItemId = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        subcategory = Value(subcategory),
        title = Value(title),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TrackedItem> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? purchaseDate,
    Expression<String>? issueDate,
    Expression<String>? startDate,
    Expression<String>? dueDate,
    Expression<String>? expiryDate,
    Expression<String>? status,
    Expression<String>? metadataJson,
    Expression<String>? previousItemId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (issueDate != null) 'issue_date': issueDate,
      if (startDate != null) 'start_date': startDate,
      if (dueDate != null) 'due_date': dueDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (status != null) 'status': status,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (previousItemId != null) 'previous_item_id': previousItemId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackedItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? category,
      Value<String>? subcategory,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? purchaseDate,
      Value<String?>? issueDate,
      Value<String?>? startDate,
      Value<String?>? dueDate,
      Value<String?>? expiryDate,
      Value<String>? status,
      Value<String>? metadataJson,
      Value<String?>? previousItemId,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return TrackedItemsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      title: title ?? this.title,
      description: description ?? this.description,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      issueDate: issueDate ?? this.issueDate,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      metadataJson: metadataJson ?? this.metadataJson,
      previousItemId: previousItemId ?? this.previousItemId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<String>(purchaseDate.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<String>(issueDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<String>(expiryDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (previousItemId.present) {
      map['previous_item_id'] = Variable<String>(previousItemId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedItemsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('issueDate: $issueDate, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('status: $status, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('previousItemId: $previousItemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillDetailsTable extends BillDetails
    with TableInfo<$BillDetailsTable, BillDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerNameMeta =
      const VerificationMeta('providerName');
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
      'provider_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _billingPeriodMeta =
      const VerificationMeta('billingPeriod');
  @override
  late final GeneratedColumn<String> billingPeriod = GeneratedColumn<String>(
      'billing_period', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
      'payment_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        itemId,
        providerName,
        accountNumber,
        amount,
        currencyCode,
        billingPeriod,
        paymentStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_details';
  @override
  VerificationContext validateIntegrity(Insertable<BillDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('provider_name')) {
      context.handle(
          _providerNameMeta,
          providerName.isAcceptableOrUnknown(
              data['provider_name']!, _providerNameMeta));
    } else if (isInserting) {
      context.missing(_providerNameMeta);
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('billing_period')) {
      context.handle(
          _billingPeriodMeta,
          billingPeriod.isAcceptableOrUnknown(
              data['billing_period']!, _billingPeriodMeta));
    }
    if (data.containsKey('payment_status')) {
      context.handle(
          _paymentStatusMeta,
          paymentStatus.isAcceptableOrUnknown(
              data['payment_status']!, _paymentStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  BillDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillDetail(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      providerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_name'])!,
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount']),
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      billingPeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}billing_period']),
      paymentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_status'])!,
    );
  }

  @override
  $BillDetailsTable createAlias(String alias) {
    return $BillDetailsTable(attachedDatabase, alias);
  }
}

class BillDetail extends DataClass implements Insertable<BillDetail> {
  final String itemId;
  final String providerName;
  final String? accountNumber;
  final double? amount;
  final String currencyCode;
  final String? billingPeriod;
  final String paymentStatus;
  const BillDetail(
      {required this.itemId,
      required this.providerName,
      this.accountNumber,
      this.amount,
      required this.currencyCode,
      this.billingPeriod,
      required this.paymentStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['provider_name'] = Variable<String>(providerName);
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || billingPeriod != null) {
      map['billing_period'] = Variable<String>(billingPeriod);
    }
    map['payment_status'] = Variable<String>(paymentStatus);
    return map;
  }

  BillDetailsCompanion toCompanion(bool nullToAbsent) {
    return BillDetailsCompanion(
      itemId: Value(itemId),
      providerName: Value(providerName),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      currencyCode: Value(currencyCode),
      billingPeriod: billingPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(billingPeriod),
      paymentStatus: Value(paymentStatus),
    );
  }

  factory BillDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillDetail(
      itemId: serializer.fromJson<String>(json['itemId']),
      providerName: serializer.fromJson<String>(json['providerName']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      amount: serializer.fromJson<double?>(json['amount']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      billingPeriod: serializer.fromJson<String?>(json['billingPeriod']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'providerName': serializer.toJson<String>(providerName),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'amount': serializer.toJson<double?>(amount),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'billingPeriod': serializer.toJson<String?>(billingPeriod),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
    };
  }

  BillDetail copyWith(
          {String? itemId,
          String? providerName,
          Value<String?> accountNumber = const Value.absent(),
          Value<double?> amount = const Value.absent(),
          String? currencyCode,
          Value<String?> billingPeriod = const Value.absent(),
          String? paymentStatus}) =>
      BillDetail(
        itemId: itemId ?? this.itemId,
        providerName: providerName ?? this.providerName,
        accountNumber:
            accountNumber.present ? accountNumber.value : this.accountNumber,
        amount: amount.present ? amount.value : this.amount,
        currencyCode: currencyCode ?? this.currencyCode,
        billingPeriod:
            billingPeriod.present ? billingPeriod.value : this.billingPeriod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );
  BillDetail copyWithCompanion(BillDetailsCompanion data) {
    return BillDetail(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      amount: data.amount.present ? data.amount.value : this.amount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      billingPeriod: data.billingPeriod.present
          ? data.billingPeriod.value
          : this.billingPeriod,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillDetail(')
          ..write('itemId: $itemId, ')
          ..write('providerName: $providerName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('billingPeriod: $billingPeriod, ')
          ..write('paymentStatus: $paymentStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, providerName, accountNumber, amount,
      currencyCode, billingPeriod, paymentStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillDetail &&
          other.itemId == this.itemId &&
          other.providerName == this.providerName &&
          other.accountNumber == this.accountNumber &&
          other.amount == this.amount &&
          other.currencyCode == this.currencyCode &&
          other.billingPeriod == this.billingPeriod &&
          other.paymentStatus == this.paymentStatus);
}

class BillDetailsCompanion extends UpdateCompanion<BillDetail> {
  final Value<String> itemId;
  final Value<String> providerName;
  final Value<String?> accountNumber;
  final Value<double?> amount;
  final Value<String> currencyCode;
  final Value<String?> billingPeriod;
  final Value<String> paymentStatus;
  final Value<int> rowid;
  const BillDetailsCompanion({
    this.itemId = const Value.absent(),
    this.providerName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.billingPeriod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillDetailsCompanion.insert({
    required String itemId,
    required String providerName,
    this.accountNumber = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.billingPeriod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        providerName = Value(providerName);
  static Insertable<BillDetail> custom({
    Expression<String>? itemId,
    Expression<String>? providerName,
    Expression<String>? accountNumber,
    Expression<double>? amount,
    Expression<String>? currencyCode,
    Expression<String>? billingPeriod,
    Expression<String>? paymentStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (providerName != null) 'provider_name': providerName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (amount != null) 'amount': amount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (billingPeriod != null) 'billing_period': billingPeriod,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillDetailsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? providerName,
      Value<String?>? accountNumber,
      Value<double?>? amount,
      Value<String>? currencyCode,
      Value<String?>? billingPeriod,
      Value<String>? paymentStatus,
      Value<int>? rowid}) {
    return BillDetailsCompanion(
      itemId: itemId ?? this.itemId,
      providerName: providerName ?? this.providerName,
      accountNumber: accountNumber ?? this.accountNumber,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (billingPeriod.present) {
      map['billing_period'] = Variable<String>(billingPeriod.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillDetailsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('providerName: $providerName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('billingPeriod: $billingPeriod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WarrantyDetailsTable extends WarrantyDetails
    with TableInfo<$WarrantyDetailsTable, WarrantyDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarrantyDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellerMeta = const VerificationMeta('seller');
  @override
  late final GeneratedColumn<String> seller = GeneratedColumn<String>(
      'seller', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseAmountMeta =
      const VerificationMeta('purchaseAmount');
  @override
  late final GeneratedColumn<double> purchaseAmount = GeneratedColumn<double>(
      'purchase_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _warrantyDurationMonthsMeta =
      const VerificationMeta('warrantyDurationMonths');
  @override
  late final GeneratedColumn<int> warrantyDurationMonths = GeneratedColumn<int>(
      'warranty_duration_months', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _warrantyProviderMeta =
      const VerificationMeta('warrantyProvider');
  @override
  late final GeneratedColumn<String> warrantyProvider = GeneratedColumn<String>(
      'warranty_provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        itemId,
        productName,
        seller,
        purchaseAmount,
        warrantyDurationMonths,
        warrantyProvider
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warranty_details';
  @override
  VerificationContext validateIntegrity(Insertable<WarrantyDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('seller')) {
      context.handle(_sellerMeta,
          seller.isAcceptableOrUnknown(data['seller']!, _sellerMeta));
    }
    if (data.containsKey('purchase_amount')) {
      context.handle(
          _purchaseAmountMeta,
          purchaseAmount.isAcceptableOrUnknown(
              data['purchase_amount']!, _purchaseAmountMeta));
    }
    if (data.containsKey('warranty_duration_months')) {
      context.handle(
          _warrantyDurationMonthsMeta,
          warrantyDurationMonths.isAcceptableOrUnknown(
              data['warranty_duration_months']!, _warrantyDurationMonthsMeta));
    }
    if (data.containsKey('warranty_provider')) {
      context.handle(
          _warrantyProviderMeta,
          warrantyProvider.isAcceptableOrUnknown(
              data['warranty_provider']!, _warrantyProviderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  WarrantyDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WarrantyDetail(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      seller: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller']),
      purchaseAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_amount']),
      warrantyDurationMonths: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}warranty_duration_months']),
      warrantyProvider: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}warranty_provider']),
    );
  }

  @override
  $WarrantyDetailsTable createAlias(String alias) {
    return $WarrantyDetailsTable(attachedDatabase, alias);
  }
}

class WarrantyDetail extends DataClass implements Insertable<WarrantyDetail> {
  final String itemId;
  final String productName;
  final String? seller;
  final double? purchaseAmount;
  final int? warrantyDurationMonths;
  final String? warrantyProvider;
  const WarrantyDetail(
      {required this.itemId,
      required this.productName,
      this.seller,
      this.purchaseAmount,
      this.warrantyDurationMonths,
      this.warrantyProvider});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || seller != null) {
      map['seller'] = Variable<String>(seller);
    }
    if (!nullToAbsent || purchaseAmount != null) {
      map['purchase_amount'] = Variable<double>(purchaseAmount);
    }
    if (!nullToAbsent || warrantyDurationMonths != null) {
      map['warranty_duration_months'] = Variable<int>(warrantyDurationMonths);
    }
    if (!nullToAbsent || warrantyProvider != null) {
      map['warranty_provider'] = Variable<String>(warrantyProvider);
    }
    return map;
  }

  WarrantyDetailsCompanion toCompanion(bool nullToAbsent) {
    return WarrantyDetailsCompanion(
      itemId: Value(itemId),
      productName: Value(productName),
      seller:
          seller == null && nullToAbsent ? const Value.absent() : Value(seller),
      purchaseAmount: purchaseAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseAmount),
      warrantyDurationMonths: warrantyDurationMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyDurationMonths),
      warrantyProvider: warrantyProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyProvider),
    );
  }

  factory WarrantyDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WarrantyDetail(
      itemId: serializer.fromJson<String>(json['itemId']),
      productName: serializer.fromJson<String>(json['productName']),
      seller: serializer.fromJson<String?>(json['seller']),
      purchaseAmount: serializer.fromJson<double?>(json['purchaseAmount']),
      warrantyDurationMonths:
          serializer.fromJson<int?>(json['warrantyDurationMonths']),
      warrantyProvider: serializer.fromJson<String?>(json['warrantyProvider']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'productName': serializer.toJson<String>(productName),
      'seller': serializer.toJson<String?>(seller),
      'purchaseAmount': serializer.toJson<double?>(purchaseAmount),
      'warrantyDurationMonths': serializer.toJson<int?>(warrantyDurationMonths),
      'warrantyProvider': serializer.toJson<String?>(warrantyProvider),
    };
  }

  WarrantyDetail copyWith(
          {String? itemId,
          String? productName,
          Value<String?> seller = const Value.absent(),
          Value<double?> purchaseAmount = const Value.absent(),
          Value<int?> warrantyDurationMonths = const Value.absent(),
          Value<String?> warrantyProvider = const Value.absent()}) =>
      WarrantyDetail(
        itemId: itemId ?? this.itemId,
        productName: productName ?? this.productName,
        seller: seller.present ? seller.value : this.seller,
        purchaseAmount:
            purchaseAmount.present ? purchaseAmount.value : this.purchaseAmount,
        warrantyDurationMonths: warrantyDurationMonths.present
            ? warrantyDurationMonths.value
            : this.warrantyDurationMonths,
        warrantyProvider: warrantyProvider.present
            ? warrantyProvider.value
            : this.warrantyProvider,
      );
  WarrantyDetail copyWithCompanion(WarrantyDetailsCompanion data) {
    return WarrantyDetail(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      seller: data.seller.present ? data.seller.value : this.seller,
      purchaseAmount: data.purchaseAmount.present
          ? data.purchaseAmount.value
          : this.purchaseAmount,
      warrantyDurationMonths: data.warrantyDurationMonths.present
          ? data.warrantyDurationMonths.value
          : this.warrantyDurationMonths,
      warrantyProvider: data.warrantyProvider.present
          ? data.warrantyProvider.value
          : this.warrantyProvider,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WarrantyDetail(')
          ..write('itemId: $itemId, ')
          ..write('productName: $productName, ')
          ..write('seller: $seller, ')
          ..write('purchaseAmount: $purchaseAmount, ')
          ..write('warrantyDurationMonths: $warrantyDurationMonths, ')
          ..write('warrantyProvider: $warrantyProvider')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, productName, seller, purchaseAmount,
      warrantyDurationMonths, warrantyProvider);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WarrantyDetail &&
          other.itemId == this.itemId &&
          other.productName == this.productName &&
          other.seller == this.seller &&
          other.purchaseAmount == this.purchaseAmount &&
          other.warrantyDurationMonths == this.warrantyDurationMonths &&
          other.warrantyProvider == this.warrantyProvider);
}

class WarrantyDetailsCompanion extends UpdateCompanion<WarrantyDetail> {
  final Value<String> itemId;
  final Value<String> productName;
  final Value<String?> seller;
  final Value<double?> purchaseAmount;
  final Value<int?> warrantyDurationMonths;
  final Value<String?> warrantyProvider;
  final Value<int> rowid;
  const WarrantyDetailsCompanion({
    this.itemId = const Value.absent(),
    this.productName = const Value.absent(),
    this.seller = const Value.absent(),
    this.purchaseAmount = const Value.absent(),
    this.warrantyDurationMonths = const Value.absent(),
    this.warrantyProvider = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarrantyDetailsCompanion.insert({
    required String itemId,
    required String productName,
    this.seller = const Value.absent(),
    this.purchaseAmount = const Value.absent(),
    this.warrantyDurationMonths = const Value.absent(),
    this.warrantyProvider = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        productName = Value(productName);
  static Insertable<WarrantyDetail> custom({
    Expression<String>? itemId,
    Expression<String>? productName,
    Expression<String>? seller,
    Expression<double>? purchaseAmount,
    Expression<int>? warrantyDurationMonths,
    Expression<String>? warrantyProvider,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (productName != null) 'product_name': productName,
      if (seller != null) 'seller': seller,
      if (purchaseAmount != null) 'purchase_amount': purchaseAmount,
      if (warrantyDurationMonths != null)
        'warranty_duration_months': warrantyDurationMonths,
      if (warrantyProvider != null) 'warranty_provider': warrantyProvider,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarrantyDetailsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? productName,
      Value<String?>? seller,
      Value<double?>? purchaseAmount,
      Value<int?>? warrantyDurationMonths,
      Value<String?>? warrantyProvider,
      Value<int>? rowid}) {
    return WarrantyDetailsCompanion(
      itemId: itemId ?? this.itemId,
      productName: productName ?? this.productName,
      seller: seller ?? this.seller,
      purchaseAmount: purchaseAmount ?? this.purchaseAmount,
      warrantyDurationMonths:
          warrantyDurationMonths ?? this.warrantyDurationMonths,
      warrantyProvider: warrantyProvider ?? this.warrantyProvider,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (seller.present) {
      map['seller'] = Variable<String>(seller.value);
    }
    if (purchaseAmount.present) {
      map['purchase_amount'] = Variable<double>(purchaseAmount.value);
    }
    if (warrantyDurationMonths.present) {
      map['warranty_duration_months'] =
          Variable<int>(warrantyDurationMonths.value);
    }
    if (warrantyProvider.present) {
      map['warranty_provider'] = Variable<String>(warrantyProvider.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarrantyDetailsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('productName: $productName, ')
          ..write('seller: $seller, ')
          ..write('purchaseAmount: $purchaseAmount, ')
          ..write('warrantyDurationMonths: $warrantyDurationMonths, ')
          ..write('warrantyProvider: $warrantyProvider, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InsuranceDetailsTable extends InsuranceDetails
    with TableInfo<$InsuranceDetailsTable, InsuranceDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsuranceDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _policyNumberMeta =
      const VerificationMeta('policyNumber');
  @override
  late final GeneratedColumn<String> policyNumber = GeneratedColumn<String>(
      'policy_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vehicleNumberMeta =
      const VerificationMeta('vehicleNumber');
  @override
  late final GeneratedColumn<String> vehicleNumber = GeneratedColumn<String>(
      'vehicle_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverageTypeMeta =
      const VerificationMeta('coverageType');
  @override
  late final GeneratedColumn<String> coverageType = GeneratedColumn<String>(
      'coverage_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _premiumAmountMeta =
      const VerificationMeta('premiumAmount');
  @override
  late final GeneratedColumn<double> premiumAmount = GeneratedColumn<double>(
      'premium_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        itemId,
        provider,
        policyNumber,
        vehicleNumber,
        coverageType,
        premiumAmount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insurance_details';
  @override
  VerificationContext validateIntegrity(Insertable<InsuranceDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('policy_number')) {
      context.handle(
          _policyNumberMeta,
          policyNumber.isAcceptableOrUnknown(
              data['policy_number']!, _policyNumberMeta));
    }
    if (data.containsKey('vehicle_number')) {
      context.handle(
          _vehicleNumberMeta,
          vehicleNumber.isAcceptableOrUnknown(
              data['vehicle_number']!, _vehicleNumberMeta));
    }
    if (data.containsKey('coverage_type')) {
      context.handle(
          _coverageTypeMeta,
          coverageType.isAcceptableOrUnknown(
              data['coverage_type']!, _coverageTypeMeta));
    }
    if (data.containsKey('premium_amount')) {
      context.handle(
          _premiumAmountMeta,
          premiumAmount.isAcceptableOrUnknown(
              data['premium_amount']!, _premiumAmountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  InsuranceDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsuranceDetail(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      policyNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}policy_number']),
      vehicleNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_number']),
      coverageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coverage_type']),
      premiumAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}premium_amount']),
    );
  }

  @override
  $InsuranceDetailsTable createAlias(String alias) {
    return $InsuranceDetailsTable(attachedDatabase, alias);
  }
}

class InsuranceDetail extends DataClass implements Insertable<InsuranceDetail> {
  final String itemId;
  final String provider;
  final String? policyNumber;
  final String? vehicleNumber;
  final String? coverageType;
  final double? premiumAmount;
  const InsuranceDetail(
      {required this.itemId,
      required this.provider,
      this.policyNumber,
      this.vehicleNumber,
      this.coverageType,
      this.premiumAmount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || policyNumber != null) {
      map['policy_number'] = Variable<String>(policyNumber);
    }
    if (!nullToAbsent || vehicleNumber != null) {
      map['vehicle_number'] = Variable<String>(vehicleNumber);
    }
    if (!nullToAbsent || coverageType != null) {
      map['coverage_type'] = Variable<String>(coverageType);
    }
    if (!nullToAbsent || premiumAmount != null) {
      map['premium_amount'] = Variable<double>(premiumAmount);
    }
    return map;
  }

  InsuranceDetailsCompanion toCompanion(bool nullToAbsent) {
    return InsuranceDetailsCompanion(
      itemId: Value(itemId),
      provider: Value(provider),
      policyNumber: policyNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(policyNumber),
      vehicleNumber: vehicleNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleNumber),
      coverageType: coverageType == null && nullToAbsent
          ? const Value.absent()
          : Value(coverageType),
      premiumAmount: premiumAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(premiumAmount),
    );
  }

  factory InsuranceDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsuranceDetail(
      itemId: serializer.fromJson<String>(json['itemId']),
      provider: serializer.fromJson<String>(json['provider']),
      policyNumber: serializer.fromJson<String?>(json['policyNumber']),
      vehicleNumber: serializer.fromJson<String?>(json['vehicleNumber']),
      coverageType: serializer.fromJson<String?>(json['coverageType']),
      premiumAmount: serializer.fromJson<double?>(json['premiumAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'provider': serializer.toJson<String>(provider),
      'policyNumber': serializer.toJson<String?>(policyNumber),
      'vehicleNumber': serializer.toJson<String?>(vehicleNumber),
      'coverageType': serializer.toJson<String?>(coverageType),
      'premiumAmount': serializer.toJson<double?>(premiumAmount),
    };
  }

  InsuranceDetail copyWith(
          {String? itemId,
          String? provider,
          Value<String?> policyNumber = const Value.absent(),
          Value<String?> vehicleNumber = const Value.absent(),
          Value<String?> coverageType = const Value.absent(),
          Value<double?> premiumAmount = const Value.absent()}) =>
      InsuranceDetail(
        itemId: itemId ?? this.itemId,
        provider: provider ?? this.provider,
        policyNumber:
            policyNumber.present ? policyNumber.value : this.policyNumber,
        vehicleNumber:
            vehicleNumber.present ? vehicleNumber.value : this.vehicleNumber,
        coverageType:
            coverageType.present ? coverageType.value : this.coverageType,
        premiumAmount:
            premiumAmount.present ? premiumAmount.value : this.premiumAmount,
      );
  InsuranceDetail copyWithCompanion(InsuranceDetailsCompanion data) {
    return InsuranceDetail(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      provider: data.provider.present ? data.provider.value : this.provider,
      policyNumber: data.policyNumber.present
          ? data.policyNumber.value
          : this.policyNumber,
      vehicleNumber: data.vehicleNumber.present
          ? data.vehicleNumber.value
          : this.vehicleNumber,
      coverageType: data.coverageType.present
          ? data.coverageType.value
          : this.coverageType,
      premiumAmount: data.premiumAmount.present
          ? data.premiumAmount.value
          : this.premiumAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsuranceDetail(')
          ..write('itemId: $itemId, ')
          ..write('provider: $provider, ')
          ..write('policyNumber: $policyNumber, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('coverageType: $coverageType, ')
          ..write('premiumAmount: $premiumAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, provider, policyNumber, vehicleNumber,
      coverageType, premiumAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsuranceDetail &&
          other.itemId == this.itemId &&
          other.provider == this.provider &&
          other.policyNumber == this.policyNumber &&
          other.vehicleNumber == this.vehicleNumber &&
          other.coverageType == this.coverageType &&
          other.premiumAmount == this.premiumAmount);
}

class InsuranceDetailsCompanion extends UpdateCompanion<InsuranceDetail> {
  final Value<String> itemId;
  final Value<String> provider;
  final Value<String?> policyNumber;
  final Value<String?> vehicleNumber;
  final Value<String?> coverageType;
  final Value<double?> premiumAmount;
  final Value<int> rowid;
  const InsuranceDetailsCompanion({
    this.itemId = const Value.absent(),
    this.provider = const Value.absent(),
    this.policyNumber = const Value.absent(),
    this.vehicleNumber = const Value.absent(),
    this.coverageType = const Value.absent(),
    this.premiumAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsuranceDetailsCompanion.insert({
    required String itemId,
    required String provider,
    this.policyNumber = const Value.absent(),
    this.vehicleNumber = const Value.absent(),
    this.coverageType = const Value.absent(),
    this.premiumAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        provider = Value(provider);
  static Insertable<InsuranceDetail> custom({
    Expression<String>? itemId,
    Expression<String>? provider,
    Expression<String>? policyNumber,
    Expression<String>? vehicleNumber,
    Expression<String>? coverageType,
    Expression<double>? premiumAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (provider != null) 'provider': provider,
      if (policyNumber != null) 'policy_number': policyNumber,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (coverageType != null) 'coverage_type': coverageType,
      if (premiumAmount != null) 'premium_amount': premiumAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsuranceDetailsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? provider,
      Value<String?>? policyNumber,
      Value<String?>? vehicleNumber,
      Value<String?>? coverageType,
      Value<double?>? premiumAmount,
      Value<int>? rowid}) {
    return InsuranceDetailsCompanion(
      itemId: itemId ?? this.itemId,
      provider: provider ?? this.provider,
      policyNumber: policyNumber ?? this.policyNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      coverageType: coverageType ?? this.coverageType,
      premiumAmount: premiumAmount ?? this.premiumAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (policyNumber.present) {
      map['policy_number'] = Variable<String>(policyNumber.value);
    }
    if (vehicleNumber.present) {
      map['vehicle_number'] = Variable<String>(vehicleNumber.value);
    }
    if (coverageType.present) {
      map['coverage_type'] = Variable<String>(coverageType.value);
    }
    if (premiumAmount.present) {
      map['premium_amount'] = Variable<double>(premiumAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsuranceDetailsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('provider: $provider, ')
          ..write('policyNumber: $policyNumber, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('coverageType: $coverageType, ')
          ..write('premiumAmount: $premiumAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionDetailsTable extends SubscriptionDetails
    with TableInfo<$SubscriptionDetailsTable, SubscriptionDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceNameMeta =
      const VerificationMeta('serviceName');
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
      'service_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _billingCycleMeta =
      const VerificationMeta('billingCycle');
  @override
  late final GeneratedColumn<String> billingCycle = GeneratedColumn<String>(
      'billing_cycle', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _autoRenewMeta =
      const VerificationMeta('autoRenew');
  @override
  late final GeneratedColumn<bool> autoRenew = GeneratedColumn<bool>(
      'auto_renew', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("auto_renew" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [itemId, serviceName, billingCycle, amount, autoRenew];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_details';
  @override
  VerificationContext validateIntegrity(Insertable<SubscriptionDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
          _serviceNameMeta,
          serviceName.isAcceptableOrUnknown(
              data['service_name']!, _serviceNameMeta));
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('billing_cycle')) {
      context.handle(
          _billingCycleMeta,
          billingCycle.isAcceptableOrUnknown(
              data['billing_cycle']!, _billingCycleMeta));
    } else if (isInserting) {
      context.missing(_billingCycleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('auto_renew')) {
      context.handle(_autoRenewMeta,
          autoRenew.isAcceptableOrUnknown(data['auto_renew']!, _autoRenewMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  SubscriptionDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionDetail(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      serviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_name'])!,
      billingCycle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}billing_cycle'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount']),
      autoRenew: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_renew'])!,
    );
  }

  @override
  $SubscriptionDetailsTable createAlias(String alias) {
    return $SubscriptionDetailsTable(attachedDatabase, alias);
  }
}

class SubscriptionDetail extends DataClass
    implements Insertable<SubscriptionDetail> {
  final String itemId;
  final String serviceName;
  final String billingCycle;
  final double? amount;
  final bool autoRenew;
  const SubscriptionDetail(
      {required this.itemId,
      required this.serviceName,
      required this.billingCycle,
      this.amount,
      required this.autoRenew});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['service_name'] = Variable<String>(serviceName);
    map['billing_cycle'] = Variable<String>(billingCycle);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    map['auto_renew'] = Variable<bool>(autoRenew);
    return map;
  }

  SubscriptionDetailsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionDetailsCompanion(
      itemId: Value(itemId),
      serviceName: Value(serviceName),
      billingCycle: Value(billingCycle),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      autoRenew: Value(autoRenew),
    );
  }

  factory SubscriptionDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionDetail(
      itemId: serializer.fromJson<String>(json['itemId']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
      billingCycle: serializer.fromJson<String>(json['billingCycle']),
      amount: serializer.fromJson<double?>(json['amount']),
      autoRenew: serializer.fromJson<bool>(json['autoRenew']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'serviceName': serializer.toJson<String>(serviceName),
      'billingCycle': serializer.toJson<String>(billingCycle),
      'amount': serializer.toJson<double?>(amount),
      'autoRenew': serializer.toJson<bool>(autoRenew),
    };
  }

  SubscriptionDetail copyWith(
          {String? itemId,
          String? serviceName,
          String? billingCycle,
          Value<double?> amount = const Value.absent(),
          bool? autoRenew}) =>
      SubscriptionDetail(
        itemId: itemId ?? this.itemId,
        serviceName: serviceName ?? this.serviceName,
        billingCycle: billingCycle ?? this.billingCycle,
        amount: amount.present ? amount.value : this.amount,
        autoRenew: autoRenew ?? this.autoRenew,
      );
  SubscriptionDetail copyWithCompanion(SubscriptionDetailsCompanion data) {
    return SubscriptionDetail(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      serviceName:
          data.serviceName.present ? data.serviceName.value : this.serviceName,
      billingCycle: data.billingCycle.present
          ? data.billingCycle.value
          : this.billingCycle,
      amount: data.amount.present ? data.amount.value : this.amount,
      autoRenew: data.autoRenew.present ? data.autoRenew.value : this.autoRenew,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionDetail(')
          ..write('itemId: $itemId, ')
          ..write('serviceName: $serviceName, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('amount: $amount, ')
          ..write('autoRenew: $autoRenew')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(itemId, serviceName, billingCycle, amount, autoRenew);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionDetail &&
          other.itemId == this.itemId &&
          other.serviceName == this.serviceName &&
          other.billingCycle == this.billingCycle &&
          other.amount == this.amount &&
          other.autoRenew == this.autoRenew);
}

class SubscriptionDetailsCompanion extends UpdateCompanion<SubscriptionDetail> {
  final Value<String> itemId;
  final Value<String> serviceName;
  final Value<String> billingCycle;
  final Value<double?> amount;
  final Value<bool> autoRenew;
  final Value<int> rowid;
  const SubscriptionDetailsCompanion({
    this.itemId = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.amount = const Value.absent(),
    this.autoRenew = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionDetailsCompanion.insert({
    required String itemId,
    required String serviceName,
    required String billingCycle,
    this.amount = const Value.absent(),
    this.autoRenew = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        serviceName = Value(serviceName),
        billingCycle = Value(billingCycle);
  static Insertable<SubscriptionDetail> custom({
    Expression<String>? itemId,
    Expression<String>? serviceName,
    Expression<String>? billingCycle,
    Expression<double>? amount,
    Expression<bool>? autoRenew,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (serviceName != null) 'service_name': serviceName,
      if (billingCycle != null) 'billing_cycle': billingCycle,
      if (amount != null) 'amount': amount,
      if (autoRenew != null) 'auto_renew': autoRenew,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionDetailsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? serviceName,
      Value<String>? billingCycle,
      Value<double?>? amount,
      Value<bool>? autoRenew,
      Value<int>? rowid}) {
    return SubscriptionDetailsCompanion(
      itemId: itemId ?? this.itemId,
      serviceName: serviceName ?? this.serviceName,
      billingCycle: billingCycle ?? this.billingCycle,
      amount: amount ?? this.amount,
      autoRenew: autoRenew ?? this.autoRenew,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (billingCycle.present) {
      map['billing_cycle'] = Variable<String>(billingCycle.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (autoRenew.present) {
      map['auto_renew'] = Variable<bool>(autoRenew.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionDetailsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('serviceName: $serviceName, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('amount: $amount, ')
          ..write('autoRenew: $autoRenew, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseDetailsTable extends PurchaseDetails
    with TableInfo<$PurchaseDetailsTable, PurchaseDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellerMeta = const VerificationMeta('seller');
  @override
  late final GeneratedColumn<String> seller = GeneratedColumn<String>(
      'seller', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchaseAmountMeta =
      const VerificationMeta('purchaseAmount');
  @override
  late final GeneratedColumn<double> purchaseAmount = GeneratedColumn<double>(
      'purchase_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _returnDeadlineMeta =
      const VerificationMeta('returnDeadline');
  @override
  late final GeneratedColumn<String> returnDeadline = GeneratedColumn<String>(
      'return_deadline', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [itemId, productName, seller, purchaseAmount, returnDeadline];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_details';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('seller')) {
      context.handle(_sellerMeta,
          seller.isAcceptableOrUnknown(data['seller']!, _sellerMeta));
    }
    if (data.containsKey('purchase_amount')) {
      context.handle(
          _purchaseAmountMeta,
          purchaseAmount.isAcceptableOrUnknown(
              data['purchase_amount']!, _purchaseAmountMeta));
    }
    if (data.containsKey('return_deadline')) {
      context.handle(
          _returnDeadlineMeta,
          returnDeadline.isAcceptableOrUnknown(
              data['return_deadline']!, _returnDeadlineMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  PurchaseDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseDetail(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      seller: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller']),
      purchaseAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_amount']),
      returnDeadline: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}return_deadline']),
    );
  }

  @override
  $PurchaseDetailsTable createAlias(String alias) {
    return $PurchaseDetailsTable(attachedDatabase, alias);
  }
}

class PurchaseDetail extends DataClass implements Insertable<PurchaseDetail> {
  final String itemId;
  final String productName;
  final String? seller;
  final double? purchaseAmount;
  final String? returnDeadline;
  const PurchaseDetail(
      {required this.itemId,
      required this.productName,
      this.seller,
      this.purchaseAmount,
      this.returnDeadline});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || seller != null) {
      map['seller'] = Variable<String>(seller);
    }
    if (!nullToAbsent || purchaseAmount != null) {
      map['purchase_amount'] = Variable<double>(purchaseAmount);
    }
    if (!nullToAbsent || returnDeadline != null) {
      map['return_deadline'] = Variable<String>(returnDeadline);
    }
    return map;
  }

  PurchaseDetailsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseDetailsCompanion(
      itemId: Value(itemId),
      productName: Value(productName),
      seller:
          seller == null && nullToAbsent ? const Value.absent() : Value(seller),
      purchaseAmount: purchaseAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseAmount),
      returnDeadline: returnDeadline == null && nullToAbsent
          ? const Value.absent()
          : Value(returnDeadline),
    );
  }

  factory PurchaseDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseDetail(
      itemId: serializer.fromJson<String>(json['itemId']),
      productName: serializer.fromJson<String>(json['productName']),
      seller: serializer.fromJson<String?>(json['seller']),
      purchaseAmount: serializer.fromJson<double?>(json['purchaseAmount']),
      returnDeadline: serializer.fromJson<String?>(json['returnDeadline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'productName': serializer.toJson<String>(productName),
      'seller': serializer.toJson<String?>(seller),
      'purchaseAmount': serializer.toJson<double?>(purchaseAmount),
      'returnDeadline': serializer.toJson<String?>(returnDeadline),
    };
  }

  PurchaseDetail copyWith(
          {String? itemId,
          String? productName,
          Value<String?> seller = const Value.absent(),
          Value<double?> purchaseAmount = const Value.absent(),
          Value<String?> returnDeadline = const Value.absent()}) =>
      PurchaseDetail(
        itemId: itemId ?? this.itemId,
        productName: productName ?? this.productName,
        seller: seller.present ? seller.value : this.seller,
        purchaseAmount:
            purchaseAmount.present ? purchaseAmount.value : this.purchaseAmount,
        returnDeadline:
            returnDeadline.present ? returnDeadline.value : this.returnDeadline,
      );
  PurchaseDetail copyWithCompanion(PurchaseDetailsCompanion data) {
    return PurchaseDetail(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      seller: data.seller.present ? data.seller.value : this.seller,
      purchaseAmount: data.purchaseAmount.present
          ? data.purchaseAmount.value
          : this.purchaseAmount,
      returnDeadline: data.returnDeadline.present
          ? data.returnDeadline.value
          : this.returnDeadline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseDetail(')
          ..write('itemId: $itemId, ')
          ..write('productName: $productName, ')
          ..write('seller: $seller, ')
          ..write('purchaseAmount: $purchaseAmount, ')
          ..write('returnDeadline: $returnDeadline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(itemId, productName, seller, purchaseAmount, returnDeadline);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseDetail &&
          other.itemId == this.itemId &&
          other.productName == this.productName &&
          other.seller == this.seller &&
          other.purchaseAmount == this.purchaseAmount &&
          other.returnDeadline == this.returnDeadline);
}

class PurchaseDetailsCompanion extends UpdateCompanion<PurchaseDetail> {
  final Value<String> itemId;
  final Value<String> productName;
  final Value<String?> seller;
  final Value<double?> purchaseAmount;
  final Value<String?> returnDeadline;
  final Value<int> rowid;
  const PurchaseDetailsCompanion({
    this.itemId = const Value.absent(),
    this.productName = const Value.absent(),
    this.seller = const Value.absent(),
    this.purchaseAmount = const Value.absent(),
    this.returnDeadline = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseDetailsCompanion.insert({
    required String itemId,
    required String productName,
    this.seller = const Value.absent(),
    this.purchaseAmount = const Value.absent(),
    this.returnDeadline = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        productName = Value(productName);
  static Insertable<PurchaseDetail> custom({
    Expression<String>? itemId,
    Expression<String>? productName,
    Expression<String>? seller,
    Expression<double>? purchaseAmount,
    Expression<String>? returnDeadline,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (productName != null) 'product_name': productName,
      if (seller != null) 'seller': seller,
      if (purchaseAmount != null) 'purchase_amount': purchaseAmount,
      if (returnDeadline != null) 'return_deadline': returnDeadline,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseDetailsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? productName,
      Value<String?>? seller,
      Value<double?>? purchaseAmount,
      Value<String?>? returnDeadline,
      Value<int>? rowid}) {
    return PurchaseDetailsCompanion(
      itemId: itemId ?? this.itemId,
      productName: productName ?? this.productName,
      seller: seller ?? this.seller,
      purchaseAmount: purchaseAmount ?? this.purchaseAmount,
      returnDeadline: returnDeadline ?? this.returnDeadline,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (seller.present) {
      map['seller'] = Variable<String>(seller.value);
    }
    if (purchaseAmount.present) {
      map['purchase_amount'] = Variable<double>(purchaseAmount.value);
    }
    if (returnDeadline.present) {
      map['return_deadline'] = Variable<String>(returnDeadline.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseDetailsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('productName: $productName, ')
          ..write('seller: $seller, ')
          ..write('purchaseAmount: $purchaseAmount, ')
          ..write('returnDeadline: $returnDeadline, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroceryDetailsTable extends GroceryDetails
    with TableInfo<$GroceryDetailsTable, GroceryDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroceryDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _batchNumberMeta =
      const VerificationMeta('batchNumber');
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
      'batch_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _storageLocationMeta =
      const VerificationMeta('storageLocation');
  @override
  late final GeneratedColumn<String> storageLocation = GeneratedColumn<String>(
      'storage_location', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pantry'));
  static const VerificationMeta _quantityRemainingMeta =
      const VerificationMeta('quantityRemaining');
  @override
  late final GeneratedColumn<double> quantityRemaining =
      GeneratedColumn<double>('quantity_remaining', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(1.0));
  static const VerificationMeta _quantityUnitMeta =
      const VerificationMeta('quantityUnit');
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
      'quantity_unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('units'));
  @override
  List<GeneratedColumn> get $columns => [
        itemId,
        productName,
        batchNumber,
        storageLocation,
        quantityRemaining,
        quantityUnit
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grocery_details';
  @override
  VerificationContext validateIntegrity(Insertable<GroceryDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
          _batchNumberMeta,
          batchNumber.isAcceptableOrUnknown(
              data['batch_number']!, _batchNumberMeta));
    }
    if (data.containsKey('storage_location')) {
      context.handle(
          _storageLocationMeta,
          storageLocation.isAcceptableOrUnknown(
              data['storage_location']!, _storageLocationMeta));
    }
    if (data.containsKey('quantity_remaining')) {
      context.handle(
          _quantityRemainingMeta,
          quantityRemaining.isAcceptableOrUnknown(
              data['quantity_remaining']!, _quantityRemainingMeta));
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
          _quantityUnitMeta,
          quantityUnit.isAcceptableOrUnknown(
              data['quantity_unit']!, _quantityUnitMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  GroceryDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroceryDetail(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      batchNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_number']),
      storageLocation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}storage_location'])!,
      quantityRemaining: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantity_remaining'])!,
      quantityUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity_unit'])!,
    );
  }

  @override
  $GroceryDetailsTable createAlias(String alias) {
    return $GroceryDetailsTable(attachedDatabase, alias);
  }
}

class GroceryDetail extends DataClass implements Insertable<GroceryDetail> {
  final String itemId;
  final String productName;
  final String? batchNumber;
  final String storageLocation;
  final double quantityRemaining;
  final String quantityUnit;
  const GroceryDetail(
      {required this.itemId,
      required this.productName,
      this.batchNumber,
      required this.storageLocation,
      required this.quantityRemaining,
      required this.quantityUnit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || batchNumber != null) {
      map['batch_number'] = Variable<String>(batchNumber);
    }
    map['storage_location'] = Variable<String>(storageLocation);
    map['quantity_remaining'] = Variable<double>(quantityRemaining);
    map['quantity_unit'] = Variable<String>(quantityUnit);
    return map;
  }

  GroceryDetailsCompanion toCompanion(bool nullToAbsent) {
    return GroceryDetailsCompanion(
      itemId: Value(itemId),
      productName: Value(productName),
      batchNumber: batchNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(batchNumber),
      storageLocation: Value(storageLocation),
      quantityRemaining: Value(quantityRemaining),
      quantityUnit: Value(quantityUnit),
    );
  }

  factory GroceryDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroceryDetail(
      itemId: serializer.fromJson<String>(json['itemId']),
      productName: serializer.fromJson<String>(json['productName']),
      batchNumber: serializer.fromJson<String?>(json['batchNumber']),
      storageLocation: serializer.fromJson<String>(json['storageLocation']),
      quantityRemaining: serializer.fromJson<double>(json['quantityRemaining']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'productName': serializer.toJson<String>(productName),
      'batchNumber': serializer.toJson<String?>(batchNumber),
      'storageLocation': serializer.toJson<String>(storageLocation),
      'quantityRemaining': serializer.toJson<double>(quantityRemaining),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
    };
  }

  GroceryDetail copyWith(
          {String? itemId,
          String? productName,
          Value<String?> batchNumber = const Value.absent(),
          String? storageLocation,
          double? quantityRemaining,
          String? quantityUnit}) =>
      GroceryDetail(
        itemId: itemId ?? this.itemId,
        productName: productName ?? this.productName,
        batchNumber: batchNumber.present ? batchNumber.value : this.batchNumber,
        storageLocation: storageLocation ?? this.storageLocation,
        quantityRemaining: quantityRemaining ?? this.quantityRemaining,
        quantityUnit: quantityUnit ?? this.quantityUnit,
      );
  GroceryDetail copyWithCompanion(GroceryDetailsCompanion data) {
    return GroceryDetail(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      batchNumber:
          data.batchNumber.present ? data.batchNumber.value : this.batchNumber,
      storageLocation: data.storageLocation.present
          ? data.storageLocation.value
          : this.storageLocation,
      quantityRemaining: data.quantityRemaining.present
          ? data.quantityRemaining.value
          : this.quantityRemaining,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroceryDetail(')
          ..write('itemId: $itemId, ')
          ..write('productName: $productName, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('quantityRemaining: $quantityRemaining, ')
          ..write('quantityUnit: $quantityUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, productName, batchNumber,
      storageLocation, quantityRemaining, quantityUnit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroceryDetail &&
          other.itemId == this.itemId &&
          other.productName == this.productName &&
          other.batchNumber == this.batchNumber &&
          other.storageLocation == this.storageLocation &&
          other.quantityRemaining == this.quantityRemaining &&
          other.quantityUnit == this.quantityUnit);
}

class GroceryDetailsCompanion extends UpdateCompanion<GroceryDetail> {
  final Value<String> itemId;
  final Value<String> productName;
  final Value<String?> batchNumber;
  final Value<String> storageLocation;
  final Value<double> quantityRemaining;
  final Value<String> quantityUnit;
  final Value<int> rowid;
  const GroceryDetailsCompanion({
    this.itemId = const Value.absent(),
    this.productName = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.storageLocation = const Value.absent(),
    this.quantityRemaining = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroceryDetailsCompanion.insert({
    required String itemId,
    required String productName,
    this.batchNumber = const Value.absent(),
    this.storageLocation = const Value.absent(),
    this.quantityRemaining = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        productName = Value(productName);
  static Insertable<GroceryDetail> custom({
    Expression<String>? itemId,
    Expression<String>? productName,
    Expression<String>? batchNumber,
    Expression<String>? storageLocation,
    Expression<double>? quantityRemaining,
    Expression<String>? quantityUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (productName != null) 'product_name': productName,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (storageLocation != null) 'storage_location': storageLocation,
      if (quantityRemaining != null) 'quantity_remaining': quantityRemaining,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroceryDetailsCompanion copyWith(
      {Value<String>? itemId,
      Value<String>? productName,
      Value<String?>? batchNumber,
      Value<String>? storageLocation,
      Value<double>? quantityRemaining,
      Value<String>? quantityUnit,
      Value<int>? rowid}) {
    return GroceryDetailsCompanion(
      itemId: itemId ?? this.itemId,
      productName: productName ?? this.productName,
      batchNumber: batchNumber ?? this.batchNumber,
      storageLocation: storageLocation ?? this.storageLocation,
      quantityRemaining: quantityRemaining ?? this.quantityRemaining,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (storageLocation.present) {
      map['storage_location'] = Variable<String>(storageLocation.value);
    }
    if (quantityRemaining.present) {
      map['quantity_remaining'] = Variable<double>(quantityRemaining.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroceryDetailsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('productName: $productName, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('storageLocation: $storageLocation, ')
          ..write('quantityRemaining: $quantityRemaining, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentDetailsTable extends DocumentDetails
    with TableInfo<$DocumentDetailsTable, DocumentDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentNumberMeta =
      const VerificationMeta('documentNumber');
  @override
  late final GeneratedColumn<String> documentNumber = GeneratedColumn<String>(
      'document_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _issuingAuthorityMeta =
      const VerificationMeta('issuingAuthority');
  @override
  late final GeneratedColumn<String> issuingAuthority = GeneratedColumn<String>(
      'issuing_authority', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _documentTypeMeta =
      const VerificationMeta('documentType');
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
      'document_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [itemId, documentNumber, issuingAuthority, documentType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_details';
  @override
  VerificationContext validateIntegrity(Insertable<DocumentDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('document_number')) {
      context.handle(
          _documentNumberMeta,
          documentNumber.isAcceptableOrUnknown(
              data['document_number']!, _documentNumberMeta));
    }
    if (data.containsKey('issuing_authority')) {
      context.handle(
          _issuingAuthorityMeta,
          issuingAuthority.isAcceptableOrUnknown(
              data['issuing_authority']!, _issuingAuthorityMeta));
    }
    if (data.containsKey('document_type')) {
      context.handle(
          _documentTypeMeta,
          documentType.isAcceptableOrUnknown(
              data['document_type']!, _documentTypeMeta));
    } else if (isInserting) {
      context.missing(_documentTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  DocumentDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentDetail(
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      documentNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_number']),
      issuingAuthority: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}issuing_authority']),
      documentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_type'])!,
    );
  }

  @override
  $DocumentDetailsTable createAlias(String alias) {
    return $DocumentDetailsTable(attachedDatabase, alias);
  }
}

class DocumentDetail extends DataClass implements Insertable<DocumentDetail> {
  final String itemId;
  final String? documentNumber;
  final String? issuingAuthority;
  final String documentType;
  const DocumentDetail(
      {required this.itemId,
      this.documentNumber,
      this.issuingAuthority,
      required this.documentType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || documentNumber != null) {
      map['document_number'] = Variable<String>(documentNumber);
    }
    if (!nullToAbsent || issuingAuthority != null) {
      map['issuing_authority'] = Variable<String>(issuingAuthority);
    }
    map['document_type'] = Variable<String>(documentType);
    return map;
  }

  DocumentDetailsCompanion toCompanion(bool nullToAbsent) {
    return DocumentDetailsCompanion(
      itemId: Value(itemId),
      documentNumber: documentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(documentNumber),
      issuingAuthority: issuingAuthority == null && nullToAbsent
          ? const Value.absent()
          : Value(issuingAuthority),
      documentType: Value(documentType),
    );
  }

  factory DocumentDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentDetail(
      itemId: serializer.fromJson<String>(json['itemId']),
      documentNumber: serializer.fromJson<String?>(json['documentNumber']),
      issuingAuthority: serializer.fromJson<String?>(json['issuingAuthority']),
      documentType: serializer.fromJson<String>(json['documentType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'documentNumber': serializer.toJson<String?>(documentNumber),
      'issuingAuthority': serializer.toJson<String?>(issuingAuthority),
      'documentType': serializer.toJson<String>(documentType),
    };
  }

  DocumentDetail copyWith(
          {String? itemId,
          Value<String?> documentNumber = const Value.absent(),
          Value<String?> issuingAuthority = const Value.absent(),
          String? documentType}) =>
      DocumentDetail(
        itemId: itemId ?? this.itemId,
        documentNumber:
            documentNumber.present ? documentNumber.value : this.documentNumber,
        issuingAuthority: issuingAuthority.present
            ? issuingAuthority.value
            : this.issuingAuthority,
        documentType: documentType ?? this.documentType,
      );
  DocumentDetail copyWithCompanion(DocumentDetailsCompanion data) {
    return DocumentDetail(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      documentNumber: data.documentNumber.present
          ? data.documentNumber.value
          : this.documentNumber,
      issuingAuthority: data.issuingAuthority.present
          ? data.issuingAuthority.value
          : this.issuingAuthority,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentDetail(')
          ..write('itemId: $itemId, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('issuingAuthority: $issuingAuthority, ')
          ..write('documentType: $documentType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(itemId, documentNumber, issuingAuthority, documentType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentDetail &&
          other.itemId == this.itemId &&
          other.documentNumber == this.documentNumber &&
          other.issuingAuthority == this.issuingAuthority &&
          other.documentType == this.documentType);
}

class DocumentDetailsCompanion extends UpdateCompanion<DocumentDetail> {
  final Value<String> itemId;
  final Value<String?> documentNumber;
  final Value<String?> issuingAuthority;
  final Value<String> documentType;
  final Value<int> rowid;
  const DocumentDetailsCompanion({
    this.itemId = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.issuingAuthority = const Value.absent(),
    this.documentType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentDetailsCompanion.insert({
    required String itemId,
    this.documentNumber = const Value.absent(),
    this.issuingAuthority = const Value.absent(),
    required String documentType,
    this.rowid = const Value.absent(),
  })  : itemId = Value(itemId),
        documentType = Value(documentType);
  static Insertable<DocumentDetail> custom({
    Expression<String>? itemId,
    Expression<String>? documentNumber,
    Expression<String>? issuingAuthority,
    Expression<String>? documentType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (documentNumber != null) 'document_number': documentNumber,
      if (issuingAuthority != null) 'issuing_authority': issuingAuthority,
      if (documentType != null) 'document_type': documentType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentDetailsCompanion copyWith(
      {Value<String>? itemId,
      Value<String?>? documentNumber,
      Value<String?>? issuingAuthority,
      Value<String>? documentType,
      Value<int>? rowid}) {
    return DocumentDetailsCompanion(
      itemId: itemId ?? this.itemId,
      documentNumber: documentNumber ?? this.documentNumber,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      documentType: documentType ?? this.documentType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (documentNumber.present) {
      map['document_number'] = Variable<String>(documentNumber.value);
    }
    if (issuingAuthority.present) {
      map['issuing_authority'] = Variable<String>(issuingAuthority.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentDetailsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('issuingAuthority: $issuingAuthority, ')
          ..write('documentType: $documentType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemDocumentsTable extends ItemDocuments
    with TableInfo<$ItemDocumentsTable, ItemDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relativePathMeta =
      const VerificationMeta('relativePath');
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
      'relative_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _checksumSha256Meta =
      const VerificationMeta('checksumSha256');
  @override
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
      'checksum_sha256', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        fileName,
        relativePath,
        mimeType,
        fileSize,
        checksumSha256,
        source,
        createdAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_documents';
  @override
  VerificationContext validateIntegrity(Insertable<ItemDocument> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
          _relativePathMeta,
          relativePath.isAcceptableOrUnknown(
              data['relative_path']!, _relativePathMeta));
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
          _checksumSha256Meta,
          checksumSha256.isAcceptableOrUnknown(
              data['checksum_sha256']!, _checksumSha256Meta));
    } else if (isInserting) {
      context.missing(_checksumSha256Meta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemDocument(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id']),
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      relativePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relative_path'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
      checksumSha256: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checksum_sha256'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ItemDocumentsTable createAlias(String alias) {
    return $ItemDocumentsTable(attachedDatabase, alias);
  }
}

class ItemDocument extends DataClass implements Insertable<ItemDocument> {
  final String id;
  final String? itemId;
  final String fileName;
  final String relativePath;
  final String mimeType;
  final int fileSize;
  final String checksumSha256;
  final String source;
  final String createdAt;
  final String? deletedAt;
  const ItemDocument(
      {required this.id,
      this.itemId,
      required this.fileName,
      required this.relativePath,
      required this.mimeType,
      required this.fileSize,
      required this.checksumSha256,
      required this.source,
      required this.createdAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['file_name'] = Variable<String>(fileName);
    map['relative_path'] = Variable<String>(relativePath);
    map['mime_type'] = Variable<String>(mimeType);
    map['file_size'] = Variable<int>(fileSize);
    map['checksum_sha256'] = Variable<String>(checksumSha256);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    return map;
  }

  ItemDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ItemDocumentsCompanion(
      id: Value(id),
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
      fileName: Value(fileName),
      relativePath: Value(relativePath),
      mimeType: Value(mimeType),
      fileSize: Value(fileSize),
      checksumSha256: Value(checksumSha256),
      source: Value(source),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ItemDocument.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemDocument(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      checksumSha256: serializer.fromJson<String>(json['checksumSha256']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String?>(itemId),
      'fileName': serializer.toJson<String>(fileName),
      'relativePath': serializer.toJson<String>(relativePath),
      'mimeType': serializer.toJson<String>(mimeType),
      'fileSize': serializer.toJson<int>(fileSize),
      'checksumSha256': serializer.toJson<String>(checksumSha256),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<String>(createdAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
    };
  }

  ItemDocument copyWith(
          {String? id,
          Value<String?> itemId = const Value.absent(),
          String? fileName,
          String? relativePath,
          String? mimeType,
          int? fileSize,
          String? checksumSha256,
          String? source,
          String? createdAt,
          Value<String?> deletedAt = const Value.absent()}) =>
      ItemDocument(
        id: id ?? this.id,
        itemId: itemId.present ? itemId.value : this.itemId,
        fileName: fileName ?? this.fileName,
        relativePath: relativePath ?? this.relativePath,
        mimeType: mimeType ?? this.mimeType,
        fileSize: fileSize ?? this.fileSize,
        checksumSha256: checksumSha256 ?? this.checksumSha256,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  ItemDocument copyWithCompanion(ItemDocumentsCompanion data) {
    return ItemDocument(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemDocument(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('fileName: $fileName, ')
          ..write('relativePath: $relativePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, fileName, relativePath, mimeType,
      fileSize, checksumSha256, source, createdAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemDocument &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.fileName == this.fileName &&
          other.relativePath == this.relativePath &&
          other.mimeType == this.mimeType &&
          other.fileSize == this.fileSize &&
          other.checksumSha256 == this.checksumSha256 &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class ItemDocumentsCompanion extends UpdateCompanion<ItemDocument> {
  final Value<String> id;
  final Value<String?> itemId;
  final Value<String> fileName;
  final Value<String> relativePath;
  final Value<String> mimeType;
  final Value<int> fileSize;
  final Value<String> checksumSha256;
  final Value<String> source;
  final Value<String> createdAt;
  final Value<String?> deletedAt;
  final Value<int> rowid;
  const ItemDocumentsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemDocumentsCompanion.insert({
    required String id,
    this.itemId = const Value.absent(),
    required String fileName,
    required String relativePath,
    required String mimeType,
    required int fileSize,
    required String checksumSha256,
    required String source,
    required String createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fileName = Value(fileName),
        relativePath = Value(relativePath),
        mimeType = Value(mimeType),
        fileSize = Value(fileSize),
        checksumSha256 = Value(checksumSha256),
        source = Value(source),
        createdAt = Value(createdAt);
  static Insertable<ItemDocument> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? fileName,
    Expression<String>? relativePath,
    Expression<String>? mimeType,
    Expression<int>? fileSize,
    Expression<String>? checksumSha256,
    Expression<String>? source,
    Expression<String>? createdAt,
    Expression<String>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (fileName != null) 'file_name': fileName,
      if (relativePath != null) 'relative_path': relativePath,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSize != null) 'file_size': fileSize,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemDocumentsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? itemId,
      Value<String>? fileName,
      Value<String>? relativePath,
      Value<String>? mimeType,
      Value<int>? fileSize,
      Value<String>? checksumSha256,
      Value<String>? source,
      Value<String>? createdAt,
      Value<String?>? deletedAt,
      Value<int>? rowid}) {
    return ItemDocumentsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      fileName: fileName ?? this.fileName,
      relativePath: relativePath ?? this.relativePath,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('fileName: $fileName, ')
          ..write('relativePath: $relativePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRulesTable extends ReminderRules
    with TableInfo<$ReminderRulesTable, ReminderRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _offsetDaysMeta =
      const VerificationMeta('offsetDays');
  @override
  late final GeneratedColumn<int> offsetDays = GeneratedColumn<int>(
      'offset_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reminderTimeMeta =
      const VerificationMeta('reminderTime');
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
      'reminder_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('09:00'));
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, itemId, offsetDays, reminderTime, isEnabled, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rules';
  @override
  VerificationContext validateIntegrity(Insertable<ReminderRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('offset_days')) {
      context.handle(
          _offsetDaysMeta,
          offsetDays.isAcceptableOrUnknown(
              data['offset_days']!, _offsetDaysMeta));
    } else if (isInserting) {
      context.missing(_offsetDaysMeta);
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
          _reminderTimeMeta,
          reminderTime.isAcceptableOrUnknown(
              data['reminder_time']!, _reminderTimeMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      offsetDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}offset_days'])!,
      reminderTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reminder_time'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ReminderRulesTable createAlias(String alias) {
    return $ReminderRulesTable(attachedDatabase, alias);
  }
}

class ReminderRule extends DataClass implements Insertable<ReminderRule> {
  final String id;
  final String itemId;
  final int offsetDays;
  final String reminderTime;
  final bool isEnabled;
  final String createdAt;
  const ReminderRule(
      {required this.id,
      required this.itemId,
      required this.offsetDays,
      required this.reminderTime,
      required this.isEnabled,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['offset_days'] = Variable<int>(offsetDays);
    map['reminder_time'] = Variable<String>(reminderTime);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ReminderRulesCompanion toCompanion(bool nullToAbsent) {
    return ReminderRulesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      offsetDays: Value(offsetDays),
      reminderTime: Value(reminderTime),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
    );
  }

  factory ReminderRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRule(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      offsetDays: serializer.fromJson<int>(json['offsetDays']),
      reminderTime: serializer.fromJson<String>(json['reminderTime']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'offsetDays': serializer.toJson<int>(offsetDays),
      'reminderTime': serializer.toJson<String>(reminderTime),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  ReminderRule copyWith(
          {String? id,
          String? itemId,
          int? offsetDays,
          String? reminderTime,
          bool? isEnabled,
          String? createdAt}) =>
      ReminderRule(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        offsetDays: offsetDays ?? this.offsetDays,
        reminderTime: reminderTime ?? this.reminderTime,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
      );
  ReminderRule copyWithCompanion(ReminderRulesCompanion data) {
    return ReminderRule(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      offsetDays:
          data.offsetDays.present ? data.offsetDays.value : this.offsetDays,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRule(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('offsetDays: $offsetDays, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, offsetDays, reminderTime, isEnabled, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRule &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.offsetDays == this.offsetDays &&
          other.reminderTime == this.reminderTime &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt);
}

class ReminderRulesCompanion extends UpdateCompanion<ReminderRule> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<int> offsetDays;
  final Value<String> reminderTime;
  final Value<bool> isEnabled;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ReminderRulesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.offsetDays = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRulesCompanion.insert({
    required String id,
    required String itemId,
    required int offsetDays,
    this.reminderTime = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        offsetDays = Value(offsetDays),
        createdAt = Value(createdAt);
  static Insertable<ReminderRule> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<int>? offsetDays,
    Expression<String>? reminderTime,
    Expression<bool>? isEnabled,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (offsetDays != null) 'offset_days': offsetDays,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<int>? offsetDays,
      Value<String>? reminderTime,
      Value<bool>? isEnabled,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return ReminderRulesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      offsetDays: offsetDays ?? this.offsetDays,
      reminderTime: reminderTime ?? this.reminderTime,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (offsetDays.present) {
      map['offset_days'] = Variable<int>(offsetDays.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRulesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('offsetDays: $offsetDays, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledRemindersTable extends ScheduledReminders
    with TableInfo<$ScheduledRemindersTable, ScheduledReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reminderRuleIdMeta =
      const VerificationMeta('reminderRuleId');
  @override
  late final GeneratedColumn<String> reminderRuleId = GeneratedColumn<String>(
      'reminder_rule_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notificationIdMeta =
      const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
      'notification_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<String> scheduledAt = GeneratedColumn<String>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        reminderRuleId,
        notificationId,
        scheduledAt,
        status,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_reminders';
  @override
  VerificationContext validateIntegrity(Insertable<ScheduledReminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('reminder_rule_id')) {
      context.handle(
          _reminderRuleIdMeta,
          reminderRuleId.isAcceptableOrUnknown(
              data['reminder_rule_id']!, _reminderRuleIdMeta));
    } else if (isInserting) {
      context.missing(_reminderRuleIdMeta);
    }
    if (data.containsKey('notification_id')) {
      context.handle(
          _notificationIdMeta,
          notificationId.isAcceptableOrUnknown(
              data['notification_id']!, _notificationIdMeta));
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledReminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      reminderRuleId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_rule_id'])!,
      notificationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notification_id'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scheduled_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ScheduledRemindersTable createAlias(String alias) {
    return $ScheduledRemindersTable(attachedDatabase, alias);
  }
}

class ScheduledReminder extends DataClass
    implements Insertable<ScheduledReminder> {
  final String id;
  final String itemId;
  final String reminderRuleId;
  final int notificationId;
  final String scheduledAt;
  final String status;
  final String createdAt;
  const ScheduledReminder(
      {required this.id,
      required this.itemId,
      required this.reminderRuleId,
      required this.notificationId,
      required this.scheduledAt,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['reminder_rule_id'] = Variable<String>(reminderRuleId);
    map['notification_id'] = Variable<int>(notificationId);
    map['scheduled_at'] = Variable<String>(scheduledAt);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ScheduledRemindersCompanion toCompanion(bool nullToAbsent) {
    return ScheduledRemindersCompanion(
      id: Value(id),
      itemId: Value(itemId),
      reminderRuleId: Value(reminderRuleId),
      notificationId: Value(notificationId),
      scheduledAt: Value(scheduledAt),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduledReminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledReminder(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      reminderRuleId: serializer.fromJson<String>(json['reminderRuleId']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      scheduledAt: serializer.fromJson<String>(json['scheduledAt']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'reminderRuleId': serializer.toJson<String>(reminderRuleId),
      'notificationId': serializer.toJson<int>(notificationId),
      'scheduledAt': serializer.toJson<String>(scheduledAt),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  ScheduledReminder copyWith(
          {String? id,
          String? itemId,
          String? reminderRuleId,
          int? notificationId,
          String? scheduledAt,
          String? status,
          String? createdAt}) =>
      ScheduledReminder(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        reminderRuleId: reminderRuleId ?? this.reminderRuleId,
        notificationId: notificationId ?? this.notificationId,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  ScheduledReminder copyWithCompanion(ScheduledRemindersCompanion data) {
    return ScheduledReminder(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      reminderRuleId: data.reminderRuleId.present
          ? data.reminderRuleId.value
          : this.reminderRuleId,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledReminder(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('reminderRuleId: $reminderRuleId, ')
          ..write('notificationId: $notificationId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, reminderRuleId, notificationId,
      scheduledAt, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledReminder &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.reminderRuleId == this.reminderRuleId &&
          other.notificationId == this.notificationId &&
          other.scheduledAt == this.scheduledAt &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class ScheduledRemindersCompanion extends UpdateCompanion<ScheduledReminder> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> reminderRuleId;
  final Value<int> notificationId;
  final Value<String> scheduledAt;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ScheduledRemindersCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.reminderRuleId = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduledRemindersCompanion.insert({
    required String id,
    required String itemId,
    required String reminderRuleId,
    required int notificationId,
    required String scheduledAt,
    required String status,
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        reminderRuleId = Value(reminderRuleId),
        notificationId = Value(notificationId),
        scheduledAt = Value(scheduledAt),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<ScheduledReminder> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? reminderRuleId,
    Expression<int>? notificationId,
    Expression<String>? scheduledAt,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (reminderRuleId != null) 'reminder_rule_id': reminderRuleId,
      if (notificationId != null) 'notification_id': notificationId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduledRemindersCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String>? reminderRuleId,
      Value<int>? notificationId,
      Value<String>? scheduledAt,
      Value<String>? status,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return ScheduledRemindersCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      reminderRuleId: reminderRuleId ?? this.reminderRuleId,
      notificationId: notificationId ?? this.notificationId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (reminderRuleId.present) {
      map['reminder_rule_id'] = Variable<String>(reminderRuleId.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<String>(scheduledAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledRemindersCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('reminderRuleId: $reminderRuleId, ')
          ..write('notificationId: $notificationId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemHistoryTable extends ItemHistory
    with TableInfo<$ItemHistoryTable, ItemHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDataJsonMeta =
      const VerificationMeta('eventDataJson');
  @override
  late final GeneratedColumn<String> eventDataJson = GeneratedColumn<String>(
      'event_data_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _eventAtMeta =
      const VerificationMeta('eventAt');
  @override
  late final GeneratedColumn<String> eventAt = GeneratedColumn<String>(
      'event_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, itemId, eventType, eventDataJson, eventAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_history';
  @override
  VerificationContext validateIntegrity(Insertable<ItemHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_data_json')) {
      context.handle(
          _eventDataJsonMeta,
          eventDataJson.isAcceptableOrUnknown(
              data['event_data_json']!, _eventDataJsonMeta));
    }
    if (data.containsKey('event_at')) {
      context.handle(_eventAtMeta,
          eventAt.isAcceptableOrUnknown(data['event_at']!, _eventAtMeta));
    } else if (isInserting) {
      context.missing(_eventAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      eventDataJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}event_data_json'])!,
      eventAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_at'])!,
    );
  }

  @override
  $ItemHistoryTable createAlias(String alias) {
    return $ItemHistoryTable(attachedDatabase, alias);
  }
}

class ItemHistoryData extends DataClass implements Insertable<ItemHistoryData> {
  final String id;
  final String itemId;
  final String eventType;
  final String eventDataJson;
  final String eventAt;
  const ItemHistoryData(
      {required this.id,
      required this.itemId,
      required this.eventType,
      required this.eventDataJson,
      required this.eventAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['event_type'] = Variable<String>(eventType);
    map['event_data_json'] = Variable<String>(eventDataJson);
    map['event_at'] = Variable<String>(eventAt);
    return map;
  }

  ItemHistoryCompanion toCompanion(bool nullToAbsent) {
    return ItemHistoryCompanion(
      id: Value(id),
      itemId: Value(itemId),
      eventType: Value(eventType),
      eventDataJson: Value(eventDataJson),
      eventAt: Value(eventAt),
    );
  }

  factory ItemHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemHistoryData(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventDataJson: serializer.fromJson<String>(json['eventDataJson']),
      eventAt: serializer.fromJson<String>(json['eventAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'eventType': serializer.toJson<String>(eventType),
      'eventDataJson': serializer.toJson<String>(eventDataJson),
      'eventAt': serializer.toJson<String>(eventAt),
    };
  }

  ItemHistoryData copyWith(
          {String? id,
          String? itemId,
          String? eventType,
          String? eventDataJson,
          String? eventAt}) =>
      ItemHistoryData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        eventType: eventType ?? this.eventType,
        eventDataJson: eventDataJson ?? this.eventDataJson,
        eventAt: eventAt ?? this.eventAt,
      );
  ItemHistoryData copyWithCompanion(ItemHistoryCompanion data) {
    return ItemHistoryData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventDataJson: data.eventDataJson.present
          ? data.eventDataJson.value
          : this.eventDataJson,
      eventAt: data.eventAt.present ? data.eventAt.value : this.eventAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemHistoryData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('eventType: $eventType, ')
          ..write('eventDataJson: $eventDataJson, ')
          ..write('eventAt: $eventAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, eventType, eventDataJson, eventAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemHistoryData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.eventType == this.eventType &&
          other.eventDataJson == this.eventDataJson &&
          other.eventAt == this.eventAt);
}

class ItemHistoryCompanion extends UpdateCompanion<ItemHistoryData> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> eventType;
  final Value<String> eventDataJson;
  final Value<String> eventAt;
  final Value<int> rowid;
  const ItemHistoryCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventDataJson = const Value.absent(),
    this.eventAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemHistoryCompanion.insert({
    required String id,
    required String itemId,
    required String eventType,
    this.eventDataJson = const Value.absent(),
    required String eventAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        eventType = Value(eventType),
        eventAt = Value(eventAt);
  static Insertable<ItemHistoryData> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? eventType,
    Expression<String>? eventDataJson,
    Expression<String>? eventAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (eventType != null) 'event_type': eventType,
      if (eventDataJson != null) 'event_data_json': eventDataJson,
      if (eventAt != null) 'event_at': eventAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemHistoryCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String>? eventType,
      Value<String>? eventDataJson,
      Value<String>? eventAt,
      Value<int>? rowid}) {
    return ItemHistoryCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      eventType: eventType ?? this.eventType,
      eventDataJson: eventDataJson ?? this.eventDataJson,
      eventAt: eventAt ?? this.eventAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventDataJson.present) {
      map['event_data_json'] = Variable<String>(eventDataJson.value);
    }
    if (eventAt.present) {
      map['event_at'] = Variable<String>(eventAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemHistoryCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('eventType: $eventType, ')
          ..write('eventDataJson: $eventDataJson, ')
          ..write('eventAt: $eventAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _settingKeyMeta =
      const VerificationMeta('settingKey');
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
      'setting_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _settingValueMeta =
      const VerificationMeta('settingValue');
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
      'setting_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, settingKey, settingValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('setting_key')) {
      context.handle(
          _settingKeyMeta,
          settingKey.isAcceptableOrUnknown(
              data['setting_key']!, _settingKeyMeta));
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
          _settingValueMeta,
          settingValue.isAcceptableOrUnknown(
              data['setting_value']!, _settingValueMeta));
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      settingKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_key'])!,
      settingValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String id;
  final String settingKey;
  final String settingValue;
  final String updatedAt;
  const AppSetting(
      {required this.id,
      required this.settingKey,
      required this.settingValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<String>(json['id']),
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  AppSetting copyWith(
          {String? id,
          String? settingKey,
          String? settingValue,
          String? updatedAt}) =>
      AppSetting(
        id: id ?? this.id,
        settingKey: settingKey ?? this.settingKey,
        settingValue: settingValue ?? this.settingValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      settingKey:
          data.settingKey.present ? data.settingKey.value : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, settingKey, settingValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> id;
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String id,
    required String settingKey,
    required String settingValue,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        settingKey = Value(settingKey),
        settingValue = Value(settingValue),
        updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? id,
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? settingKey,
      Value<String>? settingValue,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupHistoryTable extends BackupHistory
    with TableInfo<$BackupHistoryTable, BackupHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backupIdMeta =
      const VerificationMeta('backupId');
  @override
  late final GeneratedColumn<String> backupId = GeneratedColumn<String>(
      'backup_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backupTypeMeta =
      const VerificationMeta('backupType');
  @override
  late final GeneratedColumn<String> backupType = GeneratedColumn<String>(
      'backup_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatVersionMeta =
      const VerificationMeta('formatVersion');
  @override
  late final GeneratedColumn<int> formatVersion = GeneratedColumn<int>(
      'format_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationTypeMeta =
      const VerificationMeta('destinationType');
  @override
  late final GeneratedColumn<String> destinationType = GeneratedColumn<String>(
      'destination_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        backupId,
        backupType,
        formatVersion,
        schemaVersion,
        createdAt,
        fileSize,
        checksum,
        destinationType,
        status,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_history';
  @override
  VerificationContext validateIntegrity(Insertable<BackupHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('backup_id')) {
      context.handle(_backupIdMeta,
          backupId.isAcceptableOrUnknown(data['backup_id']!, _backupIdMeta));
    } else if (isInserting) {
      context.missing(_backupIdMeta);
    }
    if (data.containsKey('backup_type')) {
      context.handle(
          _backupTypeMeta,
          backupType.isAcceptableOrUnknown(
              data['backup_type']!, _backupTypeMeta));
    } else if (isInserting) {
      context.missing(_backupTypeMeta);
    }
    if (data.containsKey('format_version')) {
      context.handle(
          _formatVersionMeta,
          formatVersion.isAcceptableOrUnknown(
              data['format_version']!, _formatVersionMeta));
    } else if (isInserting) {
      context.missing(_formatVersionMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('destination_type')) {
      context.handle(
          _destinationTypeMeta,
          destinationType.isAcceptableOrUnknown(
              data['destination_type']!, _destinationTypeMeta));
    } else if (isInserting) {
      context.missing(_destinationTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      backupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backup_id'])!,
      backupType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backup_type'])!,
      formatVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}format_version'])!,
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum'])!,
      destinationType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destination_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $BackupHistoryTable createAlias(String alias) {
    return $BackupHistoryTable(attachedDatabase, alias);
  }
}

class BackupHistoryData extends DataClass
    implements Insertable<BackupHistoryData> {
  final String id;
  final String backupId;
  final String backupType;
  final int formatVersion;
  final int schemaVersion;
  final String createdAt;
  final int fileSize;
  final String checksum;
  final String destinationType;
  final String status;
  final String? completedAt;
  const BackupHistoryData(
      {required this.id,
      required this.backupId,
      required this.backupType,
      required this.formatVersion,
      required this.schemaVersion,
      required this.createdAt,
      required this.fileSize,
      required this.checksum,
      required this.destinationType,
      required this.status,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['backup_id'] = Variable<String>(backupId);
    map['backup_type'] = Variable<String>(backupType);
    map['format_version'] = Variable<int>(formatVersion);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['created_at'] = Variable<String>(createdAt);
    map['file_size'] = Variable<int>(fileSize);
    map['checksum'] = Variable<String>(checksum);
    map['destination_type'] = Variable<String>(destinationType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    return map;
  }

  BackupHistoryCompanion toCompanion(bool nullToAbsent) {
    return BackupHistoryCompanion(
      id: Value(id),
      backupId: Value(backupId),
      backupType: Value(backupType),
      formatVersion: Value(formatVersion),
      schemaVersion: Value(schemaVersion),
      createdAt: Value(createdAt),
      fileSize: Value(fileSize),
      checksum: Value(checksum),
      destinationType: Value(destinationType),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory BackupHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupHistoryData(
      id: serializer.fromJson<String>(json['id']),
      backupId: serializer.fromJson<String>(json['backupId']),
      backupType: serializer.fromJson<String>(json['backupType']),
      formatVersion: serializer.fromJson<int>(json['formatVersion']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      checksum: serializer.fromJson<String>(json['checksum']),
      destinationType: serializer.fromJson<String>(json['destinationType']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<String?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'backupId': serializer.toJson<String>(backupId),
      'backupType': serializer.toJson<String>(backupType),
      'formatVersion': serializer.toJson<int>(formatVersion),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'createdAt': serializer.toJson<String>(createdAt),
      'fileSize': serializer.toJson<int>(fileSize),
      'checksum': serializer.toJson<String>(checksum),
      'destinationType': serializer.toJson<String>(destinationType),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<String?>(completedAt),
    };
  }

  BackupHistoryData copyWith(
          {String? id,
          String? backupId,
          String? backupType,
          int? formatVersion,
          int? schemaVersion,
          String? createdAt,
          int? fileSize,
          String? checksum,
          String? destinationType,
          String? status,
          Value<String?> completedAt = const Value.absent()}) =>
      BackupHistoryData(
        id: id ?? this.id,
        backupId: backupId ?? this.backupId,
        backupType: backupType ?? this.backupType,
        formatVersion: formatVersion ?? this.formatVersion,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        createdAt: createdAt ?? this.createdAt,
        fileSize: fileSize ?? this.fileSize,
        checksum: checksum ?? this.checksum,
        destinationType: destinationType ?? this.destinationType,
        status: status ?? this.status,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  BackupHistoryData copyWithCompanion(BackupHistoryCompanion data) {
    return BackupHistoryData(
      id: data.id.present ? data.id.value : this.id,
      backupId: data.backupId.present ? data.backupId.value : this.backupId,
      backupType:
          data.backupType.present ? data.backupType.value : this.backupType,
      formatVersion: data.formatVersion.present
          ? data.formatVersion.value
          : this.formatVersion,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      destinationType: data.destinationType.present
          ? data.destinationType.value
          : this.destinationType,
      status: data.status.present ? data.status.value : this.status,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryData(')
          ..write('id: $id, ')
          ..write('backupId: $backupId, ')
          ..write('backupType: $backupType, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
          ..write('destinationType: $destinationType, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      backupId,
      backupType,
      formatVersion,
      schemaVersion,
      createdAt,
      fileSize,
      checksum,
      destinationType,
      status,
      completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupHistoryData &&
          other.id == this.id &&
          other.backupId == this.backupId &&
          other.backupType == this.backupType &&
          other.formatVersion == this.formatVersion &&
          other.schemaVersion == this.schemaVersion &&
          other.createdAt == this.createdAt &&
          other.fileSize == this.fileSize &&
          other.checksum == this.checksum &&
          other.destinationType == this.destinationType &&
          other.status == this.status &&
          other.completedAt == this.completedAt);
}

class BackupHistoryCompanion extends UpdateCompanion<BackupHistoryData> {
  final Value<String> id;
  final Value<String> backupId;
  final Value<String> backupType;
  final Value<int> formatVersion;
  final Value<int> schemaVersion;
  final Value<String> createdAt;
  final Value<int> fileSize;
  final Value<String> checksum;
  final Value<String> destinationType;
  final Value<String> status;
  final Value<String?> completedAt;
  final Value<int> rowid;
  const BackupHistoryCompanion({
    this.id = const Value.absent(),
    this.backupId = const Value.absent(),
    this.backupType = const Value.absent(),
    this.formatVersion = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.destinationType = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupHistoryCompanion.insert({
    required String id,
    required String backupId,
    required String backupType,
    required int formatVersion,
    required int schemaVersion,
    required String createdAt,
    required int fileSize,
    required String checksum,
    required String destinationType,
    required String status,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        backupId = Value(backupId),
        backupType = Value(backupType),
        formatVersion = Value(formatVersion),
        schemaVersion = Value(schemaVersion),
        createdAt = Value(createdAt),
        fileSize = Value(fileSize),
        checksum = Value(checksum),
        destinationType = Value(destinationType),
        status = Value(status);
  static Insertable<BackupHistoryData> custom({
    Expression<String>? id,
    Expression<String>? backupId,
    Expression<String>? backupType,
    Expression<int>? formatVersion,
    Expression<int>? schemaVersion,
    Expression<String>? createdAt,
    Expression<int>? fileSize,
    Expression<String>? checksum,
    Expression<String>? destinationType,
    Expression<String>? status,
    Expression<String>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (backupId != null) 'backup_id': backupId,
      if (backupType != null) 'backup_type': backupType,
      if (formatVersion != null) 'format_version': formatVersion,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (fileSize != null) 'file_size': fileSize,
      if (checksum != null) 'checksum': checksum,
      if (destinationType != null) 'destination_type': destinationType,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupHistoryCompanion copyWith(
      {Value<String>? id,
      Value<String>? backupId,
      Value<String>? backupType,
      Value<int>? formatVersion,
      Value<int>? schemaVersion,
      Value<String>? createdAt,
      Value<int>? fileSize,
      Value<String>? checksum,
      Value<String>? destinationType,
      Value<String>? status,
      Value<String?>? completedAt,
      Value<int>? rowid}) {
    return BackupHistoryCompanion(
      id: id ?? this.id,
      backupId: backupId ?? this.backupId,
      backupType: backupType ?? this.backupType,
      formatVersion: formatVersion ?? this.formatVersion,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      checksum: checksum ?? this.checksum,
      destinationType: destinationType ?? this.destinationType,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (backupId.present) {
      map['backup_id'] = Variable<String>(backupId.value);
    }
    if (backupType.present) {
      map['backup_type'] = Variable<String>(backupType.value);
    }
    if (formatVersion.present) {
      map['format_version'] = Variable<int>(formatVersion.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (destinationType.present) {
      map['destination_type'] = Variable<String>(destinationType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupHistoryCompanion(')
          ..write('id: $id, ')
          ..write('backupId: $backupId, ')
          ..write('backupType: $backupType, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
          ..write('destinationType: $destinationType, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrackedItemsTable trackedItems = $TrackedItemsTable(this);
  late final $BillDetailsTable billDetails = $BillDetailsTable(this);
  late final $WarrantyDetailsTable warrantyDetails =
      $WarrantyDetailsTable(this);
  late final $InsuranceDetailsTable insuranceDetails =
      $InsuranceDetailsTable(this);
  late final $SubscriptionDetailsTable subscriptionDetails =
      $SubscriptionDetailsTable(this);
  late final $PurchaseDetailsTable purchaseDetails =
      $PurchaseDetailsTable(this);
  late final $GroceryDetailsTable groceryDetails = $GroceryDetailsTable(this);
  late final $DocumentDetailsTable documentDetails =
      $DocumentDetailsTable(this);
  late final $ItemDocumentsTable itemDocuments = $ItemDocumentsTable(this);
  late final $ReminderRulesTable reminderRules = $ReminderRulesTable(this);
  late final $ScheduledRemindersTable scheduledReminders =
      $ScheduledRemindersTable(this);
  late final $ItemHistoryTable itemHistory = $ItemHistoryTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BackupHistoryTable backupHistory = $BackupHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        trackedItems,
        billDetails,
        warrantyDetails,
        insuranceDetails,
        subscriptionDetails,
        purchaseDetails,
        groceryDetails,
        documentDetails,
        itemDocuments,
        reminderRules,
        scheduledReminders,
        itemHistory,
        appSettings,
        backupHistory
      ];
}

typedef $$TrackedItemsTableCreateCompanionBuilder = TrackedItemsCompanion
    Function({
  required String id,
  required String category,
  required String subcategory,
  required String title,
  Value<String?> description,
  Value<String?> purchaseDate,
  Value<String?> issueDate,
  Value<String?> startDate,
  Value<String?> dueDate,
  Value<String?> expiryDate,
  required String status,
  Value<String> metadataJson,
  Value<String?> previousItemId,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$TrackedItemsTableUpdateCompanionBuilder = TrackedItemsCompanion
    Function({
  Value<String> id,
  Value<String> category,
  Value<String> subcategory,
  Value<String> title,
  Value<String?> description,
  Value<String?> purchaseDate,
  Value<String?> issueDate,
  Value<String?> startDate,
  Value<String?> dueDate,
  Value<String?> expiryDate,
  Value<String> status,
  Value<String> metadataJson,
  Value<String?> previousItemId,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$TrackedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issueDate => $composableBuilder(
      column: $table.issueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousItemId => $composableBuilder(
      column: $table.previousItemId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TrackedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issueDate => $composableBuilder(
      column: $table.issueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousItemId => $composableBuilder(
      column: $table.previousItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<String> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<String> get previousItemId => $composableBuilder(
      column: $table.previousItemId, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TrackedItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackedItemsTable,
    TrackedItem,
    $$TrackedItemsTableFilterComposer,
    $$TrackedItemsTableOrderingComposer,
    $$TrackedItemsTableAnnotationComposer,
    $$TrackedItemsTableCreateCompanionBuilder,
    $$TrackedItemsTableUpdateCompanionBuilder,
    (
      TrackedItem,
      BaseReferences<_$AppDatabase, $TrackedItemsTable, TrackedItem>
    ),
    TrackedItem,
    PrefetchHooks Function()> {
  $$TrackedItemsTableTableManager(_$AppDatabase db, $TrackedItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subcategory = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> purchaseDate = const Value.absent(),
            Value<String?> issueDate = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String?> dueDate = const Value.absent(),
            Value<String?> expiryDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<String?> previousItemId = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackedItemsCompanion(
            id: id,
            category: category,
            subcategory: subcategory,
            title: title,
            description: description,
            purchaseDate: purchaseDate,
            issueDate: issueDate,
            startDate: startDate,
            dueDate: dueDate,
            expiryDate: expiryDate,
            status: status,
            metadataJson: metadataJson,
            previousItemId: previousItemId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String category,
            required String subcategory,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> purchaseDate = const Value.absent(),
            Value<String?> issueDate = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String?> dueDate = const Value.absent(),
            Value<String?> expiryDate = const Value.absent(),
            required String status,
            Value<String> metadataJson = const Value.absent(),
            Value<String?> previousItemId = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackedItemsCompanion.insert(
            id: id,
            category: category,
            subcategory: subcategory,
            title: title,
            description: description,
            purchaseDate: purchaseDate,
            issueDate: issueDate,
            startDate: startDate,
            dueDate: dueDate,
            expiryDate: expiryDate,
            status: status,
            metadataJson: metadataJson,
            previousItemId: previousItemId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrackedItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackedItemsTable,
    TrackedItem,
    $$TrackedItemsTableFilterComposer,
    $$TrackedItemsTableOrderingComposer,
    $$TrackedItemsTableAnnotationComposer,
    $$TrackedItemsTableCreateCompanionBuilder,
    $$TrackedItemsTableUpdateCompanionBuilder,
    (
      TrackedItem,
      BaseReferences<_$AppDatabase, $TrackedItemsTable, TrackedItem>
    ),
    TrackedItem,
    PrefetchHooks Function()>;
typedef $$BillDetailsTableCreateCompanionBuilder = BillDetailsCompanion
    Function({
  required String itemId,
  required String providerName,
  Value<String?> accountNumber,
  Value<double?> amount,
  Value<String> currencyCode,
  Value<String?> billingPeriod,
  Value<String> paymentStatus,
  Value<int> rowid,
});
typedef $$BillDetailsTableUpdateCompanionBuilder = BillDetailsCompanion
    Function({
  Value<String> itemId,
  Value<String> providerName,
  Value<String?> accountNumber,
  Value<double?> amount,
  Value<String> currencyCode,
  Value<String?> billingPeriod,
  Value<String> paymentStatus,
  Value<int> rowid,
});

class $$BillDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $BillDetailsTable> {
  $$BillDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerName => $composableBuilder(
      column: $table.providerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billingPeriod => $composableBuilder(
      column: $table.billingPeriod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => ColumnFilters(column));
}

class $$BillDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $BillDetailsTable> {
  $$BillDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerName => $composableBuilder(
      column: $table.providerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billingPeriod => $composableBuilder(
      column: $table.billingPeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));
}

class $$BillDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillDetailsTable> {
  $$BillDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get providerName => $composableBuilder(
      column: $table.providerName, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<String> get billingPeriod => $composableBuilder(
      column: $table.billingPeriod, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => column);
}

class $$BillDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BillDetailsTable,
    BillDetail,
    $$BillDetailsTableFilterComposer,
    $$BillDetailsTableOrderingComposer,
    $$BillDetailsTableAnnotationComposer,
    $$BillDetailsTableCreateCompanionBuilder,
    $$BillDetailsTableUpdateCompanionBuilder,
    (BillDetail, BaseReferences<_$AppDatabase, $BillDetailsTable, BillDetail>),
    BillDetail,
    PrefetchHooks Function()> {
  $$BillDetailsTableTableManager(_$AppDatabase db, $BillDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> providerName = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<double?> amount = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String?> billingPeriod = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BillDetailsCompanion(
            itemId: itemId,
            providerName: providerName,
            accountNumber: accountNumber,
            amount: amount,
            currencyCode: currencyCode,
            billingPeriod: billingPeriod,
            paymentStatus: paymentStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String providerName,
            Value<String?> accountNumber = const Value.absent(),
            Value<double?> amount = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String?> billingPeriod = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BillDetailsCompanion.insert(
            itemId: itemId,
            providerName: providerName,
            accountNumber: accountNumber,
            amount: amount,
            currencyCode: currencyCode,
            billingPeriod: billingPeriod,
            paymentStatus: paymentStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BillDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BillDetailsTable,
    BillDetail,
    $$BillDetailsTableFilterComposer,
    $$BillDetailsTableOrderingComposer,
    $$BillDetailsTableAnnotationComposer,
    $$BillDetailsTableCreateCompanionBuilder,
    $$BillDetailsTableUpdateCompanionBuilder,
    (BillDetail, BaseReferences<_$AppDatabase, $BillDetailsTable, BillDetail>),
    BillDetail,
    PrefetchHooks Function()>;
typedef $$WarrantyDetailsTableCreateCompanionBuilder = WarrantyDetailsCompanion
    Function({
  required String itemId,
  required String productName,
  Value<String?> seller,
  Value<double?> purchaseAmount,
  Value<int?> warrantyDurationMonths,
  Value<String?> warrantyProvider,
  Value<int> rowid,
});
typedef $$WarrantyDetailsTableUpdateCompanionBuilder = WarrantyDetailsCompanion
    Function({
  Value<String> itemId,
  Value<String> productName,
  Value<String?> seller,
  Value<double?> purchaseAmount,
  Value<int?> warrantyDurationMonths,
  Value<String?> warrantyProvider,
  Value<int> rowid,
});

class $$WarrantyDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $WarrantyDetailsTable> {
  $$WarrantyDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seller => $composableBuilder(
      column: $table.seller, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchaseAmount => $composableBuilder(
      column: $table.purchaseAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get warrantyDurationMonths => $composableBuilder(
      column: $table.warrantyDurationMonths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warrantyProvider => $composableBuilder(
      column: $table.warrantyProvider,
      builder: (column) => ColumnFilters(column));
}

class $$WarrantyDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $WarrantyDetailsTable> {
  $$WarrantyDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seller => $composableBuilder(
      column: $table.seller, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchaseAmount => $composableBuilder(
      column: $table.purchaseAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get warrantyDurationMonths => $composableBuilder(
      column: $table.warrantyDurationMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warrantyProvider => $composableBuilder(
      column: $table.warrantyProvider,
      builder: (column) => ColumnOrderings(column));
}

class $$WarrantyDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarrantyDetailsTable> {
  $$WarrantyDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get seller =>
      $composableBuilder(column: $table.seller, builder: (column) => column);

  GeneratedColumn<double> get purchaseAmount => $composableBuilder(
      column: $table.purchaseAmount, builder: (column) => column);

  GeneratedColumn<int> get warrantyDurationMonths => $composableBuilder(
      column: $table.warrantyDurationMonths, builder: (column) => column);

  GeneratedColumn<String> get warrantyProvider => $composableBuilder(
      column: $table.warrantyProvider, builder: (column) => column);
}

class $$WarrantyDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WarrantyDetailsTable,
    WarrantyDetail,
    $$WarrantyDetailsTableFilterComposer,
    $$WarrantyDetailsTableOrderingComposer,
    $$WarrantyDetailsTableAnnotationComposer,
    $$WarrantyDetailsTableCreateCompanionBuilder,
    $$WarrantyDetailsTableUpdateCompanionBuilder,
    (
      WarrantyDetail,
      BaseReferences<_$AppDatabase, $WarrantyDetailsTable, WarrantyDetail>
    ),
    WarrantyDetail,
    PrefetchHooks Function()> {
  $$WarrantyDetailsTableTableManager(
      _$AppDatabase db, $WarrantyDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarrantyDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarrantyDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarrantyDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String?> seller = const Value.absent(),
            Value<double?> purchaseAmount = const Value.absent(),
            Value<int?> warrantyDurationMonths = const Value.absent(),
            Value<String?> warrantyProvider = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarrantyDetailsCompanion(
            itemId: itemId,
            productName: productName,
            seller: seller,
            purchaseAmount: purchaseAmount,
            warrantyDurationMonths: warrantyDurationMonths,
            warrantyProvider: warrantyProvider,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String productName,
            Value<String?> seller = const Value.absent(),
            Value<double?> purchaseAmount = const Value.absent(),
            Value<int?> warrantyDurationMonths = const Value.absent(),
            Value<String?> warrantyProvider = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarrantyDetailsCompanion.insert(
            itemId: itemId,
            productName: productName,
            seller: seller,
            purchaseAmount: purchaseAmount,
            warrantyDurationMonths: warrantyDurationMonths,
            warrantyProvider: warrantyProvider,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WarrantyDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WarrantyDetailsTable,
    WarrantyDetail,
    $$WarrantyDetailsTableFilterComposer,
    $$WarrantyDetailsTableOrderingComposer,
    $$WarrantyDetailsTableAnnotationComposer,
    $$WarrantyDetailsTableCreateCompanionBuilder,
    $$WarrantyDetailsTableUpdateCompanionBuilder,
    (
      WarrantyDetail,
      BaseReferences<_$AppDatabase, $WarrantyDetailsTable, WarrantyDetail>
    ),
    WarrantyDetail,
    PrefetchHooks Function()>;
typedef $$InsuranceDetailsTableCreateCompanionBuilder
    = InsuranceDetailsCompanion Function({
  required String itemId,
  required String provider,
  Value<String?> policyNumber,
  Value<String?> vehicleNumber,
  Value<String?> coverageType,
  Value<double?> premiumAmount,
  Value<int> rowid,
});
typedef $$InsuranceDetailsTableUpdateCompanionBuilder
    = InsuranceDetailsCompanion Function({
  Value<String> itemId,
  Value<String> provider,
  Value<String?> policyNumber,
  Value<String?> vehicleNumber,
  Value<String?> coverageType,
  Value<double?> premiumAmount,
  Value<int> rowid,
});

class $$InsuranceDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $InsuranceDetailsTable> {
  $$InsuranceDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get policyNumber => $composableBuilder(
      column: $table.policyNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleNumber => $composableBuilder(
      column: $table.vehicleNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverageType => $composableBuilder(
      column: $table.coverageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get premiumAmount => $composableBuilder(
      column: $table.premiumAmount, builder: (column) => ColumnFilters(column));
}

class $$InsuranceDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $InsuranceDetailsTable> {
  $$InsuranceDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get policyNumber => $composableBuilder(
      column: $table.policyNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleNumber => $composableBuilder(
      column: $table.vehicleNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverageType => $composableBuilder(
      column: $table.coverageType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get premiumAmount => $composableBuilder(
      column: $table.premiumAmount,
      builder: (column) => ColumnOrderings(column));
}

class $$InsuranceDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsuranceDetailsTable> {
  $$InsuranceDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get policyNumber => $composableBuilder(
      column: $table.policyNumber, builder: (column) => column);

  GeneratedColumn<String> get vehicleNumber => $composableBuilder(
      column: $table.vehicleNumber, builder: (column) => column);

  GeneratedColumn<String> get coverageType => $composableBuilder(
      column: $table.coverageType, builder: (column) => column);

  GeneratedColumn<double> get premiumAmount => $composableBuilder(
      column: $table.premiumAmount, builder: (column) => column);
}

class $$InsuranceDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InsuranceDetailsTable,
    InsuranceDetail,
    $$InsuranceDetailsTableFilterComposer,
    $$InsuranceDetailsTableOrderingComposer,
    $$InsuranceDetailsTableAnnotationComposer,
    $$InsuranceDetailsTableCreateCompanionBuilder,
    $$InsuranceDetailsTableUpdateCompanionBuilder,
    (
      InsuranceDetail,
      BaseReferences<_$AppDatabase, $InsuranceDetailsTable, InsuranceDetail>
    ),
    InsuranceDetail,
    PrefetchHooks Function()> {
  $$InsuranceDetailsTableTableManager(
      _$AppDatabase db, $InsuranceDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsuranceDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsuranceDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsuranceDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String?> policyNumber = const Value.absent(),
            Value<String?> vehicleNumber = const Value.absent(),
            Value<String?> coverageType = const Value.absent(),
            Value<double?> premiumAmount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InsuranceDetailsCompanion(
            itemId: itemId,
            provider: provider,
            policyNumber: policyNumber,
            vehicleNumber: vehicleNumber,
            coverageType: coverageType,
            premiumAmount: premiumAmount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String provider,
            Value<String?> policyNumber = const Value.absent(),
            Value<String?> vehicleNumber = const Value.absent(),
            Value<String?> coverageType = const Value.absent(),
            Value<double?> premiumAmount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InsuranceDetailsCompanion.insert(
            itemId: itemId,
            provider: provider,
            policyNumber: policyNumber,
            vehicleNumber: vehicleNumber,
            coverageType: coverageType,
            premiumAmount: premiumAmount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InsuranceDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InsuranceDetailsTable,
    InsuranceDetail,
    $$InsuranceDetailsTableFilterComposer,
    $$InsuranceDetailsTableOrderingComposer,
    $$InsuranceDetailsTableAnnotationComposer,
    $$InsuranceDetailsTableCreateCompanionBuilder,
    $$InsuranceDetailsTableUpdateCompanionBuilder,
    (
      InsuranceDetail,
      BaseReferences<_$AppDatabase, $InsuranceDetailsTable, InsuranceDetail>
    ),
    InsuranceDetail,
    PrefetchHooks Function()>;
typedef $$SubscriptionDetailsTableCreateCompanionBuilder
    = SubscriptionDetailsCompanion Function({
  required String itemId,
  required String serviceName,
  required String billingCycle,
  Value<double?> amount,
  Value<bool> autoRenew,
  Value<int> rowid,
});
typedef $$SubscriptionDetailsTableUpdateCompanionBuilder
    = SubscriptionDetailsCompanion Function({
  Value<String> itemId,
  Value<String> serviceName,
  Value<String> billingCycle,
  Value<double?> amount,
  Value<bool> autoRenew,
  Value<int> rowid,
});

class $$SubscriptionDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionDetailsTable> {
  $$SubscriptionDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billingCycle => $composableBuilder(
      column: $table.billingCycle, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoRenew => $composableBuilder(
      column: $table.autoRenew, builder: (column) => ColumnFilters(column));
}

class $$SubscriptionDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionDetailsTable> {
  $$SubscriptionDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billingCycle => $composableBuilder(
      column: $table.billingCycle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoRenew => $composableBuilder(
      column: $table.autoRenew, builder: (column) => ColumnOrderings(column));
}

class $$SubscriptionDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionDetailsTable> {
  $$SubscriptionDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => column);

  GeneratedColumn<String> get billingCycle => $composableBuilder(
      column: $table.billingCycle, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get autoRenew =>
      $composableBuilder(column: $table.autoRenew, builder: (column) => column);
}

class $$SubscriptionDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubscriptionDetailsTable,
    SubscriptionDetail,
    $$SubscriptionDetailsTableFilterComposer,
    $$SubscriptionDetailsTableOrderingComposer,
    $$SubscriptionDetailsTableAnnotationComposer,
    $$SubscriptionDetailsTableCreateCompanionBuilder,
    $$SubscriptionDetailsTableUpdateCompanionBuilder,
    (
      SubscriptionDetail,
      BaseReferences<_$AppDatabase, $SubscriptionDetailsTable,
          SubscriptionDetail>
    ),
    SubscriptionDetail,
    PrefetchHooks Function()> {
  $$SubscriptionDetailsTableTableManager(
      _$AppDatabase db, $SubscriptionDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionDetailsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionDetailsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> serviceName = const Value.absent(),
            Value<String> billingCycle = const Value.absent(),
            Value<double?> amount = const Value.absent(),
            Value<bool> autoRenew = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionDetailsCompanion(
            itemId: itemId,
            serviceName: serviceName,
            billingCycle: billingCycle,
            amount: amount,
            autoRenew: autoRenew,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String serviceName,
            required String billingCycle,
            Value<double?> amount = const Value.absent(),
            Value<bool> autoRenew = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionDetailsCompanion.insert(
            itemId: itemId,
            serviceName: serviceName,
            billingCycle: billingCycle,
            amount: amount,
            autoRenew: autoRenew,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubscriptionDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubscriptionDetailsTable,
    SubscriptionDetail,
    $$SubscriptionDetailsTableFilterComposer,
    $$SubscriptionDetailsTableOrderingComposer,
    $$SubscriptionDetailsTableAnnotationComposer,
    $$SubscriptionDetailsTableCreateCompanionBuilder,
    $$SubscriptionDetailsTableUpdateCompanionBuilder,
    (
      SubscriptionDetail,
      BaseReferences<_$AppDatabase, $SubscriptionDetailsTable,
          SubscriptionDetail>
    ),
    SubscriptionDetail,
    PrefetchHooks Function()>;
typedef $$PurchaseDetailsTableCreateCompanionBuilder = PurchaseDetailsCompanion
    Function({
  required String itemId,
  required String productName,
  Value<String?> seller,
  Value<double?> purchaseAmount,
  Value<String?> returnDeadline,
  Value<int> rowid,
});
typedef $$PurchaseDetailsTableUpdateCompanionBuilder = PurchaseDetailsCompanion
    Function({
  Value<String> itemId,
  Value<String> productName,
  Value<String?> seller,
  Value<double?> purchaseAmount,
  Value<String?> returnDeadline,
  Value<int> rowid,
});

class $$PurchaseDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseDetailsTable> {
  $$PurchaseDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seller => $composableBuilder(
      column: $table.seller, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchaseAmount => $composableBuilder(
      column: $table.purchaseAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get returnDeadline => $composableBuilder(
      column: $table.returnDeadline,
      builder: (column) => ColumnFilters(column));
}

class $$PurchaseDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseDetailsTable> {
  $$PurchaseDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seller => $composableBuilder(
      column: $table.seller, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchaseAmount => $composableBuilder(
      column: $table.purchaseAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get returnDeadline => $composableBuilder(
      column: $table.returnDeadline,
      builder: (column) => ColumnOrderings(column));
}

class $$PurchaseDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseDetailsTable> {
  $$PurchaseDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get seller =>
      $composableBuilder(column: $table.seller, builder: (column) => column);

  GeneratedColumn<double> get purchaseAmount => $composableBuilder(
      column: $table.purchaseAmount, builder: (column) => column);

  GeneratedColumn<String> get returnDeadline => $composableBuilder(
      column: $table.returnDeadline, builder: (column) => column);
}

class $$PurchaseDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchaseDetailsTable,
    PurchaseDetail,
    $$PurchaseDetailsTableFilterComposer,
    $$PurchaseDetailsTableOrderingComposer,
    $$PurchaseDetailsTableAnnotationComposer,
    $$PurchaseDetailsTableCreateCompanionBuilder,
    $$PurchaseDetailsTableUpdateCompanionBuilder,
    (
      PurchaseDetail,
      BaseReferences<_$AppDatabase, $PurchaseDetailsTable, PurchaseDetail>
    ),
    PurchaseDetail,
    PrefetchHooks Function()> {
  $$PurchaseDetailsTableTableManager(
      _$AppDatabase db, $PurchaseDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String?> seller = const Value.absent(),
            Value<double?> purchaseAmount = const Value.absent(),
            Value<String?> returnDeadline = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseDetailsCompanion(
            itemId: itemId,
            productName: productName,
            seller: seller,
            purchaseAmount: purchaseAmount,
            returnDeadline: returnDeadline,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String productName,
            Value<String?> seller = const Value.absent(),
            Value<double?> purchaseAmount = const Value.absent(),
            Value<String?> returnDeadline = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PurchaseDetailsCompanion.insert(
            itemId: itemId,
            productName: productName,
            seller: seller,
            purchaseAmount: purchaseAmount,
            returnDeadline: returnDeadline,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchaseDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchaseDetailsTable,
    PurchaseDetail,
    $$PurchaseDetailsTableFilterComposer,
    $$PurchaseDetailsTableOrderingComposer,
    $$PurchaseDetailsTableAnnotationComposer,
    $$PurchaseDetailsTableCreateCompanionBuilder,
    $$PurchaseDetailsTableUpdateCompanionBuilder,
    (
      PurchaseDetail,
      BaseReferences<_$AppDatabase, $PurchaseDetailsTable, PurchaseDetail>
    ),
    PurchaseDetail,
    PrefetchHooks Function()>;
typedef $$GroceryDetailsTableCreateCompanionBuilder = GroceryDetailsCompanion
    Function({
  required String itemId,
  required String productName,
  Value<String?> batchNumber,
  Value<String> storageLocation,
  Value<double> quantityRemaining,
  Value<String> quantityUnit,
  Value<int> rowid,
});
typedef $$GroceryDetailsTableUpdateCompanionBuilder = GroceryDetailsCompanion
    Function({
  Value<String> itemId,
  Value<String> productName,
  Value<String?> batchNumber,
  Value<String> storageLocation,
  Value<double> quantityRemaining,
  Value<String> quantityUnit,
  Value<int> rowid,
});

class $$GroceryDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $GroceryDetailsTable> {
  $$GroceryDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageLocation => $composableBuilder(
      column: $table.storageLocation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityRemaining => $composableBuilder(
      column: $table.quantityRemaining,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantityUnit => $composableBuilder(
      column: $table.quantityUnit, builder: (column) => ColumnFilters(column));
}

class $$GroceryDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroceryDetailsTable> {
  $$GroceryDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageLocation => $composableBuilder(
      column: $table.storageLocation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityRemaining => $composableBuilder(
      column: $table.quantityRemaining,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
      column: $table.quantityUnit,
      builder: (column) => ColumnOrderings(column));
}

class $$GroceryDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroceryDetailsTable> {
  $$GroceryDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => column);

  GeneratedColumn<String> get storageLocation => $composableBuilder(
      column: $table.storageLocation, builder: (column) => column);

  GeneratedColumn<double> get quantityRemaining => $composableBuilder(
      column: $table.quantityRemaining, builder: (column) => column);

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
      column: $table.quantityUnit, builder: (column) => column);
}

class $$GroceryDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroceryDetailsTable,
    GroceryDetail,
    $$GroceryDetailsTableFilterComposer,
    $$GroceryDetailsTableOrderingComposer,
    $$GroceryDetailsTableAnnotationComposer,
    $$GroceryDetailsTableCreateCompanionBuilder,
    $$GroceryDetailsTableUpdateCompanionBuilder,
    (
      GroceryDetail,
      BaseReferences<_$AppDatabase, $GroceryDetailsTable, GroceryDetail>
    ),
    GroceryDetail,
    PrefetchHooks Function()> {
  $$GroceryDetailsTableTableManager(
      _$AppDatabase db, $GroceryDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroceryDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroceryDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroceryDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<String?> batchNumber = const Value.absent(),
            Value<String> storageLocation = const Value.absent(),
            Value<double> quantityRemaining = const Value.absent(),
            Value<String> quantityUnit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroceryDetailsCompanion(
            itemId: itemId,
            productName: productName,
            batchNumber: batchNumber,
            storageLocation: storageLocation,
            quantityRemaining: quantityRemaining,
            quantityUnit: quantityUnit,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            required String productName,
            Value<String?> batchNumber = const Value.absent(),
            Value<String> storageLocation = const Value.absent(),
            Value<double> quantityRemaining = const Value.absent(),
            Value<String> quantityUnit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroceryDetailsCompanion.insert(
            itemId: itemId,
            productName: productName,
            batchNumber: batchNumber,
            storageLocation: storageLocation,
            quantityRemaining: quantityRemaining,
            quantityUnit: quantityUnit,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GroceryDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroceryDetailsTable,
    GroceryDetail,
    $$GroceryDetailsTableFilterComposer,
    $$GroceryDetailsTableOrderingComposer,
    $$GroceryDetailsTableAnnotationComposer,
    $$GroceryDetailsTableCreateCompanionBuilder,
    $$GroceryDetailsTableUpdateCompanionBuilder,
    (
      GroceryDetail,
      BaseReferences<_$AppDatabase, $GroceryDetailsTable, GroceryDetail>
    ),
    GroceryDetail,
    PrefetchHooks Function()>;
typedef $$DocumentDetailsTableCreateCompanionBuilder = DocumentDetailsCompanion
    Function({
  required String itemId,
  Value<String?> documentNumber,
  Value<String?> issuingAuthority,
  required String documentType,
  Value<int> rowid,
});
typedef $$DocumentDetailsTableUpdateCompanionBuilder = DocumentDetailsCompanion
    Function({
  Value<String> itemId,
  Value<String?> documentNumber,
  Value<String?> issuingAuthority,
  Value<String> documentType,
  Value<int> rowid,
});

class $$DocumentDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentDetailsTable> {
  $$DocumentDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentNumber => $composableBuilder(
      column: $table.documentNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issuingAuthority => $composableBuilder(
      column: $table.issuingAuthority,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentType => $composableBuilder(
      column: $table.documentType, builder: (column) => ColumnFilters(column));
}

class $$DocumentDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentDetailsTable> {
  $$DocumentDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentNumber => $composableBuilder(
      column: $table.documentNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issuingAuthority => $composableBuilder(
      column: $table.issuingAuthority,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentType => $composableBuilder(
      column: $table.documentType,
      builder: (column) => ColumnOrderings(column));
}

class $$DocumentDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentDetailsTable> {
  $$DocumentDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get documentNumber => $composableBuilder(
      column: $table.documentNumber, builder: (column) => column);

  GeneratedColumn<String> get issuingAuthority => $composableBuilder(
      column: $table.issuingAuthority, builder: (column) => column);

  GeneratedColumn<String> get documentType => $composableBuilder(
      column: $table.documentType, builder: (column) => column);
}

class $$DocumentDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DocumentDetailsTable,
    DocumentDetail,
    $$DocumentDetailsTableFilterComposer,
    $$DocumentDetailsTableOrderingComposer,
    $$DocumentDetailsTableAnnotationComposer,
    $$DocumentDetailsTableCreateCompanionBuilder,
    $$DocumentDetailsTableUpdateCompanionBuilder,
    (
      DocumentDetail,
      BaseReferences<_$AppDatabase, $DocumentDetailsTable, DocumentDetail>
    ),
    DocumentDetail,
    PrefetchHooks Function()> {
  $$DocumentDetailsTableTableManager(
      _$AppDatabase db, $DocumentDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String?> documentNumber = const Value.absent(),
            Value<String?> issuingAuthority = const Value.absent(),
            Value<String> documentType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentDetailsCompanion(
            itemId: itemId,
            documentNumber: documentNumber,
            issuingAuthority: issuingAuthority,
            documentType: documentType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemId,
            Value<String?> documentNumber = const Value.absent(),
            Value<String?> issuingAuthority = const Value.absent(),
            required String documentType,
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentDetailsCompanion.insert(
            itemId: itemId,
            documentNumber: documentNumber,
            issuingAuthority: issuingAuthority,
            documentType: documentType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DocumentDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DocumentDetailsTable,
    DocumentDetail,
    $$DocumentDetailsTableFilterComposer,
    $$DocumentDetailsTableOrderingComposer,
    $$DocumentDetailsTableAnnotationComposer,
    $$DocumentDetailsTableCreateCompanionBuilder,
    $$DocumentDetailsTableUpdateCompanionBuilder,
    (
      DocumentDetail,
      BaseReferences<_$AppDatabase, $DocumentDetailsTable, DocumentDetail>
    ),
    DocumentDetail,
    PrefetchHooks Function()>;
typedef $$ItemDocumentsTableCreateCompanionBuilder = ItemDocumentsCompanion
    Function({
  required String id,
  Value<String?> itemId,
  required String fileName,
  required String relativePath,
  required String mimeType,
  required int fileSize,
  required String checksumSha256,
  required String source,
  required String createdAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});
typedef $$ItemDocumentsTableUpdateCompanionBuilder = ItemDocumentsCompanion
    Function({
  Value<String> id,
  Value<String?> itemId,
  Value<String> fileName,
  Value<String> relativePath,
  Value<String> mimeType,
  Value<int> fileSize,
  Value<String> checksumSha256,
  Value<String> source,
  Value<String> createdAt,
  Value<String?> deletedAt,
  Value<int> rowid,
});

class $$ItemDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemDocumentsTable> {
  $$ItemDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ItemDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemDocumentsTable> {
  $$ItemDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relativePath => $composableBuilder(
      column: $table.relativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemDocumentsTable> {
  $$ItemDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ItemDocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemDocumentsTable,
    ItemDocument,
    $$ItemDocumentsTableFilterComposer,
    $$ItemDocumentsTableOrderingComposer,
    $$ItemDocumentsTableAnnotationComposer,
    $$ItemDocumentsTableCreateCompanionBuilder,
    $$ItemDocumentsTableUpdateCompanionBuilder,
    (
      ItemDocument,
      BaseReferences<_$AppDatabase, $ItemDocumentsTable, ItemDocument>
    ),
    ItemDocument,
    PrefetchHooks Function()> {
  $$ItemDocumentsTableTableManager(_$AppDatabase db, $ItemDocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> itemId = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String> relativePath = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<String> checksumSha256 = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemDocumentsCompanion(
            id: id,
            itemId: itemId,
            fileName: fileName,
            relativePath: relativePath,
            mimeType: mimeType,
            fileSize: fileSize,
            checksumSha256: checksumSha256,
            source: source,
            createdAt: createdAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> itemId = const Value.absent(),
            required String fileName,
            required String relativePath,
            required String mimeType,
            required int fileSize,
            required String checksumSha256,
            required String source,
            required String createdAt,
            Value<String?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemDocumentsCompanion.insert(
            id: id,
            itemId: itemId,
            fileName: fileName,
            relativePath: relativePath,
            mimeType: mimeType,
            fileSize: fileSize,
            checksumSha256: checksumSha256,
            source: source,
            createdAt: createdAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemDocumentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemDocumentsTable,
    ItemDocument,
    $$ItemDocumentsTableFilterComposer,
    $$ItemDocumentsTableOrderingComposer,
    $$ItemDocumentsTableAnnotationComposer,
    $$ItemDocumentsTableCreateCompanionBuilder,
    $$ItemDocumentsTableUpdateCompanionBuilder,
    (
      ItemDocument,
      BaseReferences<_$AppDatabase, $ItemDocumentsTable, ItemDocument>
    ),
    ItemDocument,
    PrefetchHooks Function()>;
typedef $$ReminderRulesTableCreateCompanionBuilder = ReminderRulesCompanion
    Function({
  required String id,
  required String itemId,
  required int offsetDays,
  Value<String> reminderTime,
  Value<bool> isEnabled,
  required String createdAt,
  Value<int> rowid,
});
typedef $$ReminderRulesTableUpdateCompanionBuilder = ReminderRulesCompanion
    Function({
  Value<String> id,
  Value<String> itemId,
  Value<int> offsetDays,
  Value<String> reminderTime,
  Value<bool> isEnabled,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$ReminderRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get offsetDays => $composableBuilder(
      column: $table.offsetDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderTime => $composableBuilder(
      column: $table.reminderTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ReminderRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get offsetDays => $composableBuilder(
      column: $table.offsetDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderTime => $composableBuilder(
      column: $table.reminderTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ReminderRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get offsetDays => $composableBuilder(
      column: $table.offsetDays, builder: (column) => column);

  GeneratedColumn<String> get reminderTime => $composableBuilder(
      column: $table.reminderTime, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReminderRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReminderRulesTable,
    ReminderRule,
    $$ReminderRulesTableFilterComposer,
    $$ReminderRulesTableOrderingComposer,
    $$ReminderRulesTableAnnotationComposer,
    $$ReminderRulesTableCreateCompanionBuilder,
    $$ReminderRulesTableUpdateCompanionBuilder,
    (
      ReminderRule,
      BaseReferences<_$AppDatabase, $ReminderRulesTable, ReminderRule>
    ),
    ReminderRule,
    PrefetchHooks Function()> {
  $$ReminderRulesTableTableManager(_$AppDatabase db, $ReminderRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<int> offsetDays = const Value.absent(),
            Value<String> reminderTime = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReminderRulesCompanion(
            id: id,
            itemId: itemId,
            offsetDays: offsetDays,
            reminderTime: reminderTime,
            isEnabled: isEnabled,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            required int offsetDays,
            Value<String> reminderTime = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReminderRulesCompanion.insert(
            id: id,
            itemId: itemId,
            offsetDays: offsetDays,
            reminderTime: reminderTime,
            isEnabled: isEnabled,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReminderRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReminderRulesTable,
    ReminderRule,
    $$ReminderRulesTableFilterComposer,
    $$ReminderRulesTableOrderingComposer,
    $$ReminderRulesTableAnnotationComposer,
    $$ReminderRulesTableCreateCompanionBuilder,
    $$ReminderRulesTableUpdateCompanionBuilder,
    (
      ReminderRule,
      BaseReferences<_$AppDatabase, $ReminderRulesTable, ReminderRule>
    ),
    ReminderRule,
    PrefetchHooks Function()>;
typedef $$ScheduledRemindersTableCreateCompanionBuilder
    = ScheduledRemindersCompanion Function({
  required String id,
  required String itemId,
  required String reminderRuleId,
  required int notificationId,
  required String scheduledAt,
  required String status,
  required String createdAt,
  Value<int> rowid,
});
typedef $$ScheduledRemindersTableUpdateCompanionBuilder
    = ScheduledRemindersCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String> reminderRuleId,
  Value<int> notificationId,
  Value<String> scheduledAt,
  Value<String> status,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$ScheduledRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledRemindersTable> {
  $$ScheduledRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderRuleId => $composableBuilder(
      column: $table.reminderRuleId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ScheduledRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledRemindersTable> {
  $$ScheduledRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderRuleId => $composableBuilder(
      column: $table.reminderRuleId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ScheduledRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledRemindersTable> {
  $$ScheduledRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get reminderRuleId => $composableBuilder(
      column: $table.reminderRuleId, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
      column: $table.notificationId, builder: (column) => column);

  GeneratedColumn<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScheduledRemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduledRemindersTable,
    ScheduledReminder,
    $$ScheduledRemindersTableFilterComposer,
    $$ScheduledRemindersTableOrderingComposer,
    $$ScheduledRemindersTableAnnotationComposer,
    $$ScheduledRemindersTableCreateCompanionBuilder,
    $$ScheduledRemindersTableUpdateCompanionBuilder,
    (
      ScheduledReminder,
      BaseReferences<_$AppDatabase, $ScheduledRemindersTable, ScheduledReminder>
    ),
    ScheduledReminder,
    PrefetchHooks Function()> {
  $$ScheduledRemindersTableTableManager(
      _$AppDatabase db, $ScheduledRemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledRemindersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> reminderRuleId = const Value.absent(),
            Value<int> notificationId = const Value.absent(),
            Value<String> scheduledAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduledRemindersCompanion(
            id: id,
            itemId: itemId,
            reminderRuleId: reminderRuleId,
            notificationId: notificationId,
            scheduledAt: scheduledAt,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            required String reminderRuleId,
            required int notificationId,
            required String scheduledAt,
            required String status,
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduledRemindersCompanion.insert(
            id: id,
            itemId: itemId,
            reminderRuleId: reminderRuleId,
            notificationId: notificationId,
            scheduledAt: scheduledAt,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScheduledRemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScheduledRemindersTable,
    ScheduledReminder,
    $$ScheduledRemindersTableFilterComposer,
    $$ScheduledRemindersTableOrderingComposer,
    $$ScheduledRemindersTableAnnotationComposer,
    $$ScheduledRemindersTableCreateCompanionBuilder,
    $$ScheduledRemindersTableUpdateCompanionBuilder,
    (
      ScheduledReminder,
      BaseReferences<_$AppDatabase, $ScheduledRemindersTable, ScheduledReminder>
    ),
    ScheduledReminder,
    PrefetchHooks Function()>;
typedef $$ItemHistoryTableCreateCompanionBuilder = ItemHistoryCompanion
    Function({
  required String id,
  required String itemId,
  required String eventType,
  Value<String> eventDataJson,
  required String eventAt,
  Value<int> rowid,
});
typedef $$ItemHistoryTableUpdateCompanionBuilder = ItemHistoryCompanion
    Function({
  Value<String> id,
  Value<String> itemId,
  Value<String> eventType,
  Value<String> eventDataJson,
  Value<String> eventAt,
  Value<int> rowid,
});

class $$ItemHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventDataJson => $composableBuilder(
      column: $table.eventDataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventAt => $composableBuilder(
      column: $table.eventAt, builder: (column) => ColumnFilters(column));
}

class $$ItemHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventDataJson => $composableBuilder(
      column: $table.eventDataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventAt => $composableBuilder(
      column: $table.eventAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get eventDataJson => $composableBuilder(
      column: $table.eventDataJson, builder: (column) => column);

  GeneratedColumn<String> get eventAt =>
      $composableBuilder(column: $table.eventAt, builder: (column) => column);
}

class $$ItemHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemHistoryTable,
    ItemHistoryData,
    $$ItemHistoryTableFilterComposer,
    $$ItemHistoryTableOrderingComposer,
    $$ItemHistoryTableAnnotationComposer,
    $$ItemHistoryTableCreateCompanionBuilder,
    $$ItemHistoryTableUpdateCompanionBuilder,
    (
      ItemHistoryData,
      BaseReferences<_$AppDatabase, $ItemHistoryTable, ItemHistoryData>
    ),
    ItemHistoryData,
    PrefetchHooks Function()> {
  $$ItemHistoryTableTableManager(_$AppDatabase db, $ItemHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> eventDataJson = const Value.absent(),
            Value<String> eventAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemHistoryCompanion(
            id: id,
            itemId: itemId,
            eventType: eventType,
            eventDataJson: eventDataJson,
            eventAt: eventAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            required String eventType,
            Value<String> eventDataJson = const Value.absent(),
            required String eventAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemHistoryCompanion.insert(
            id: id,
            itemId: itemId,
            eventType: eventType,
            eventDataJson: eventDataJson,
            eventAt: eventAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemHistoryTable,
    ItemHistoryData,
    $$ItemHistoryTableFilterComposer,
    $$ItemHistoryTableOrderingComposer,
    $$ItemHistoryTableAnnotationComposer,
    $$ItemHistoryTableCreateCompanionBuilder,
    $$ItemHistoryTableUpdateCompanionBuilder,
    (
      ItemHistoryData,
      BaseReferences<_$AppDatabase, $ItemHistoryTable, ItemHistoryData>
    ),
    ItemHistoryData,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String id,
  required String settingKey,
  required String settingValue,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> id,
  Value<String> settingKey,
  Value<String> settingValue,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingValue => $composableBuilder(
      column: $table.settingValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingValue => $composableBuilder(
      column: $table.settingValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => column);

  GeneratedColumn<String> get settingValue => $composableBuilder(
      column: $table.settingValue, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> settingKey = const Value.absent(),
            Value<String> settingValue = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            id: id,
            settingKey: settingKey,
            settingValue: settingValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String settingKey,
            required String settingValue,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            id: id,
            settingKey: settingKey,
            settingValue: settingValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;
typedef $$BackupHistoryTableCreateCompanionBuilder = BackupHistoryCompanion
    Function({
  required String id,
  required String backupId,
  required String backupType,
  required int formatVersion,
  required int schemaVersion,
  required String createdAt,
  required int fileSize,
  required String checksum,
  required String destinationType,
  required String status,
  Value<String?> completedAt,
  Value<int> rowid,
});
typedef $$BackupHistoryTableUpdateCompanionBuilder = BackupHistoryCompanion
    Function({
  Value<String> id,
  Value<String> backupId,
  Value<String> backupType,
  Value<int> formatVersion,
  Value<int> schemaVersion,
  Value<String> createdAt,
  Value<int> fileSize,
  Value<String> checksum,
  Value<String> destinationType,
  Value<String> status,
  Value<String?> completedAt,
  Value<int> rowid,
});

class $$BackupHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupId => $composableBuilder(
      column: $table.backupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupType => $composableBuilder(
      column: $table.backupType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get formatVersion => $composableBuilder(
      column: $table.formatVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationType => $composableBuilder(
      column: $table.destinationType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$BackupHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupId => $composableBuilder(
      column: $table.backupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupType => $composableBuilder(
      column: $table.backupType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get formatVersion => $composableBuilder(
      column: $table.formatVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationType => $composableBuilder(
      column: $table.destinationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$BackupHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupHistoryTable> {
  $$BackupHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get backupId =>
      $composableBuilder(column: $table.backupId, builder: (column) => column);

  GeneratedColumn<String> get backupType => $composableBuilder(
      column: $table.backupType, builder: (column) => column);

  GeneratedColumn<int> get formatVersion => $composableBuilder(
      column: $table.formatVersion, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get destinationType => $composableBuilder(
      column: $table.destinationType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$BackupHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BackupHistoryTable,
    BackupHistoryData,
    $$BackupHistoryTableFilterComposer,
    $$BackupHistoryTableOrderingComposer,
    $$BackupHistoryTableAnnotationComposer,
    $$BackupHistoryTableCreateCompanionBuilder,
    $$BackupHistoryTableUpdateCompanionBuilder,
    (
      BackupHistoryData,
      BaseReferences<_$AppDatabase, $BackupHistoryTable, BackupHistoryData>
    ),
    BackupHistoryData,
    PrefetchHooks Function()> {
  $$BackupHistoryTableTableManager(_$AppDatabase db, $BackupHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> backupId = const Value.absent(),
            Value<String> backupType = const Value.absent(),
            Value<int> formatVersion = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<String> checksum = const Value.absent(),
            Value<String> destinationType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupHistoryCompanion(
            id: id,
            backupId: backupId,
            backupType: backupType,
            formatVersion: formatVersion,
            schemaVersion: schemaVersion,
            createdAt: createdAt,
            fileSize: fileSize,
            checksum: checksum,
            destinationType: destinationType,
            status: status,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String backupId,
            required String backupType,
            required int formatVersion,
            required int schemaVersion,
            required String createdAt,
            required int fileSize,
            required String checksum,
            required String destinationType,
            required String status,
            Value<String?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupHistoryCompanion.insert(
            id: id,
            backupId: backupId,
            backupType: backupType,
            formatVersion: formatVersion,
            schemaVersion: schemaVersion,
            createdAt: createdAt,
            fileSize: fileSize,
            checksum: checksum,
            destinationType: destinationType,
            status: status,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BackupHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BackupHistoryTable,
    BackupHistoryData,
    $$BackupHistoryTableFilterComposer,
    $$BackupHistoryTableOrderingComposer,
    $$BackupHistoryTableAnnotationComposer,
    $$BackupHistoryTableCreateCompanionBuilder,
    $$BackupHistoryTableUpdateCompanionBuilder,
    (
      BackupHistoryData,
      BaseReferences<_$AppDatabase, $BackupHistoryTable, BackupHistoryData>
    ),
    BackupHistoryData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrackedItemsTableTableManager get trackedItems =>
      $$TrackedItemsTableTableManager(_db, _db.trackedItems);
  $$BillDetailsTableTableManager get billDetails =>
      $$BillDetailsTableTableManager(_db, _db.billDetails);
  $$WarrantyDetailsTableTableManager get warrantyDetails =>
      $$WarrantyDetailsTableTableManager(_db, _db.warrantyDetails);
  $$InsuranceDetailsTableTableManager get insuranceDetails =>
      $$InsuranceDetailsTableTableManager(_db, _db.insuranceDetails);
  $$SubscriptionDetailsTableTableManager get subscriptionDetails =>
      $$SubscriptionDetailsTableTableManager(_db, _db.subscriptionDetails);
  $$PurchaseDetailsTableTableManager get purchaseDetails =>
      $$PurchaseDetailsTableTableManager(_db, _db.purchaseDetails);
  $$GroceryDetailsTableTableManager get groceryDetails =>
      $$GroceryDetailsTableTableManager(_db, _db.groceryDetails);
  $$DocumentDetailsTableTableManager get documentDetails =>
      $$DocumentDetailsTableTableManager(_db, _db.documentDetails);
  $$ItemDocumentsTableTableManager get itemDocuments =>
      $$ItemDocumentsTableTableManager(_db, _db.itemDocuments);
  $$ReminderRulesTableTableManager get reminderRules =>
      $$ReminderRulesTableTableManager(_db, _db.reminderRules);
  $$ScheduledRemindersTableTableManager get scheduledReminders =>
      $$ScheduledRemindersTableTableManager(_db, _db.scheduledReminders);
  $$ItemHistoryTableTableManager get itemHistory =>
      $$ItemHistoryTableTableManager(_db, _db.itemHistory);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BackupHistoryTableTableManager get backupHistory =>
      $$BackupHistoryTableTableManager(_db, _db.backupHistory);
}
