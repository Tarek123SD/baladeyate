// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Baladeyate';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get navDonations => 'Donations';

  @override
  String get navTrack => 'Track';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get signupPasswordRequired => 'Password is required';

  @override
  String get signupPasswordMinLength =>
      'Password must be at least 8 characters';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get loginTitle => 'Login';

  @override
  String get signupTitle => 'Sign Up';
}
