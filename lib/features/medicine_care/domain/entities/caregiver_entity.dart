import '../../../../core/database/app_database.dart';

class CaregiverEntity {
  final CaregiverContact contact;

  const CaregiverEntity({required this.contact});

  String get id => contact.id;
  String get name => contact.name;
  String get relationship => contact.relationship;
  String get phoneOrEmail => contact.phoneOrEmail;
  int get gracePeriodMinutes => contact.gracePeriodMinutes;
  bool get notifyUnconfirmed => contact.notifyUnconfirmed;
  String get createdAt => contact.createdAt;
}
