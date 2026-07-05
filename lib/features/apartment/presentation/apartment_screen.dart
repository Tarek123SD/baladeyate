import 'package:baladeyate/features/delegate/cubits/delegate_survey_cubit/delegate_survey_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/image_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';

class ApartmentScreen extends StatefulWidget {
  const ApartmentScreen({super.key, this.surveyMode = false});

  final bool surveyMode;

  @override
  State<ApartmentScreen> createState() => ApartmentScreenState();
}

class ApartmentScreenState extends State<ApartmentScreen> {
  late TextEditingController _apartmentNumberController;
  late TextEditingController _apartmentTypeController;

  DelegateSurveyCubit? _surveyCubit;
  String? _selectedOccupancyStatus = 'مسكون'; // Default selected
  int _selectedRoomCount = 3; // Default selected

  @override
  void initState() {
    super.initState();
    if (widget.surveyMode) {
      _surveyCubit = context.read<DelegateSurveyCubit>();
    }
    final draft = _readDraft();
    _apartmentNumberController =
        TextEditingController(text: draft?.apartmentNumber ?? '402');
    _apartmentTypeController =
        TextEditingController(text: draft?.apartmentType ?? 'مكتبية - عائلية');
    _selectedOccupancyStatus = draft?.occupancyStatus ?? 'مسكون';
    _selectedRoomCount = draft?.roomCount ?? 3;

    if (widget.surveyMode) {
      _apartmentNumberController.addListener(_syncToCubit);
      _apartmentTypeController.addListener(_syncToCubit);
      _syncToCubit();
    }
  }

  void syncSurveyForm() => _syncToCubit();

  dynamic _readDraft() {
    if (_surveyCubit == null) return null;
    final state = _surveyCubit!.state;
    if (state is DelegateSurveyEditing) return state.draft;
    if (state is DelegateSurveyFailure) return state.draft;
    return null;
  }

  void _syncToCubit() {
    if (_surveyCubit == null) return;
    _surveyCubit!.updateApartment(
          apartmentNumber: _apartmentNumberController.text.trim(),
          apartmentType: _apartmentTypeController.text.trim(),
          occupancyStatus: _selectedOccupancyStatus,
          roomCount: _selectedRoomCount,
        );
  }

  @override
  void dispose() {
    if (widget.surveyMode) {
      _apartmentNumberController.removeListener(_syncToCubit);
      _apartmentTypeController.removeListener(_syncToCubit);
    }
    _apartmentNumberController.dispose();
    _apartmentTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundWhite),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InfoCard(
              icon: Icons.layers_outlined,
              title: 'الطابق',
              subtitle: widget.surveyMode
                  ? (_readDraft()?.floorNumber?.isNotEmpty == true
                      ? 'الطابق ${_readDraft()!.floorNumber}'
                      : 'الطابق الحالي')
                  : 'الطابق الرابع',
              iconColor: AppColors.primaryForest,
            ),
            InfoCard(
              icon: Icons.apartment_outlined,
              title: 'المبنى',
              subtitle: widget.surveyMode
                  ? (_readDraft()?.buildingName?.isNotEmpty == true
                      ? _readDraft()!.buildingName!
                      : 'مسح ميداني')
                  : 'برج البياسمين A1',
              iconColor: AppColors.primaryForest,
            ),
            FormSectionCard(
              title: 'تفاصيل الوحدة',
              badge: widget.surveyMode ? 'مسح ميداني' : 'قيد الإدخال',
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
        ),
      ],
    );
  }

  Widget _buildOccupancyButton(BuildContext context, String label) {
    final isSelected = _selectedOccupancyStatus == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedOccupancyStatus = label);
          _syncToCubit();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 10.h(context),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryForest
                : AppColors.thirdGoldenWheat.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r(context)),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryForest
                  : AppColors.secondaryGoldenWheat.withValues(alpha: 0.5),
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
          _syncToCubit();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h(context)),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryForest
                : AppColors.thirdGoldenWheat.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryForest
                  : AppColors.secondaryGoldenWheat.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.s(context),
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : AppColors.secondaryCharcoal,
            ),
          ),
        ),
      ),
    );
  }
}
