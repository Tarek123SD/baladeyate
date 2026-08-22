import 'package:flutter/material.dart';

/// Shared display helpers for transaction status, type, dates, and form data.
class TransactionStatusProps {
  const TransactionStatusProps({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
}

const Map<String, String> transactionFormDataLabels = {
  'commercial_name': 'الاسم التجاري',
  'shop_area': 'المساحة',
  'activity_type': 'نوع النشاط',
  'building_type': 'نوع البناء',
  'building_area': 'مساحة البناء',
  'floors_count': 'عدد الطوابق',
  'apartment_number': 'رقم الشقة',
  'service_description': 'وصف الخدمة',
  'notes': 'ملاحظات',
  'address': 'العنوان',
};

TransactionStatusProps getTransactionStatusProps(String status) {
  switch (status.toLowerCase()) {
    case 'field_inspection':
    case 'kashf':
      return const TransactionStatusProps(
        label: 'كشف ميداني',
        color: Color(0xFF4527A0),
        bgColor: Color(0xFFEDE7F6),
        icon: Icons.fact_check_outlined,
      );
    case 'needs_documents':
      return const TransactionStatusProps(
        label: 'بحاجة لوثائق',
        color: Color(0xFF6D4C41),
        bgColor: Color(0xFFEFEBE9),
        icon: Icons.upload_file_outlined,
      );
    case 'under_review':
    case 'processing':
    case 'in_progress':
      return const TransactionStatusProps(
        label: 'قيد الدراسة',
        color: Color(0xFF1565C0),
        bgColor: Color(0xFFE3F2FD),
        icon: Icons.sync_rounded,
      );
    case 'approved':
      return const TransactionStatusProps(
        label: 'مقبولة',
        color: Color(0xFF2E7D32),
        bgColor: Color(0xFFE8F5E9),
        icon: Icons.check_circle_rounded,
      );
    case 'completed':
      return const TransactionStatusProps(
        label: 'مكتملة',
        color: Color(0xFF1B5E20),
        bgColor: Color(0xFFE8F5E9),
        icon: Icons.verified_rounded,
      );
    case 'rejected':
      return const TransactionStatusProps(
        label: 'مرفوضة',
        color: Color(0xFFC62828),
        bgColor: Color(0xFFFFEBEE),
        icon: Icons.cancel_rounded,
      );
    case 'pending':
    default:
      return const TransactionStatusProps(
        label: 'قيد المراجعة',
        color: Color(0xFFE65100),
        bgColor: Color(0xFFFFF3E0),
        icon: Icons.hourglass_top_rounded,
      );
  }
}

String getTransactionTypeLabel(String type, {String? typeLabel}) {
  if (typeLabel != null && typeLabel.trim().isNotEmpty) {
    return typeLabel;
  }

  switch (type.toLowerCase()) {
    case 'commercial_license':
      return 'رخصة تجارية';
    case 'building_permit':
      return 'رخصة بناء';
    case 'general_service':
      return 'خدمة عامة';
    default:
      if (type.trim().isNotEmpty) {
        return type;
      }
      return 'معاملة بلدية';
  }
}

String formatTransactionDate(String dateStr) {
  if (dateStr.isEmpty) return 'تاريخ غير متوفر';
  final parsed = DateTime.tryParse(dateStr);
  if (parsed == null) return dateStr;
  return '${parsed.day}/${parsed.month}/${parsed.year}';
}

String formatTransactionFormDataValue(String key, dynamic value) {
  final strValue = value?.toString() ?? '';
  if (strValue.isEmpty) return strValue;
  if ((key == 'shop_area' || key == 'building_area') &&
      !strValue.contains('م')) {
    return '$strValue م²';
  }
  return strValue;
}

String formatTransactionFormDataPair(String key, dynamic value) {
  final label = transactionFormDataLabels[key] ?? key;
  final formattedVal = formatTransactionFormDataValue(key, value);
  return '$label: $formattedVal';
}
