import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SignupTermsSection extends StatelessWidget {
  const SignupTermsSection({
    super.key,
    required this.agreeToTerms,
    required this.onToggle,
  });

  final bool agreeToTerms;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أوافق على شروط الاستخدام وسياسة الخصوصية الخاصة بالخدمات',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              SignupTermsCheckbox(checked: agreeToTerms),
              Expanded(
                child: Text(
                  'الرقمية السيادية.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SignupTermsCheckbox extends StatelessWidget {
  const SignupTermsCheckbox({
    super.key,
    required this.checked,
  });

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final boxSize = 22.s(context);

    return Container(
      width: boxSize,
      height: boxSize,
      margin: EdgeInsets.only(left: 10.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r(context)),
        border: Border.all(
          color: AppColors.primaryForest,
          width: 1.5,
        ),
      ),
      child: checked
          ? Center(
              child: Icon(
                Icons.check,
                size: 16.s(context),
                color: AppColors.green,
              ),
            )
          : null,
    );
  }
}
