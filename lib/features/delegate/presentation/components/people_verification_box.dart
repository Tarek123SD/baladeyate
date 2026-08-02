import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class PeopleVerificationBox extends StatelessWidget {
  const PeopleVerificationBox({
    super.key,
    required this.isDataVerified,
    required this.onChanged,
  });

  final bool isDataVerified;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w(context)),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12.r(context)),
        border: Border.all(
          color: AppColors.secondaryGoldenWheat.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isDataVerified,
              onChanged: (value) => onChanged(value ?? false),
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
              'أقر بصحة البيانات المسجلة أعلاه وبأن كافة المعلومات تعكس الواقع الفعلي للأسرة في الوحدة السكنية المحددة.',
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
    );
  }
}
