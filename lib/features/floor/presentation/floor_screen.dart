import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/file_upload_section.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';

class FloorScreen extends StatefulWidget {
  const FloorScreen({super.key});

  @override
  State<FloorScreen> createState() => _FloorScreenState();
}

class _FloorScreenState extends State<FloorScreen> {
  late TextEditingController _floorNumberController;
  late TextEditingController _floorNameController;
  late TextEditingController _apartmentCountController;
  late TextEditingController _floorPlanNumberController;

  @override
  void initState() {
    super.initState();
    _floorNumberController = TextEditingController(text: '4');
    _floorNameController = TextEditingController();
    _apartmentCountController = TextEditingController();
    _floorPlanNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _floorNumberController.dispose();
    _floorNameController.dispose();
    _apartmentCountController.dispose();
    _floorPlanNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Floor Specifications Card
          FormSectionCard(
            title: 'مواصفات الطابق',
            badge: 'قيد الإدخال',
            badgeColor: AppColors.primaryGoldenWheat,
            child: Column(
              children: [
                FormInputField(
                  label: 'رقم الطابق',
                  hint: 'مثال: 4',
                  controller: _floorNumberController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'اسم الطابق (اختياري)',
                  hint: 'مثال: طابق المزايين',
                  controller: _floorNameController,
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد الشقق',
                  hint: 'أدخل عدد الوحدات السكنية',
                  controller: _apartmentCountController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'رقم مخطط الطابق',
                  hint: 'أدخل رقم المخطط الفني',
                  controller: _floorPlanNumberController,
                ),
              ],
            ),
          ),
          // Building Reference Card
          InfoCard(
            icon: Icons.apartment_outlined,
            title: 'المبنى المرتبط',
            subtitle: 'برج البياسمين',
            iconColor: AppColors.primaryGoldenWheat.withValues(alpha: 0.2),
          ),
          // Floor Plan Upload Card
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 16.w(context),
              vertical: 12.h(context),
            ),
            padding: EdgeInsets.all(24.w(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r(context)),
              border: Border.all(
                color: const Color(0xFFE6E6E6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FileUploadSection(
              label: 'مخطط الطابق',
              subtitle: 'الحد الأقصى 10 ميجابايت (PDF, JPG, PNG)',
              onUpload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        const Text('سيتم إضافة خاصية اختيار الملفات قريباً'),
                    backgroundColor: AppColors.primaryForest,
                  ),
                );
              },
            ),
          ),
          // Info Message
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 16.w(context),
              vertical: 12.h(context),
            ),
            padding: EdgeInsets.all(16.w(context)),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20.r(context)),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
                width: 1,
              ),
            ),
            child: Text(
              'الدقة في توثيق بيانات الطابق تضمن سلامة المخططات الإنشائية والبيئية.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.s(context),
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.8),
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 20.h(context)),
        ],
      ),
    );
  }
}
