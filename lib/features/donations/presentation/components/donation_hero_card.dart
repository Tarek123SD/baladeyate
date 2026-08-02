import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_state.dart';
import 'package:baladeyate/features/donations/models/donation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationHeroCard extends StatelessWidget {
  const DonationHeroCard({
    super.key,
    required this.onDonate,
  });

  final void Function(Object extra) onDonate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonationsCubit, DonationsState>(
      builder: (context, state) {
        DonationModel? featuredCampaign;
        if (state is DonationsLoaded && state.cases.isNotEmpty) {
          featuredCampaign = state.cases.first;
        }

        final title = featuredCampaign?.title ?? 'إعادة إعمار المدارس التاريخية';
        final description = featuredCampaign?.description.isNotEmpty == true
            ? featuredCampaign!.description
            : 'ساهم في ترميم الصروح التعليمية التي تعيد بناء التاريخ وتضمن مستقبلاً مشرقاً لأجيالنا القادمة.';

        final isMobile = ResponsiveHelper.isMobile(context);
        final radius = 24.r(context);

        return Container(
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
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryForest.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              children: [
                Positioned(
                  top: -30.s(context),
                  left: -20.s(context),
                  child: _DecorCircle(size: 120.s(context), alpha: 0.08),
                ),
                Positioned(
                  bottom: -40.s(context),
                  left: 40.s(context),
                  child: _DecorCircle(size: 90.s(context), alpha: 0.06),
                ),
                Padding(
                  padding:
                      EdgeInsets.all(isMobile ? 20.s(context) : 24.s(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w(context),
                            vertical: 6.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18.r(context)),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            'حملة مميزة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.f(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h(context)),
                      Text(
                        title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 22.f(context) : 26.f(context),
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 10.h(context)),
                      Text(
                        description,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 13.5.f(context),
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 20.h(context)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: isMobile ? double.infinity : 180.w(context),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryForest,
                              elevation: 3,
                              padding: EdgeInsets.symmetric(
                                vertical: 14.h(context),
                                horizontal: 20.w(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(28.r(context)),
                              ),
                            ),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16.ic(context),
                              color: AppColors.primaryForest,
                            ),
                            label: Text(
                              'تصدق الآن',
                              style: TextStyle(
                                color: AppColors.primaryForest,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5.f(context),
                              ),
                            ),
                            onPressed: () => onDonate(
                              featuredCampaign ?? title,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({
    required this.size,
    required this.alpha,
  });

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        shape: BoxShape.circle,
      ),
    );
  }
}
