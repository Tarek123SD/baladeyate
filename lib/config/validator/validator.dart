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
}
