import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/presentation/components/people_aid_date_field.dart';
import 'package:baladeyate/features/delegate/presentation/components/people_verification_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Health status Arabic label -> API value (`health_status`).
const Map<String, String> peopleHealthStatuses = {
  'جيدة': 'good',
  'متوسطة': 'medium',
  'سيئة': 'poor',
};

/// Living/economic status Arabic label -> API value (`living_status`).
const Map<String, String> peopleLivingStatuses = {
  'جيدة': 'good',
  'متوسطة': 'medium',
  'منخفضة': 'poor',
};

/// Occupancy type Arabic label -> API value (`occupancy_type`).
const Map<String, String> peopleOccupancyTypes = {
  'ملك': 'owner',
  'إيجار': 'rent',
};

String peopleLabelForValue(
  Map<String, String> map,
  String? value,
  String fallback,
) {
  return map.entries
      .firstWhere(
        (entry) => entry.value == value,
        orElse: () => MapEntry(fallback, map[fallback] ?? ''),
      )
      .key;
}

class PeopleFormBody extends StatelessWidget {
  const PeopleFormBody({
    super.key,
    required this.isStandalone,
    required this.survey,
    required this.floor,
    required this.unit,
    required this.isDataVerified,
    required this.familyBookController,
    required this.unemployedCountController,
    required this.studentsCountController,
    required this.familyMembersCountController,
    required this.residentsCountController,
    required this.compositionController,
    required this.headNationalIdController,
    required this.headFullNameController,
    required this.onSyncText,
    required this.onPickAidDate,
  });

  final bool isStandalone;
  final BuildingSurvey? survey;
  final FloorDraft? floor;
  final ApartmentUnitDraft? unit;
  final bool isDataVerified;
  final TextEditingController familyBookController;
  final TextEditingController unemployedCountController;
  final TextEditingController studentsCountController;
  final TextEditingController familyMembersCountController;
  final TextEditingController residentsCountController;
  final TextEditingController compositionController;
  final TextEditingController headNationalIdController;
  final TextEditingController headFullNameController;
  final VoidCallback onSyncText;
  final VoidCallback onPickAidDate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isStandalone) ...[
            InfoCard(
              icon: Icons.apartment_outlined,
              title: 'المبنى',
              subtitle: survey?.building.name.isNotEmpty == true
                  ? survey!.building.name
                  : 'مسح ميداني',
              iconColor: AppColors.primaryForest,
            ),
            InfoCard(
              icon: Icons.layers_outlined,
              title: 'الطابق',
              subtitle: floor != null
                  ? (floor!.floorName.isNotEmpty
                      ? floor!.floorName
                      : 'الطابق ${floor!.floorNumber}')
                  : '—',
              iconColor: AppColors.primaryForest,
            ),
          ],
          FormSectionCard(
            title: 'بيانات الأسرة',
            badge: 'تسجيل الوحدة',
            badgeColor: AppColors.primaryGoldenWheat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormInputField(
                  label: 'رقم دفتر العائلة',
                  hint: 'أدخل رقم دفتر العائلة',
                  controller: familyBookController,
                  prefixIcon: Icons.menu_book_outlined,
                  onChanged: (_) => onSyncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'رقم هوية رب الأسرة',
                  hint: '11 رقمًا لربط السجل بحساب المواطن',
                  controller: headNationalIdController,
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onSyncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'اسم رب الأسرة',
                  hint: 'الاسم الكامل كما في الهوية',
                  controller: headFullNameController,
                  prefixIcon: Icons.person_outline,
                  onChanged: (_) => onSyncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormDropdownField(
                  label: 'الحالة الصحية',
                  items: peopleHealthStatuses.keys.toList(),
                  value: peopleLabelForValue(
                    peopleHealthStatuses,
                    unit?.healthStatus,
                    'جيدة',
                  ),
                  onChanged: (label) {
                    if (label == null) return;
                    context.read<BuildingSurveyCubit>().updateCurrentFamily(
                          healthStatus: peopleHealthStatuses[label],
                        );
                  },
                ),
                SizedBox(height: 18.h(context)),
                FormDropdownField(
                  label: 'الحالة المعيشية',
                  items: peopleLivingStatuses.keys.toList(),
                  value: peopleLabelForValue(
                    peopleLivingStatuses,
                    unit?.livingStatus,
                    'متوسطة',
                  ),
                  onChanged: (label) {
                    if (label == null) return;
                    context.read<BuildingSurveyCubit>().updateCurrentFamily(
                          livingStatus: peopleLivingStatuses[label],
                        );
                  },
                ),
                SizedBox(height: 18.h(context)),
                FormDropdownField(
                  label: 'نوع الإشغال',
                  items: peopleOccupancyTypes.keys.toList(),
                  value: peopleLabelForValue(
                    peopleOccupancyTypes,
                    unit?.occupancyType,
                    'ملك',
                  ),
                  onChanged: (label) {
                    if (label == null) return;
                    context.read<BuildingSurveyCubit>().updateCurrentFamily(
                          occupancyType: peopleOccupancyTypes[label],
                        );
                  },
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد العاطلين عن العمل',
                  hint: 'مثال: 1',
                  controller: unemployedCountController,
                  prefixIcon: Icons.work_off_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onSyncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد الطلاب',
                  hint: 'مثال: 2',
                  controller: studentsCountController,
                  prefixIcon: Icons.school_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onSyncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد أفراد العائلة',
                  hint: 'أدخل عدد أفراد العائلة',
                  controller: familyMembersCountController,
                  prefixIcon: Icons.groups_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onSyncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد القاطنين الفعلي',
                  hint: 'أدخل عدد القاطنين الفعلي',
                  controller: residentsCountController,
                  prefixIcon: Icons.home_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onSyncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'تكوين الأسرة',
                  hint: 'مثال: أب، أم، 3 أبناء',
                  controller: compositionController,
                  prefixIcon: Icons.account_tree_outlined,
                  maxLines: 3,
                  onChanged: (_) => onSyncText(),
                ),
                SizedBox(height: 18.h(context)),
                PeopleAidDateField(
                  value: unit?.lastAidDate ?? '',
                  onTap: onPickAidDate,
                ),
                SizedBox(height: 24.h(context)),
                PeopleVerificationBox(
                  isDataVerified: isDataVerified,
                  onChanged: (value) => context
                      .read<BuildingSurveyCubit>()
                      .updateCurrentFamily(isDataVerified: value),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h(context)),
        ],
      ),
    );
  }
}
