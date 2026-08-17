import 'package:dio/dio.dart';

class ApiResponseParser {
  ApiResponseParser._();

  static final RegExp _arabicPattern = RegExp(r'[\u0600-\u06FF]');
  static final RegExp _latinPattern = RegExp(r'[A-Za-z]');

  static const Map<String, String> _knownEnglishMessages = {
    'invalid credentials.': 'بيانات الدخول غير صحيحة.',
    'invalid credentials': 'بيانات الدخول غير صحيحة.',
    'unauthenticated.': 'يجب تسجيل الدخول للوصول إلى هذا المورد.',
    'unauthenticated': 'يجب تسجيل الدخول للوصول إلى هذا المورد.',
    'validation failed.': 'يرجى التحقق من البيانات المدخلة.',
    'validation failed': 'يرجى التحقق من البيانات المدخلة.',
    'the given data was invalid.': 'يرجى التحقق من البيانات المدخلة.',
    'you are not authorized to access this resource.':
        'ليس لديك صلاحية للوصول إلى هذا المورد.',
    'this action is unauthorized.': 'ليس لديك صلاحية للوصول إلى هذا المورد.',
    'resource not found.': 'المورد المطلوب غير موجود.',
    'a record with this value already exists.': 'يوجد سجل بهذه القيمة مسبقاً.',
    'internal server error.': 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.',
    'request failed.': 'فشل تنفيذ الطلب.',
    'notification not found.': 'الإشعار غير موجود.',
    'cemetery not found.': 'المقبرة غير موجودة.',
    'the selected user is not a delegate.': 'المستخدم المحدد ليس مندوباً.',
    'too many attempts.': 'محاولات كثيرة. يرجى المحاولة لاحقاً.',
    'server error': 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.',
    'not found': 'المورد المطلوب غير موجود.',
    'forbidden': 'ليس لديك صلاحية للوصول إلى هذا المورد.',
    'unauthorized': 'يجب تسجيل الدخول للوصول إلى هذا المورد.',
  };

  static const Map<String, String> _fieldNames = {
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'password confirmation': 'تأكيد كلمة المرور',
    'first name': 'الاسم الأول',
    'last name': 'اسم العائلة',
    'national number': 'الرقم الوطني',
    'national id': 'رقم الهوية',
    'phone number': 'رقم الهاتف',
    'identity image': 'صورة الهوية',
    'fcm token': 'رمز الإشعارات',
    'otp': 'رمز التحقق',
    'reset token': 'رمز إعادة التعيين',
    'description': 'التفاصيل',
    'priority': 'الأولوية',
    'type': 'النوع',
    'form data': 'بيانات النموذج',
    'attachments': 'المرفقات',
    'amount': 'المبلغ',
    'receipt image': 'صورة الإيصال',
    'building id': 'المبنى',
    'delegate id': 'المندوب',
    'title': 'العنوان',
    'status': 'الحالة',
    'address': 'العنوان',
    'members': 'أفراد الأسرة',
  };

  static const Set<String> _genericMessages = {
    'validation failed.',
    'validation failed',
    'the given data was invalid.',
    'يرجى التحقق من البيانات المدخلة.',
    'فشل التحقق من البيانات.',
  };

  static Map<String, dynamic> expectMap(dynamic data, {String? fallback}) {
    if (data is! Map<String, dynamic>) {
      throw Exception(fallback ?? 'استجابة غير صالحة من الخادم');
    }

    if (data['success'] == false) {
      throw Exception(
        toUserMessage(
          Exception(extractMessage(data) ?? fallback ?? 'فشلت العملية'),
          fallback: fallback ?? 'فشلت العملية',
        ),
      );
    }

    return data;
  }

  static dynamic expectData(dynamic data, {String? fallback}) {
    return expectMap(data, fallback: fallback)['data'];
  }

  static Map<String, dynamic> expectDataMap(dynamic data, {String? fallback}) {
    final payload = expectData(data, fallback: fallback);
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    throw Exception(fallback ?? 'استجابة غير صالحة من الخادم');
  }

  static String? extractMessage(Map<String, dynamic> data) {
    final fromErrors = _firstValidationError(data['errors']);
    final message = data['message'];
    final fromMessage =
        message is String && message.trim().isNotEmpty ? message.trim() : null;

    if (fromErrors != null &&
        (fromMessage == null || _isGenericMessage(fromMessage))) {
      return fromErrors;
    }

    return fromMessage ?? fromErrors;
  }

  static List<T> parseList<T>(
    dynamic data, {
    required T Function(Map<String, dynamic> json) fromJson,
    String? fallback,
  }) {
    final map = expectMap(data, fallback: fallback);
    final payload = map['data'];
    final List<dynamic> rawList;

    if (payload is List) {
      rawList = payload;
    } else if (payload is Map<String, dynamic> && payload['data'] is List) {
      rawList = payload['data'] as List<dynamic>;
    } else {
      rawList = const [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }

  static T parseItem<T>(
    dynamic data, {
    required T Function(Map<String, dynamic> json) fromJson,
    String? fallback,
  }) {
    final payload = expectData(data, fallback: fallback);
    if (payload is! Map<String, dynamic>) {
      throw Exception(fallback ?? 'استجابة غير صالحة من الخادم');
    }

    return fromJson(payload);
  }

  /// User-facing Arabic message for any caught API / network error.
  static String toUserMessage(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      return _fromDioException(error, fallback: fallback);
    }

    final raw = _stripExceptionPrefix(error.toString());
    return _localize(raw) ??
        (raw.isNotEmpty && _hasArabic(raw) ? raw : fallback);
  }

  static Exception mapError(
    Object error, {
    required String fallback,
  }) {
    return Exception(toUserMessage(error, fallback: fallback));
  }

  static String _fromDioException(
    DioException error, {
    required String fallback,
  }) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال، تحقق من الإنترنت وحاول مرة أخرى';
      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالخادم، تحقق من الإنترنت';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      case DioExceptionType.badCertificate:
        return 'تعذر التحقق من أمان الاتصال بالخادم';
      case DioExceptionType.badResponse:
        break;
      case DioExceptionType.unknown:
        final inner = (error.error?.toString() ?? error.message ?? '')
            .toLowerCase();
        if (inner.contains('connection reset by peer') ||
            inner.contains('socketexception')) {
          return 'انقطع الاتصال أثناء رفع الملفات. يرجى تصغير حجم الصور والمحاولة مرة أخرى';
        }
        break;
    }

    final statusCode = error.response?.statusCode;
    final extracted = _extractFromResponse(error.response?.data);
    final localized = _localize(extracted);

    if (localized != null) {
      return localized;
    }

    return _messageForStatus(statusCode) ?? fallback;
  }

  static String? _extractFromResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return extractMessage(data);
    }
    if (data is String && data.trim().isNotEmpty && !data.trim().startsWith('<')) {
      return data.trim();
    }
    return null;
  }

  static String? _messageForStatus(int? statusCode) {
    return switch (statusCode) {
      400 => 'طلب غير صالح. يرجى التحقق من البيانات المدخلة.',
      401 => 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.',
      403 => 'ليس لديك صلاحية للوصول إلى هذا المورد.',
      404 => 'المورد المطلوب غير موجود.',
      409 => 'يوجد سجل بهذه القيمة مسبقاً.',
      413 => 'حجم الملف كبير جدًا، يرجى اختيار صورة أصغر',
      422 => 'يرجى التحقق من البيانات المدخلة.',
      429 => 'محاولات كثيرة. يرجى المحاولة لاحقاً.',
      500 || 502 || 503 => 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.',
      _ => null,
    };
  }

  static String? _firstValidationError(dynamic errors) {
    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      if (firstError is String && firstError.isNotEmpty) {
        return firstError;
      }
    }
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
    if (errors is String && errors.isNotEmpty) {
      return errors;
    }
    return null;
  }

  static bool _isGenericMessage(String message) {
    return _genericMessages.contains(message.trim().toLowerCase());
  }

  static String _stripExceptionPrefix(String value) {
    return value.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  }

  static String? _localize(String? message) {
    if (message == null) return null;
    final trimmed = message.trim();
    if (trimmed.isEmpty) return null;

    final known = _knownEnglishMessages[trimmed.toLowerCase()];
    if (known != null) return known;

    final fromValidation = _translateLaravelValidation(trimmed);
    if (fromValidation != null) return fromValidation;

    if (_hasArabic(trimmed)) return trimmed;

    // Hide leftover English / technical Dio text from the UI.
    if (_looksEnglish(trimmed) || _looksTechnical(trimmed)) {
      return null;
    }

    return trimmed;
  }

  static String? _translateLaravelValidation(String message) {
    final requiredMatch = RegExp(
      r'^The (.+) field is required\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (requiredMatch != null) {
      return '${_arabicField(requiredMatch.group(1)!)} مطلوب.';
    }

    final takenMatch = RegExp(
      r'^The (.+) has already been taken\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (takenMatch != null) {
      return '${_arabicField(takenMatch.group(1)!)} مستخدم مسبقاً.';
    }

    final emailMatch = RegExp(
      r'^The (.+) field must be a valid email address\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (emailMatch != null) {
      return 'يجب أن يكون ${_arabicField(emailMatch.group(1)!)} بريداً إلكترونياً صالحاً.';
    }

    final minMatch = RegExp(
      r'^The (.+) field must be at least (\d+) characters\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (minMatch != null) {
      return 'يجب ألا يقل ${_arabicField(minMatch.group(1)!)} عن ${minMatch.group(2)} أحرف.';
    }

    final maxCharsMatch = RegExp(
      r'^The (.+) field must not be greater than (\d+) characters\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (maxCharsMatch != null) {
      return 'يجب ألا يتجاوز ${_arabicField(maxCharsMatch.group(1)!)} ${maxCharsMatch.group(2)} حرفاً.';
    }

    final maxFileMatch = RegExp(
      r'^The (.+) field must not be greater than (\d+) kilobytes\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (maxFileMatch != null) {
      return 'يجب ألا يتجاوز حجم ${_arabicField(maxFileMatch.group(1)!)} ${maxFileMatch.group(2)} كيلوبايت.';
    }

    final confirmMatch = RegExp(
      r'^The (.+) field confirmation does not match\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (confirmMatch != null) {
      return 'تأكيد ${_arabicField(confirmMatch.group(1)!)} غير متطابق.';
    }

    final selectedMatch = RegExp(
      r'^The selected (.+) is invalid\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (selectedMatch != null) {
      return '${_arabicField(selectedMatch.group(1)!)} المحدد غير صالح.';
    }

    final imageMatch = RegExp(
      r'^The (.+) field must be an image\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (imageMatch != null) {
      return 'يجب أن يكون ${_arabicField(imageMatch.group(1)!)} صورة.';
    }

    final sizeMatch = RegExp(
      r'^The (.+) field must be (\d+) characters\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (sizeMatch != null) {
      return 'يجب أن يتكون ${_arabicField(sizeMatch.group(1)!)} من ${sizeMatch.group(2)} حرفاً.';
    }

    final digitsMatch = RegExp(
      r'^The (.+) field must be (\d+) digits\.?$',
      caseSensitive: false,
    ).firstMatch(message);
    if (digitsMatch != null) {
      return 'يجب أن يتكون ${_arabicField(digitsMatch.group(1)!)} من ${digitsMatch.group(2)} أرقام.';
    }

    return null;
  }

  static String _arabicField(String field) {
    return _fieldNames[field.trim().toLowerCase()] ?? field.trim();
  }

  static bool _hasArabic(String value) => _arabicPattern.hasMatch(value);

  static bool _looksEnglish(String value) =>
      _latinPattern.hasMatch(value) && !_hasArabic(value);

  static bool _looksTechnical(String value) {
    final lower = value.toLowerCase();
    return lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('httpexception') ||
        lower.contains('xmlhttprequest') ||
        lower.contains('status code') ||
        lower.startsWith('<!doctype') ||
        lower.startsWith('<html');
  }
}
