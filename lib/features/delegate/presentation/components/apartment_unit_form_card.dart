import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Floor type Arabic label -> API value (`floor_type`).
const Map<String, String> apartmentFloorTypes = {
  'سكني': 'residential',
  'تجاري': 'commercial',
  'مختلط': 'mixed',
};

class ApartmentUnitFormCard extends StatelessWidget {
  const ApartmentUnitFormCard({
    super.key,
    required this.index,
    required this.unit,
    required this.waterMeterController,
    required this.electricityMeterController,
    required this.landlineController,
    required this.onUnitChanged,
    required this.onFieldsChanged,
    required this.onAddFamily,
  });

  final int index;
  final ApartmentUnitDraft unit;
  final TextEditingController waterMeterController;
  final TextEditingController electricityMeterController;
  final TextEditingController landlineController;
  final ValueChanged<ApartmentUnitDraft> onUnitChanged;
  final VoidCallback onFieldsChanged;
  final VoidCallback onAddFamily;

  @override
  Widget build(BuildContext context) {
    final floorTypeLabel = apartmentFloorTypes.entries
        .firstWhere(
          (entry) => entry.value == unit.floorType,
          orElse: () => const MapEntry('سكني', 'residential'),
        )
        .key;

    return FormSectionCard(
      title: 'تفاصيل الشقة ${index + 1}',
      badge: unit.isSaved ? 'تم الحفظ' : 'مسح ميداني',
      badgeColor:
          unit.isSaved ? AppColors.primaryForest : AppColors.primaryGoldenWheat,
      child: Column(
        children: [
          FormDropdownField(
            label: 'نوع الوحدة',
            items: apartmentFloorTypes.keys.toList(),
            value: floorTypeLabel,
            onChanged: (label) {
              if (label == null) return;
              onUnitChanged(
                unit.copyWith(floorType: apartmentFloorTypes[label]),
              );
              onFieldsChanged();
            },
          ),
          SizedBox(height: 18.h(context)),
          FormInputField(
            label: 'رقم عداد المياه',
            hint: 'أدخل رقم عداد المياه',
            controller: waterMeterController,
            prefixIcon: Icons.water_drop_outlined,
            onChanged: (_) => onFieldsChanged(),
          ),
          SizedBox(height: 18.h(context)),
          FormInputField(
            label: 'رقم عداد الكهرباء',
            hint: 'أدخل رقم عداد الكهرباء',
            controller: electricityMeterController,
            prefixIcon: Icons.electric_bolt_outlined,
            onChanged: (_) => onFieldsChanged(),
          ),
          SizedBox(height: 18.h(context)),
          FormInputField(
            label: 'الهاتف الأرضي (اختياري)',
            hint: 'أدخل رقم الهاتف الأرضي',
            controller: landlineController,
            prefixIcon: Icons.call_outlined,
            keyboardType: TextInputType.phone,
            onChanged: (_) => onFieldsChanged(),
          ),
          SizedBox(height: 18.h(context)),
          FormDropdownField(
            label: 'حالة الشقة',
            items: const ['مسكونة', 'فارغة', 'مغلقة', 'قيد الإكساء'],
            value: unit.status.isEmpty ? 'فارغة' : unit.status,
            onChanged: (newStatus) {
              if (newStatus == null) return;
              onUnitChanged(
                unit.copyWith(
                  status: newStatus,
                  isSealed: newStatus == 'مغلقة' ? true : unit.isSealed,
                ),
              );
              onFieldsChanged();
            },
          ),
          SizedBox(height: 8.h(context)),
          SwitchListTile.adaptive(
            value: unit.isSealed,
            onChanged: (value) {
              onUnitChanged(unit.copyWith(isSealed: value));
              onFieldsChanged();
            },
            activeThumbColor: AppColors.primaryForest,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'الوحدة مغلقة / مختومة',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.s(context),
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryCharcoal,
              ),
            ),
          ),
          if (unit.status == 'مسكونة') ...[
            SizedBox(height: 12.h(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddFamily,
                icon: const Icon(Icons.people_outline, color: Colors.white),
                label: const Text('إضافة بيانات الأسرة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGoldenWheat,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
