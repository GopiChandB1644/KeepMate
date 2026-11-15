import '../domain/entities/medicine_entity.dart';

enum MedicineVoiceLanguage {
  english('en-US', 'English', '🇺🇸'),
  telugu('te-IN', 'తెలుగు (Telugu)', '🇮🇳'),
  hindi('hi-IN', 'हिंदी (Hindi)', '🇮🇳');

  final String locale;
  final String label;
  final String flag;
  const MedicineVoiceLanguage(this.locale, this.label, this.flag);

  static MedicineVoiceLanguage fromLocale(String locale) {
    return MedicineVoiceLanguage.values.firstWhere(
      (e) => e.locale.startsWith(locale.substring(0, 2)),
      orElse: () => MedicineVoiceLanguage.english,
    );
  }
}

class MedicineVoiceService {
  const MedicineVoiceService();

  /// Generates natural spoken reminder text in the selected regional language
  String getReminderSpeechText({
    required String medicineName,
    required String dosage,
    MealInstruction? instruction,
    MedicineVoiceLanguage language = MedicineVoiceLanguage.english,
  }) {
    final meal = instruction ?? MealInstruction.afterFood;

    switch (language) {
      case MedicineVoiceLanguage.telugu:
        final mealText = switch (meal) {
          MealInstruction.beforeFood => 'భోజనానికి ముందు',
          MealInstruction.afterFood => 'భోజనం తర్వాత',
          MealInstruction.withFood => 'ఆహారంతో పాటు',
          MealInstruction.emptyStomach => 'ఖాళీ కడుపుతో',
          MealInstruction.anytime => '',
        };
        return 'మందులు వేసుకునే సమయం అయింది. $medicineName $dosage $mealText వేసుకోండి. దయచేసి డాక్టర్ ప్రిస్క్రిప్షన్ పాటించండి.';

      case MedicineVoiceLanguage.hindi:
        final mealText = switch (meal) {
          MealInstruction.beforeFood => 'खाने से पहले',
          MealInstruction.afterFood => 'खाने के बाद',
          MealInstruction.withFood => 'खाने के साथ',
          MealInstruction.emptyStomach => 'खाली पेट',
          MealInstruction.anytime => '',
        };
        return 'दवाई लेने का समय हो गया है। $medicineName $dosage $mealText लें। कृपया डॉक्टर की सलाह के अनुसार दवाई लें।';

      case MedicineVoiceLanguage.english:
        final mealText = switch (meal) {
          MealInstruction.beforeFood => 'before food',
          MealInstruction.afterFood => 'after food',
          MealInstruction.withFood => 'with food',
          MealInstruction.emptyStomach => 'on an empty stomach',
          MealInstruction.anytime => '',
        };
        return 'Time for your medicine: $medicineName, $dosage $mealText. Please take according to your prescription.';
    }
  }

  /// Generates respectful, non-accusatory notice for caregivers
  String getCaregiverAlertMessage({
    required String personName,
    required String medicineName,
    required String dosage,
    required String scheduledTime,
    int gracePeriodMinutes = 30,
  }) {
    return 'Medication Update: Dose not confirmed.\n'
        '$personName has an unconfirmed dose of $medicineName ($dosage) scheduled at $scheduledTime '
        '(past $gracePeriodMinutes mins grace period).\n'
        'Please check gently with $personName. (Note: A missed notification is not proof that medicine was not taken).';
  }
}
