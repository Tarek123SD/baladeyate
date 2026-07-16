import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DonationCase {
  const DonationCase({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.targetAmount,
    required this.raisedAmount,
    required this.currency,
    required this.status,
    required this.importanceLevel,
    required this.imageUrl,
    required this.city,
    required this.area,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final String type;
  final double targetAmount;
  final double raisedAmount;
  final String currency;
  final String status;
  final String importanceLevel;
  final String imageUrl;
  final String city;
  final String area;

  factory DonationCase.fromJson(Map<String, dynamic> json) {
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

    return DonationCase(
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
      // Our API exposes required_amount / collected_amount.
      targetAmount:
          _toDouble(json['required_amount'] ?? json['target_amount']),
      raisedAmount:
          _toDouble(json['collected_amount'] ?? json['raised_amount']),
      currency: (json['currency'] as String?) ?? 'SYP',
      status: (json['status'] as String?) ?? '',
      importanceLevel: (json['importance_level'] as String?) ?? '',
      imageUrl:
          (json['image_url'] as String?) ?? (json['image'] as String?) ?? '',
      city: city,
      area: area,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double get progress {
    if (targetAmount <= 0) return 0;
    return (raisedAmount / targetAmount).clamp(0.0, 1.0);
  }

  int get progressPercent => (progress * 100).round();

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

  String get goalLabel => 'الهدف ${_formatAmount(targetAmount)} $currencySymbol';

  String get statusLabel => 'تم جمع $progressPercent%';

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
        return Icons.local_hospital;
      case 'food':
        return Icons.food_bank;
      case 'education':
        return Icons.school;
      case 'housing':
        return Icons.home_work_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      default:
        return Icons.volunteer_activism_rounded;
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

  bool get hasImportance => importanceLevel.trim().isNotEmpty;

  String get importanceLabel {
    switch (importanceLevel.toLowerCase()) {
      case 'high':
        return 'أهمية عالية';
      case 'medium':
        return 'أهمية متوسطة';
      case 'low':
        return 'أهمية منخفضة';
      default:
        return '';
    }
  }

  Color get importanceColor {
    switch (importanceLevel.toLowerCase()) {
      case 'high':
        return const Color(0xFFD64545);
      case 'medium':
        return AppColors.primaryGoldenWheat;
      case 'low':
        return AppColors.secondaryForest;
      default:
        return AppColors.primaryForest;
    }
  }
}
