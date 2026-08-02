import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class PeopleAidDateField extends StatelessWidget {
  const PeopleAidDateField({
    super.key,
    required this.value,
    required this.onTap,
  });

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'تاريخ آخر مساعدة (اختياري)',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 13.s(context),
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryCharcoal,
          ),
        ),
        SizedBox(height: 10.h(context)),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r(context)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w(context),
              vertical: 16.h(context),
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r(context)),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20.s(context),
                  color: Colors.grey[600],
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'اختر التاريخ' : value,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14.f(context),
                      color: value.isEmpty ? Colors.grey[600] : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
