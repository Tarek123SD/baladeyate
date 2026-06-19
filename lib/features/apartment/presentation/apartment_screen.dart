import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/image_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';

class ApartmentScreen extends StatefulWidget {
  const ApartmentScreen({super.key});

  @override
  State<ApartmentScreen> createState() => _ApartmentScreenState();
}

class _ApartmentScreenState extends State<ApartmentScreen> {
  late TextEditingController _apartmentNumberController;
  late TextEditingController _apartmentTypeController;

  String? _selectedOccupancyStatus = 'مسكون'; // Default selected
  int _selectedRoomCount = 3; // Default selected

  @override
  void initState() {
    super.initState();
    _apartmentNumberController = TextEditingController(text: '402');
    _apartmentTypeController = TextEditingController(text: 'مكتبية - عائلية');
  }

  @override
  void dispose() {
    _apartmentNumberController.dispose();
    _apartmentTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // References Row (Floor + Building)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
            child: Row(
              children: [
                SizedBox(
                  width:
                      (MediaQuery.of(context).size.width - 44.w(context)) / 2,
                  child: InfoCard(
                    icon: Icons.layers_outlined,
                    title: 'الطابق',
                    subtitle: 'الطابق الرابع',
                    iconColor: AppColors.primaryGoldenWheat.withValues(alpha: 0.2),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                SizedBox(
                  width:
                      (MediaQuery.of(context).size.width - 44.w(context)) / 2,
                  child: InfoCard(
                    icon: Icons.apartment_outlined,
                    title: 'المبنى',
                    subtitle: 'برج البياسمين A1',
                    iconColor: AppColors.primaryGoldenWheat.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
          // Unit Details Card
          FormSectionCard(
            title: 'تفاصيل الوحدة',
            badge: 'قيد الإدخال',
            badgeColor: AppColors.primaryGoldenWheat,
            child: Column(
              children: [
                // Apartment Number
                FormInputField(
                  label: 'رقم الشقة',
                  hint: 'أدخل رقم الوحدة',
                  controller: _apartmentNumberController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 18.h(context)),
                // Apartment Type
                FormInputField(
                  label: 'نوع الشقة',
                  hint: 'مثال: مكتبية - عائلية',
                  controller: _apartmentTypeController,
                ),
                SizedBox(height: 24.h(context)),
                // Occupancy Status
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'حالة الاشغال',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14.s(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryCharcoal,
                    ),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOccupancyButton(context, 'قيد الترميم'),
                    SizedBox(width: 8.w(context)),
                    _buildOccupancyButton(context, 'شاغر'),
                    SizedBox(width: 8.w(context)),
                    _buildOccupancyButton(context, 'مسكون'),
                  ],
                ),
                SizedBox(height: 24.h(context)),
                // Room Count
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'عدد الغرف',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14.s(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryCharcoal,
                    ),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoomCountButton(context, '+5'),
                    SizedBox(width: 8.w(context)),
                    _buildRoomCountButton(context, '4'),
                    SizedBox(width: 8.w(context)),
                    _buildRoomCountButton(context, '3'),
                    SizedBox(width: 8.w(context)),
                    _buildRoomCountButton(context, '2'),
                    SizedBox(width: 8.w(context)),
                    _buildRoomCountButton(context, '1'),
                  ],
                ),
                SizedBox(height: 24.h(context)),
                // Image Upload Section
                ImageSectionCard(
                  label: 'إضافة صورة للوحدة',
                  onAddImage: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('سيتم إضافة خاصية اختيار الصور قريباً'),
                        backgroundColor: AppColors.primaryForest,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h(context)),
        ],
      ),
    );
  }

  Widget _buildOccupancyButton(BuildContext context, String label) {
    final isSelected = _selectedOccupancyStatus == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedOccupancyStatus = label),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 10.h(context),
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryForest : Colors.white,
            borderRadius: BorderRadius.circular(20.r(context)),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryForest
                  : const Color(0xFFD9D9D9),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(left: 6.w(context)),
                  child: Icon(
                    Icons.check,
                    size: 16.s(context),
                    color: Colors.white,
                  ),
                ),
              Text(
                label,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 12.s(context),
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? Colors.white : AppColors.secondaryCharcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCountButton(BuildContext context, String label) {
    final isSelected = (_selectedRoomCount == int.tryParse(label) ||
        (_selectedRoomCount == 5 && label == '+5'));
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (label == '+5') {
              _selectedRoomCount = 5;
            } else {
              _selectedRoomCount = int.parse(label);
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h(context)),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primaryForest : const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.s(context),
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF999999),
            ),
          ),
        ),
      ),
    );
  }
}
