import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/image_section_card.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/presentation/components/building_complex_switch_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Ownership type Arabic label -> API value (`ownership_type`).
const Map<String, String> buildingOwnershipTypes = {
  'ملكية خاصة': 'private',
  'حكومي': 'government',
  'وقف': 'endowment',
};

class BuildingComplexFormContent extends StatelessWidget {
  const BuildingComplexFormContent({
    super.key,
    required this.survey,
    required this.buildingNameController,
    required this.realEstateNumberController,
    required this.licenseNumberController,
    required this.floorCountController,
    required this.coordinatesController,
    required this.onSyncText,
    required this.onCaptureBuildingPhoto,
  });

  final BuildingSurvey? survey;
  final TextEditingController buildingNameController;
  final TextEditingController realEstateNumberController;
  final TextEditingController licenseNumberController;
  final TextEditingController floorCountController;
  final TextEditingController? coordinatesController;
  final VoidCallback onSyncText;
  final VoidCallback onCaptureBuildingPhoto;

  @override
  Widget build(BuildContext context) {
    final building = survey?.building;
    final ownershipLabel = buildingOwnershipTypes.entries
        .firstWhere(
          (entry) => entry.value == building?.ownershipType,
          orElse: () => const MapEntry('', ''),
        )
        .key;

    return Column(
      children: [
        if (coordinatesController != null) ...[
          FormInputField(
            label: 'إحداثيات النقطة',
            hint: 'خط العرض، خط الطول',
            controller: coordinatesController,
            prefixIcon: Icons.pin_drop_outlined,
            readOnly: true,
          ),
          SizedBox(height: 18.h(context)),
        ],
        FormInputField(
          label: 'اسم المبنى',
          hint: 'أدخل اسم المبنى',
          controller: buildingNameController,
          onChanged: (_) => onSyncText(),
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'الرقم العقاري',
          hint: 'أدخل الرقم العقاري للمبنى',
          controller: realEstateNumberController,
          prefixIcon: Icons.numbers_outlined,
          onChanged: (_) => onSyncText(),
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'رقم الرخصة',
          hint: 'أدخل رقم رخصة البناء',
          controller: licenseNumberController,
          prefixIcon: Icons.assignment_outlined,
          onChanged: (_) => onSyncText(),
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'عدد الطوابق',
          hint: 'مثال: 12',
          controller: floorCountController,
          keyboardType: TextInputType.number,
          onChanged: (_) => onSyncText(),
        ),
        SizedBox(height: 18.h(context)),
        FormDropdownField(
          label: 'نوع الملكية',
          items: buildingOwnershipTypes.keys.toList(),
          value: ownershipLabel.isEmpty ? null : ownershipLabel,
          onChanged: (label) {
            if (label == null) return;
            context.read<BuildingSurveyCubit>().updateBuilding(
                  ownershipType: buildingOwnershipTypes[label],
                );
          },
        ),
        SizedBox(height: 8.h(context)),
        BuildingComplexSwitchTile(
          label: 'يوجد قبو',
          value: building?.hasBasement ?? false,
          onChanged: (value) => context
              .read<BuildingSurveyCubit>()
              .updateBuilding(hasBasement: value),
        ),
        BuildingComplexSwitchTile(
          label: 'يوجد كراج',
          value: building?.hasGarage ?? false,
          onChanged: (value) => context
              .read<BuildingSurveyCubit>()
              .updateBuilding(hasGarage: value),
        ),
        BuildingComplexSwitchTile(
          label: 'مبنى مخالف / غير مرخّص',
          value: building?.isIllegal ?? false,
          onChanged: (value) => context
              .read<BuildingSurveyCubit>()
              .updateBuilding(isIllegal: value),
        ),
        SizedBox(height: 18.h(context)),
        ImageSectionCard(
          label: 'صورة المبنى',
          localImagePath: building?.buildingImagePath,
          placeholderText: 'التقط صورة للمبنى من الكاميرا',
          onAddImage: onCaptureBuildingPhoto,
          onViewImage: onCaptureBuildingPhoto,
        ),
      ],
    );
  }
}
