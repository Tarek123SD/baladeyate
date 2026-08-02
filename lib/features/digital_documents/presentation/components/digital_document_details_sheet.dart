import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/digital_documents/models/digital_document_model.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

void showDigitalDocumentDetailsSheet(
  BuildContext context,
  DigitalDocumentModel document,
) {
  const primaryDarkGreen = Color(0xFF1B5E20);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DigitalDocumentDetailsSheet(
        document: document,
        primaryDarkGreen: primaryDarkGreen,
      );
    },
  );
}

class DigitalDocumentDetailsSheet extends StatelessWidget {
  const DigitalDocumentDetailsSheet({
    super.key,
    required this.document,
    this.primaryDarkGreen = const Color(0xFF1B5E20),
  });

  final DigitalDocumentModel document;
  final Color primaryDarkGreen;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r(context)),
          ),
        ),
        padding: EdgeInsets.all(20.s(context)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w(context),
                  height: 4.h(context),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r(context)),
                  ),
                ),
              ),
              SizedBox(height: 16.h(context)),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.s(context)),
                    decoration: BoxDecoration(
                      color: primaryDarkGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: primaryDarkGreen,
                      size: 24.ic(context),
                    ),
                  ),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.translatedType,
                          style: TextStyle(
                            fontSize: 18.f(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryCharcoal,
                          ),
                        ),
                        Text(
                          'وثيقة رقمية صادرة ومعتمدة رسمياً',
                          style: TextStyle(
                            fontSize: 12.f(context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h(context)),
              const Divider(),
              SizedBox(height: 14.h(context)),
              DigitalDocumentDetailRow(
                label: 'رقم المعاملة والوثيقة',
                value: document.transactionNumber,
              ),
              DigitalDocumentDetailRow(
                label: 'الحالة القانونية',
                value: 'مقبولة ومعتمدة رسمياً',
                textColor: primaryDarkGreen,
              ),
              DigitalDocumentDetailRow(
                label: 'تاريخ الاعتماد',
                value: document.displayDate,
              ),
              if (document.formData != null) ...[
                SizedBox(height: 8.h(context)),
                Text(
                  'بيانات الطلب المسجلة:',
                  style: TextStyle(
                    fontSize: 13.f(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryCharcoal,
                  ),
                ),
                SizedBox(height: 6.h(context)),
                ...document.formData!.entries.map((entry) {
                  if (entry.value == null ||
                      entry.value.toString().trim().isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return DigitalDocumentDetailRow(
                    label: entry.key,
                    value: entry.value.toString(),
                  );
                }),
              ],
              SizedBox(height: 20.h(context)),
              Center(
                child: Container(
                  padding: EdgeInsets.all(14.s(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r(context)),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: document.qrPayload,
                        version: QrVersions.auto,
                        size: 160.s(context),
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: primaryDarkGreen,
                        ),
                      ),
                      SizedBox(height: 10.h(context)),
                      Text(
                        'امسح الرمز للتحقق',
                        style: TextStyle(
                          fontSize: 12.f(context),
                          fontWeight: FontWeight.bold,
                          color: primaryDarkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h(context)),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDarkGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r(context)),
                  ),
                ),
                child: Text(
                  'إغلاق التفاصيل',
                  style: TextStyle(
                    fontSize: 14.f(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DigitalDocumentDetailRow extends StatelessWidget {
  const DigitalDocumentDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.textColor,
  });

  final String label;
  final String value;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5.f(context),
              color: Colors.grey.shade600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12.5.f(context),
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.primaryCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
