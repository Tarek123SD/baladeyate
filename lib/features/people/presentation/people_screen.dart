import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';

class Resident {
  String name;
  String role;

  Resident({required this.name, required this.role});
}

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late TextEditingController _residentCountController;
  late TextEditingController _phoneController;
  late TextEditingController _residentNameController;
  late TextEditingController _residentRoleController;

  List<Resident> residents = [];
  bool _isDataVerified = false;

  @override
  void initState() {
    super.initState();
    _residentCountController = TextEditingController(text: '4');
    _phoneController = TextEditingController(text: '+966 50 123 4567');
    _residentNameController = TextEditingController();
    _residentRoleController = TextEditingController();

    // Initialize with sample residents
    residents = [
      Resident(name: 'أحمد محمد العتيبي', role: 'رئيس الأسرة'),
      Resident(name: 'سارة خالد الشمري', role: 'تابع'),
    ];
  }

  @override
  void dispose() {
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
    }
  }

  void _removeResident(int index) {
    setState(() {
      residents.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // References Row (Building, Floor, Apartment)
          SizedBox(
            height: 120.h(context),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                child: Row(
                  children: [
                    SizedBox(
                      width: 180.w(context),
                      child: InfoCard(
                        icon: Icons.apartment_outlined,
                        title: 'المبنى',
                        subtitle: 'A-102',
                        iconColor:
                            AppColors.primaryGoldenWheat.withValues(alpha: 0.2),
                      ),
                    ),
                    SizedBox(width: 12.w(context)),
                    SizedBox(
                      width: 180.w(context),
                      child: InfoCard(
                        icon: Icons.layers_outlined,
                        title: 'الطابق',
                        subtitle: 'الثالث',
                        iconColor:
                            AppColors.primaryGoldenWheat.withValues(alpha: 0.2),
                      ),
                    ),
                    SizedBox(width: 12.w(context)),
                    SizedBox(
                      width: 180.w(context),
                      child: InfoCard(
                        icon: Icons.door_front_door_outlined,
                        title: 'الشقة',
                        subtitle: '304',
                        iconColor:
                            AppColors.primaryGoldenWheat.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Residents List Card
          FormSectionCard(
            title: 'سجل القاطنين',
            badge: 'الخطوة الاخيرة',
            badgeColor: AppColors.primaryGoldenWheat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Resident Count with Icon
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'عدد السكان',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 13.s(context),
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryCharcoal,
                    ),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w(context),
                    vertical: 14.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r(context)),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 20.s(context),
                        color: AppColors.primaryForest,
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Text(
                          _residentCountController.text,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 16.s(context),
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h(context)),
                // Phone Number
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'رقم التواصل الرئيسي',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 13.s(context),
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryCharcoal,
                    ),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w(context),
                    vertical: 14.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r(context)),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 20.s(context),
                        color: AppColors.primaryForest,
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Text(
                          _phoneController.text,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 14.s(context),
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                // Data Verification Checkbox
                Container(
                  padding: EdgeInsets.all(12.w(context)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12.r(context)),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
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
                            color: AppColors.secondaryCharcoal,
                            height: 1.5,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r(context)),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Number Badge
            Container(
              width: 40.w(context),
              height: 40.w(context),
              decoration: BoxDecoration(
                color: isHeadOfFamily
                    ? AppColors.primaryForest
                    : const Color(0xFFE8E8E8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16.s(context),
                    fontWeight: FontWeight.w600,
                    color:
                        isHeadOfFamily ? Colors.white : const Color(0xFF999999),
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
                      color: const Color(0xFF999999),
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
      builder: (context) => AlertDialog(
        title: Text(
          'اضف ساكن جديد',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 16.s(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _residentNameController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  hintText: 'أدخل اسم الساكن',
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r(context)),
                  ),
                ),
              ),
              SizedBox(height: 12.h(context)),
              TextField(
                controller: _residentRoleController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'الصلة (اختياري)',
                  hintText: 'مثال: رئيس الأسرة',
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r(context)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
            ),
            onPressed: () {
              _addResident();
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
