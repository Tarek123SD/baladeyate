/// Centralized form validation helpers.
class Validator {
  Validator._();

  static String? required(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'هذا الحقل مطلوب';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
    }
    return null;
  }

  static String? signupPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة السر مطلوبة';
    }
    if (value.length < 8) {
      return 'يجب أن تكون كلمة السر 8 أحرف على الأقل';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (!value.contains('@')) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  static String? nationalNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرقم الوطني مطلوب';
    }
    if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
      return 'يجب أن يتكون الرقم الوطني من 10 أو 11 رقم';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 9) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final passwordError = signupPassword(value);
    if (passwordError != null) {
      return passwordError;
    }
    if (value != password) {
      return 'كلمتا السر غير متطابقتين';
    }
    return null;
  }
}
