import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TransactionsHeaderCard extends StatelessWidget {
  const TransactionsHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryForest,
        borderRadius: BorderRadius.circular(16.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.s(context)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r(context)),
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              color: Colors.white,
              size: 26.ic(context),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مركز المعاملات والرخص',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'متابعة وإدارة معاملاتك البلدية ورخص المنشآت بدقة وسهولة',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.f(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w(context)),
          InkWell(
            onTap: () => context.push('/digital-documents'),
            borderRadius: BorderRadius.circular(12.r(context)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w(context),
                vertical: 6.h(context),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12.r(context)),
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFFFE082),
                    size: 16.ic(context),
                  ),
                  SizedBox(width: 4.w(context)),
                  Text(
                    'المحفظة',
                    style: TextStyle(
                      color: const Color(0xFFFFE082),
                      fontSize: 12.f(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
