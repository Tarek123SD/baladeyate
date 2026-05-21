// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بلديتي';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get navDonations => 'التبرعات';

  @override
  String get navTrack => 'الشكاوي';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get signupPasswordRequired => 'كلمة السر مطلوبة';

  @override
  String get signupPasswordMinLength =>
      'يجب أن تكون كلمة السر 8 أحرف على الأقل';

  @override
  String get invalidEmail => 'صيغة البريد الإلكتروني غير صحيحة';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get signupTitle => 'إنشاء حساب';
}
