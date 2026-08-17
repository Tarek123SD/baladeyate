import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:flutter/material.dart';

class DonationModel {
  const DonationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.targetAmount,
    required this.collectedAmount,
    required this.currency,
    required this.status,
    required this.importanceLevel,
    required this.imageUrl,
    required this.city,
    required this.area,
    this.isFeatured = false,
    this.paymentLink,
    this.qrCode,
    this.qrImageUrl,
    this.paymentAccount,
    this.paymentMethod,
    this.paymentInstructions,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final String type;
  final double targetAmount;
  final double collectedAmount;
  final String currency;
  final String status;
  final String importanceLevel;
  final String imageUrl;
  final String city;
  final String area;
  final bool isFeatured;

  /// Payment destination from the dashboard (link, wallet/bank account, QR).
  final String? paymentLink;
  final String? qrCode;
  final String? qrImageUrl;
  final String? paymentAccount;
  final String? paymentMethod;
  final String? paymentInstructions;

  // Aliases for backward compatibility and snake_case backend getters
  double get raisedAmount => collectedAmount;
  // ignore: non_constant_identifier_names
  double? get target_amount => targetAmount;
  // ignore: non_constant_identifier_names
  double? get collected_amount => collectedAmount;

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    String city = '';
    String area = '';
    if (location is Map<String, dynamic>) {
      city = (location['city'] as String?) ?? '';
      area = (location['area'] as String?) ?? '';
    } else {
      city = (json['city'] as String?) ?? '';
      area = (json['area'] as String?) ?? '';
    }

    final payment = json['payment'];
    final paymentMap = payment is Map<String, dynamic> ? payment : const <String, dynamic>{};

    final rawQr = _pickString(json, const [
          'qr_code',
          'qr',
          'qr_payload',
        ]) ??
        _pickString(paymentMap, const ['qr_code', 'qr', 'qr_payload']);

    final qrImage = _pickString(json, const [
          'qr_image',
          'qr_image_url',
          'qr_code_url',
          'qr_code_image',
        ]) ??
        _pickString(paymentMap, const [
          'qr_image',
          'qr_image_url',
          'qr_code_url',
          'qr_code_image',
        ]);

    var paymentLink = _pickString(json, const [
          'payment_link',
          'payment_url',
          'donation_link',
          'donate_url',
        ]) ??
        _pickString(paymentMap, const [
          'payment_link',
          'payment_url',
          'donation_link',
          'donate_url',
          'link',
        ]);

    var qrImageUrl = qrImage;
    String? qrPayload = rawQr;

    if (rawQr != null && _looksLikeImageUrl(rawQr)) {
      qrImageUrl ??= rawQr;
      qrPayload = null;
    } else if (paymentLink == null && rawQr != null && _looksLikeHttpUrl(rawQr)) {
      paymentLink = rawQr;
    }

    return DonationModel(
      id: json['id'] as int? ?? 0,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'حملة خيرية',
      description: (json['description'] as String?) ??
          (json['details'] as String?) ??
          '',
      category:
          (json['category'] as String?) ?? (json['type'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      targetAmount: _toDouble(json['target_amount'] ?? json['required_amount'] ?? json['targetAmount']),
      collectedAmount:
          _toDouble(json['collected_amount'] ?? json['raised_amount'] ?? json['collectedAmount']),
      currency: (json['currency'] as String?) ?? 'SYP',
      status: (json['status'] as String?) ?? '',
      importanceLevel: (json['importance_level'] as String?) ?? '',
      imageUrl:
          (json['image_url'] as String?) ?? (json['image'] as String?) ?? '',
      city: city,
      area: area,
      isFeatured: _toBool(json['is_featured'] ?? json['isFeatured']),
      paymentLink: paymentLink,
      qrCode: qrPayload,
      qrImageUrl: qrImageUrl,
      paymentAccount: _pickString(json, const [
            'payment_account',
            'account_number',
            'bank_account',
            'wallet_number',
            'iban',
          ]) ??
          _pickString(paymentMap, const [
            'payment_account',
            'account_number',
            'bank_account',
            'wallet_number',
            'iban',
            'account',
          ]),
      paymentMethod: _pickString(json, const [
            'payment_method',
            'bank_name',
            'wallet_name',
          ]) ??
          _pickString(paymentMap, const [
            'payment_method',
            'bank_name',
            'wallet_name',
            'method',
          ]),
      paymentInstructions: _pickString(json, const [
            'payment_instructions',
            'instructions',
            'payment_note',
          ]) ??
          _pickString(paymentMap, const [
            'payment_instructions',
            'instructions',
            'payment_note',
            'note',
          ]),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String? _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is num) {
        return value.toString();
      }
    }
    return null;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == '1' || normalized == 'true';
    }
    return false;
  }

  static bool _looksLikeHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
    final scheme = uri.scheme.toLowerCase();
    return scheme == 'http' || scheme == 'https';
  }

  static bool _looksLikeImageUrl(String value) {
    if (!_looksLikeHttpUrl(value)) return false;
    final path = Uri.parse(value).path.toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif') ||
        path.contains('/storage/') ||
        path.contains('/uploads/');
  }

  bool get hasPaymentDestination =>
      (paymentLink != null && paymentLink!.isNotEmpty) ||
      (paymentAccount != null && paymentAccount!.isNotEmpty) ||
      (qrCode != null && qrCode!.isNotEmpty) ||
      (qrImageUrl != null && qrImageUrl!.isNotEmpty);

  bool get hasOpenablePaymentLink =>
      paymentLink != null && _looksLikeHttpUrl(paymentLink!);

  /// Value encoded into a generated QR when the API does not send a QR image.
  String? get qrPayload {
    if (qrCode != null && qrCode!.isNotEmpty) return qrCode;
    if (paymentLink != null && paymentLink!.isNotEmpty) return paymentLink;
    if (paymentAccount != null && paymentAccount!.isNotEmpty) {
      return paymentAccount;
    }
    return null;
  }

  double get progress {
    if (target_amount == null || target_amount! <= 0) return 0.0;
    return (collected_amount ?? 0) / target_amount!;
  }

  int get progressPercentage {
    return (progress.clamp(0.0, 1.0) * 100).toInt();
  }

  int get progressPercent => progressPercentage;

  String get currencySymbol {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'SYP':
        return 'ل.س';
      default:
        return currency;
    }
  }

  String _formatAmount(double value) {
    return value.toInt().toString().replaceAllMapped(
          RegExp(r"\B(?=(\d{3})+(?!\d))"),
          (match) => ",",
        );
  }

  String get goalLabel =>
      'الهدف ${_formatAmount(targetAmount)} $currencySymbol';
  String get statusLabel => 'تم جمع $progressPercentage%';

  String get locationLabel {
    final parts = [area, city].where((p) => p.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'غير محدد' : parts.join('، ');
  }

  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'health':
        return 'صحي';
      case 'food':
        return 'إغاثي';
      case 'education':
        return 'تعليمي';
      case 'housing':
        return 'إعمار';
      case 'water':
        return 'مياه';
      default:
        return 'خيري';
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'health':
        return AppIcons.health;
      case 'food':
        return AppIcons.food;
      case 'education':
        return AppIcons.education;
      case 'housing':
        return AppIcons.housing;
      case 'water':
        return AppIcons.water;
      default:
        return AppIcons.donate;
    }
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'health':
        return AppColors.secondaryForest;
      case 'food':
        return AppColors.primaryGoldenWheat;
      case 'education':
        return AppColors.thirdForest;
      case 'housing':
        return AppColors.secondaryGoldenWheat;
      case 'water':
        return const Color(0xFF1667C2);
      default:
        return AppColors.primaryForest;
    }
  }
}

// Alias for backward compatibility
typedef DonationCase = DonationModel;
