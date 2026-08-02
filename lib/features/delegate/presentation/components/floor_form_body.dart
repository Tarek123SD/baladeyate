import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/file_upload_section.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class FloorFormBody extends StatelessWidget {
  const FloorFormBody({
    super.key,
    required this.isStandalone,
    required this.buildingName,
    required this.floorNumberController,
    required this.floorNameController,
    required this.apartmentCountController,
    required this.floorPlanNumberController,
  });

  final bool isStandalone;
  final String buildingName;
  final TextEditingController floorNumberController;
  final TextEditingController floorNameController;
  final TextEditingController apartmentCountController;
  final TextEditingController floorPlanNumberController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormSectionCard(
            title: 'مواصفات الطابق',
            badge: isStandalone ? 'مسح ميداني' : 'قيد الإدخال',
            badgeColor: AppColors.primaryGoldenWheat,
            child: Column(
              children: [
                FormInputField(
                  label: 'رقم الطابق',
                  hint: 'مثال: 4',
                  controller: floorNumberController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'اسم الطابق (اختياري)',
                  hint: 'مثال: طابق المزايين',
                  controller: floorNameController,
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد الشقق',
                  hint: 'أدخل عدد الوحدات السكنية',
                  controller: apartmentCountController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'رقم مخطط الطابق',
                  hint: 'أدخل رقم المخطط الفني',
                  controller: floorPlanNumberController,
                ),
              ],
            ),
          ),
          InfoCard(
            icon: Icons.apartment_outlined,
            title: 'المبنى المرتبط',
            subtitle: buildingName.isNotEmpty ? buildingName : 'مسح ميداني',
            iconColor: AppColors.primaryForest,
          ),
          FormSectionCard(
            title: 'مخطط الطابق',
            child: FileUploadSection(
              label: 'رفع المخطط',
              subtitle: 'الحد الأقصى 10 ميجابايت (PDF, JPG, PNG)',
              onUpload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'سيتم إضافة خاصية اختيار الملفات قريباً',
                    ),
                    backgroundColor: AppColors.primaryForest,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h(context)),
        ],
      ),
    );
  }
}
