import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_state.dart';
import 'package:baladeyate/features/donations/models/donation_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        if (state is DonationsLoading || state is DonationsInitial) {
          return const _HeroSkeleton();
        }

        if (state is! DonationsLoaded) {
          return const SizedBox.shrink();
        }

        final featuredCampaign = state.featuredCase;
        if (featuredCampaign == null) {
          return const SizedBox.shrink();
        }

        return _HeroContent(
          donation: featuredCampaign,
          onDonate: () => onDonate(featuredCampaign),
        );
      },
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.donation,
    required this.onDonate,
  });

  final DonationModel donation;
  final VoidCallback onDonate;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final radius = 24.r(context);
    final hasImage = donation.imageUrl.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
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
            if (hasImage)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: donation.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: AppColors.primaryForest,
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primaryForest.withValues(
                        alpha: hasImage ? 0.78 : 1,
                      ),
                      AppColors.secondaryForest.withValues(
                        alpha: hasImage ? 0.82 : 1,
                      ),
                      AppColors.thirdForest.withValues(
                        alpha: hasImage ? 0.88 : 1,
                      ),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
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
              padding: EdgeInsets.all(isMobile ? 20.s(context) : 24.s(context)),
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
                    donation.title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 22.f(context) : 26.f(context),
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  if (donation.description.trim().isNotEmpty) ...[
                    SizedBox(height: 10.h(context)),
                    Text(
                      donation.description,
                      textAlign: TextAlign.right,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13.5.f(context),
                        height: 1.6,
                      ),
                    ),
                  ],
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
                            borderRadius: BorderRadius.circular(28.r(context)),
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
                        onPressed: onDonate,
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
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    final radius = 24.r(context);

    return Container(
      height: 220.h(context),
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.contrastingProgress(
            AppColors.primaryForest.withValues(alpha: 0.12),
          ),
        ),
      ),
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
