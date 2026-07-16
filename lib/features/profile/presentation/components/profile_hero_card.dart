import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    required this.familyBook,
  });

  final String? familyBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.s(context)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryForest,
            AppColors.secondaryForest,
            AppColors.thirdForest,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: EdgeInsets.all(12.s(context)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r(context)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.home_work_rounded,
              color: Colors.white,
              size: 30.ic(context),
            ),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'سكني وأسرتي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.f(context),
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  'بيانات الأسرة المسجّلة في البلدية',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.f(context),
                    height: 1.5,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                if (familyBook != null && familyBook!.isNotEmpty) ...[
                  SizedBox(height: 12.h(context)),
                  _familyBookChip(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _familyBookChip(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.s(context),
        vertical: 6.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r(context)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: Colors.white.withValues(alpha: 0.9),
            size: 14.ic(context),
          ),
          SizedBox(width: 6.w(context)),
          Flexible(
            child: Text(
              'دفتر العائلة: ${familyBook ?? '—'}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.f(context),
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
