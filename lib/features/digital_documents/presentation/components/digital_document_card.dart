import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/digital_documents/models/digital_document_model.dart';

/// Premium Wallet Card widget for a Digital Municipal Document.
class DigitalDocumentCard extends StatelessWidget {
  final DigitalDocumentModel document;
  final VoidCallback? onTapDetails;
  final int cardIndex;

  const DigitalDocumentCard({
    super.key,
    required this.document,
    this.onTapDetails,
    this.cardIndex = 0,
  });

  /// Form Data Key Translations
  static const Map<String, String> _formDataLabels = {
    'commercial_name': 'الاسم التجاري',
    'activity_type': 'نوع النشاط',
    'shop_area': 'المساحة',
    'building_type': 'نوع البناء',
    'building_area': 'مساحة البناء',
    'floors_count': 'عدد الطوابق',
    'apartment_number': 'رقم الشقة',
    'notes': 'ملاحظات',
    'address': 'العنوان',
  };

  @override
  Widget build(BuildContext context) {
    const municipalDarkGreen = Color(0xFF1B5E20);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 18.h(context)),
      decoration: BoxDecoration(
        color: municipalDarkGreen,
        borderRadius: BorderRadius.circular(20.r(context)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            municipalDarkGreen,
            municipalDarkGreen.withValues(alpha: 0.92),
            const Color(0xFF0D3B13),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: municipalDarkGreen.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF81C784).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r(context)),
        child: Stack(
          children: [
            // Watermark Logo/Pattern Background
            Positioned(
              top: -20.h(context),
              left: -20.w(context),
              child: Icon(
                Icons.account_balance_rounded,
                size: 130.ic(context),
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),

            // Main Content Layout
            Padding(
              padding: EdgeInsets.all(20.s(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TOP: Document Type (Left) & Official Badge Icon (Right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Document Type Translated
                      Expanded(
                        child: Text(
                          document.translatedType,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.f(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Official Badge Icon / Emblem
                      Container(
                        padding: EdgeInsets.all(8.s(context)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          color: const Color(0xFFFFD54F),
                          size: 22.ic(context),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h(context)),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.2),
                    height: 1,
                  ),
                  SizedBox(height: 14.h(context)),

                  // CENTER: Key Details & Form Data
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Details Column (Transaction Number & Key Data)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Transaction Number
                            Text(
                              'رقم المعاملة',
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 11.f(context),
                              ),
                            ),
                            SizedBox(height: 2.h(context)),
                            Text(
                              document.transactionNumber,
                              style: TextStyle(
                                color: const Color(0xFFFFD54F),
                                fontSize: 14.f(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10.h(context)),

                            // Date of approval
                            Text(
                              'تاريخ الاعتماد',
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 11.f(context),
                              ),
                            ),
                            SizedBox(height: 2.h(context)),
                            Text(
                              document.displayDate,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.f(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10.h(context)),

                            // Key data from form_data (e.g. "الاسم التجاري", "المساحة")
                            if (document.formData != null &&
                                document.formData!.isNotEmpty)
                              ..._buildFormDataRows(context),
                          ],
                        ),
                      ),

                      SizedBox(width: 14.w(context)),

                      // BOTTOM / RIGHT: Pure White Rounded Rectangle Container Holding QR Code
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.s(context)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r(context)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: document.qrPayload,
                              version: QrVersions.auto,
                              size: 100.s(context),
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: municipalDarkGreen,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppColors.primaryCharcoal,
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h(context)),

                          // Text under QR code
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppIcons.scanDocument,
                                size: 11.ic(context),
                                color: const Color(0xFFFFD54F),
                              ),
                              SizedBox(width: 3.w(context)),
                              Text(
                                'امسح الرمز للتحقق',
                                style: TextStyle(
                                  color: Colors.grey.shade200,
                                  fontSize: 10.f(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h(context)),

                  // Details Action Trigger
                  if (onTapDetails != null)
                    InkWell(
                      onTap: onTapDetails,
                      borderRadius: BorderRadius.circular(10.r(context)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w(context),
                          vertical: 6.h(context),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'عرض التفاصيل والسجل الكامل',
                              style: TextStyle(
                                color: Colors.grey.shade200,
                                fontSize: 11.5.f(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: const Color(0xFFFFD54F),
                              size: 12.ic(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: (60 * cardIndex).ms).slideY(begin: 0.05, end: 0);
  }

  List<Widget> _buildFormDataRows(BuildContext context) {
    final rawMap = document.formData!;
    final entries = rawMap.entries
        .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
        .take(2)
        .toList();

    if (entries.isEmpty) return [];

    return entries.map((entry) {
      final label = _formDataLabels[entry.key] ?? entry.key;
      final valueStr = entry.value.toString();

      return Padding(
        padding: EdgeInsets.only(bottom: 8.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 11.f(context),
              ),
            ),
            SizedBox(height: 2.h(context)),
            Text(
              valueStr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5.f(context),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }).toList();
  }
}
