import 'package:baladeyate/features/delegate/cubits/delegate_survey_cubit/delegate_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/survey_resident.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';

class Resident {
  String name;
  String role;

  Resident({required this.name, required this.role});
}

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key, this.surveyMode = false});

  final bool surveyMode;

  @override
  State<PeopleScreen> createState() => PeopleScreenState();
}

class PeopleScreenState extends State<PeopleScreen> {
  late TextEditingController _residentCountController;
  late TextEditingController _phoneController;
  late TextEditingController _residentNameController;
  late TextEditingController _residentRoleController;

  DelegateSurveyCubit? _surveyCubit;
  List<Resident> residents = [];
  bool _isDataVerified = false;

  @override
  void initState() {
    super.initState();
    if (widget.surveyMode) {
      _surveyCubit = context.read<DelegateSurveyCubit>();
    }
    final draft = _readDraft();
    _residentCountController =
        TextEditingController(text: draft?.residentCount ?? '4');
    _phoneController = TextEditingController(text: draft?.phone ?? '');
    _residentNameController = TextEditingController();
    _residentRoleController = TextEditingController();
    _isDataVerified = draft?.isDataVerified ?? false;

    residents = widget.surveyMode && draft != null && draft.residents.isNotEmpty
        ? draft.residents
            .map((item) => Resident(name: item.name, role: item.role))
            .toList()
        : [
            Resident(name: 'أحمد محمد العتيبي', role: 'رئيس الأسرة'),
            Resident(name: 'سارة خالد الشمري', role: 'تابع'),
          ];

    if (widget.surveyMode) {
      _residentCountController.addListener(_syncToCubit);
      _phoneController.addListener(_syncToCubit);
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
    _surveyCubit!.updateFamily(
          residentCount: _residentCountController.text.trim(),
          phone: _phoneController.text.trim(),
          residents: residents
              .map((resident) => SurveyResident(
                    name: resident.name,
                    role: resident.role,
                  ))
              .toList(),
          isDataVerified: _isDataVerified,
        );
  }

  @override
  void dispose() {
    if (widget.surveyMode) {
      _residentCountController.removeListener(_syncToCubit);
      _phoneController.removeListener(_syncToCubit);
    }
    _residentCountController.dispose();
    _phoneController.dispose();
    _residentNameController.dispose();
    _residentRoleController.dispose();
    super.dispose();
  }

  void _addResident() {
    if (_residentNameController.text.isNotEmpty) {
      setState(() {
        residents.add(
          Resident(
            name: _residentNameController.text,
            role: _residentRoleController.text.isEmpty
                ? 'تابع'
                : _residentRoleController.text,
          ),
        );
        _residentNameController.clear();
        _residentRoleController.clear();
      });
      _syncToCubit();
    }
  }

  void _removeResident(int index) {
    setState(() {
      residents.removeAt(index);
    });
    _syncToCubit();
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
              icon: Icons.apartment_outlined,
              title: 'المبنى',
              subtitle: widget.surveyMode
                  ? (_readDraft()?.buildingName ?? 'مسح ميداني')
                  : 'A-102',
              iconColor: AppColors.primaryForest,
            ),
            InfoCard(
              icon: Icons.layers_outlined,
              title: 'الطابق',
              subtitle: widget.surveyMode
                  ? (_readDraft()?.floorNumber ?? '—')
                  : 'الثالث',
              iconColor: AppColors.primaryForest,
            ),
            InfoCard(
              icon: Icons.door_front_door_outlined,
              title: 'الشقة',
              subtitle: widget.surveyMode
                  ? (_readDraft()?.apartmentNumber ?? '—')
                  : '304',
              iconColor: AppColors.primaryForest,
            ),
            FormSectionCard(
              title: 'سجل القاطنين',
              badge: 'الخطوة الأخيرة',
              badgeColor: AppColors.primaryGoldenWheat,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormInputField(
                    label: 'عدد السكان',
                    hint: 'أدخل عدد السكان',
                    controller: _residentCountController,
                    prefixIcon: Icons.people_outline,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 18.h(context)),
                  FormInputField(
                    label: 'رقم التواصل الرئيسي',
                    hint: 'أدخل رقم الهاتف',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 24.h(context)),
                // Residents List Header
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showAddResidentDialog(context);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 18.s(context),
                              color: AppColors.primaryForest,
                            ),
                            SizedBox(width: 8.w(context)),
                            Text(
                              'اضف ساكن',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 12.s(context),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryForest,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w(context)),
                      Text(
                        'قائمة الاسماء',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 14.s(context),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h(context)),
                // Residents List
                ...List.generate(
                  residents.length,
                  (index) => _buildResidentCard(context, index),
                ),
                SizedBox(height: 24.h(context)),
                Container(
                  padding: EdgeInsets.all(12.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.thirdGoldenWheat.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12.r(context)),
                    border: Border.all(
                      color: AppColors.secondaryGoldenWheat
                          .withValues(alpha: 0.45),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: _isDataVerified,
                          onChanged: (value) {
                            setState(() => _isDataVerified = value ?? false);
                            _syncToCubit();
                          },
                          activeColor: AppColors.primaryForest,
                          side: BorderSide(
                            color: AppColors.primaryForest,
                            width: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Text(
                          'أقر بصحة البيانات المسجلة أعلاه وبأن كافة المعلومات تعكس الواقع الفعلي للسكان في الوحدة السكنية المحددة.',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 12.s(context),
                            color: AppColors.primaryForest,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildResidentCard(BuildContext context, int index) {
    final resident = residents[index];
    final isHeadOfFamily = resident.role == 'رئيس الأسرة';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h(context)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w(context),
          vertical: 14.h(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16.r(context)),
          border: Border.all(
            color: isHeadOfFamily
                ? AppColors.primaryForest.withValues(alpha: 0.25)
                : AppColors.secondaryGoldenWheat.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.w(context),
              height: 40.w(context),
              decoration: BoxDecoration(
                color: isHeadOfFamily
                    ? AppColors.primaryForest
                    : AppColors.secondaryForest.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16.s(context),
                    fontWeight: FontWeight.w600,
                    color: isHeadOfFamily
                        ? Colors.white
                        : AppColors.primaryForest,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w(context)),
            // Resident Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    resident.name,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.s(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryCharcoal,
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    resident.role,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.s(context),
                      color: AppColors.primaryGoldenWheat,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w(context)),
            // Delete Button
            GestureDetector(
              onTap: () => _removeResident(index),
              child: Icon(
                Icons.delete_outline,
                size: 20.s(context),
                color: const Color(0xFFE74C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddResidentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r(context)),
        ),
        title: Text(
          'أضف ساكن جديد',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 16.s(context),
            fontWeight: FontWeight.w700,
            color: AppColors.primaryForest,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormInputField(
                label: 'الاسم',
                hint: 'أدخل اسم الساكن',
                controller: _residentNameController,
                prefixIcon: Icons.person_outline,
              ),
              SizedBox(height: 12.h(context)),
              FormInputField(
                label: 'الصلة (اختياري)',
                hint: 'مثال: رئيس الأسرة',
                controller: _residentRoleController,
                prefixIcon: Icons.badge_outlined,
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.secondaryCharcoal),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
            ),
            onPressed: () {
              _addResident();
              Navigator.pop(dialogContext);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
