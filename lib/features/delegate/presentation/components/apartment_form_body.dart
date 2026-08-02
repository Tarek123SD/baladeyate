import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/info_card.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/presentation/components/apartment_unit_form_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ApartmentFormBody extends StatelessWidget {
  const ApartmentFormBody({
    super.key,
    required this.isStandalone,
    required this.survey,
    required this.floor,
    required this.apartmentsCount,
    required this.initialized,
    required this.apartmentDrafts,
    required this.waterMeterControllers,
    required this.electricityMeterControllers,
    required this.landlineControllers,
    required this.onUnitChanged,
    required this.onFieldsChanged,
    required this.onAddFamily,
  });

  final bool isStandalone;
  final BuildingSurvey? survey;
  final FloorDraft? floor;
  final int apartmentsCount;
  final bool initialized;
  final List<ApartmentUnitDraft> apartmentDrafts;
  final List<TextEditingController> waterMeterControllers;
  final List<TextEditingController> electricityMeterControllers;
  final List<TextEditingController> landlineControllers;
  final void Function(int index, ApartmentUnitDraft unit) onUnitChanged;
  final VoidCallback onFieldsChanged;
  final void Function(int index) onAddFamily;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isStandalone) ...[
            InfoCard(
              icon: Icons.layers_outlined,
              title: 'الطابق',
              subtitle: floor != null
                  ? (floor!.floorName.isNotEmpty
                      ? floor!.floorName
                      : 'الطابق ${floor!.floorNumber}')
                  : 'الطابق الحالي',
              iconColor: AppColors.primaryForest,
            ),
            InfoCard(
              icon: Icons.apartment_outlined,
              title: 'المبنى',
              subtitle: survey?.building.name.isNotEmpty == true
                  ? survey!.building.name
                  : 'مسح ميداني',
              iconColor: AppColors.primaryForest,
            ),
          ],
          if (initialized)
            ...List.generate(apartmentsCount, (index) {
              return ApartmentUnitFormCard(
                index: index,
                unit: apartmentDrafts[index],
                waterMeterController: waterMeterControllers[index],
                electricityMeterController:
                    electricityMeterControllers[index],
                landlineController: landlineControllers[index],
                onUnitChanged: (unit) => onUnitChanged(index, unit),
                onFieldsChanged: onFieldsChanged,
                onAddFamily: () => onAddFamily(index),
              );
            }),
          SizedBox(height: 20.h(context)),
        ],
      ),
    );
  }
}
