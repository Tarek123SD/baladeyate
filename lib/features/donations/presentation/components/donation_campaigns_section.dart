import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/widgets/custom_donation_campaign_card.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_state.dart';
import 'package:baladeyate/features/donations/models/donation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationCampaignsSection extends StatelessWidget {
  const DonationCampaignsSection({
    super.key,
    required this.onDonate,
  });

  final void Function(DonationModel donationCase) onDonate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonationsCubit, DonationsState>(
      builder: (context, state) {
        if (state is DonationsLoading || state is DonationsInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h(context)),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.pageProgress(context),
              ),
            ),
          );
        }

        if (state is DonationsFailure) {
          return DonationCampaignsErrorBox(
            message: state.message,
            onRetry: () => context.read<DonationsCubit>().loadCases(),
          );
        }

        if (state is DonationsLoaded) {
          final cases = state.cases;
          if (cases.isEmpty) {
            return const DonationCampaignsEmptyBox();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cases.length; i++) ...[
                if (i > 0) SizedBox(height: 16.h(context)),
                CustomDonationCampaignCard(
                  label: cases[i].categoryLabel,
                  title: cases[i].title,
                  subtitle: cases[i].description,
                  progress: cases[i].progress,
                  statusLabel: cases[i].statusLabel,
                  goalLabel: cases[i].goalLabel,
                  icon: cases[i].categoryIcon,
                  iconColor: cases[i].categoryColor,
                  onDonate: () => onDonate(cases[i]),
                ),
              ],
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class DonationCampaignsEmptyBox extends StatelessWidget {
  const DonationCampaignsEmptyBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 32.h(context),
        horizontal: 20.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r(context)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.donate,
            size: 40.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 12.h(context)),
          Text(
            'لا توجد حملات نشطة حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            'سيتم عرض الحملات هنا بمجرد إضافتها من لوحة التحكم',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5.f(context),
              color: const Color(0xFF757575),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class DonationCampaignsErrorBox extends StatelessWidget {
  const DonationCampaignsErrorBox({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 30.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 10.h(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h(context)),
          SizedBox(
            height: 42.h(context),
            child: OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryForest,
                side: const BorderSide(color: AppColors.primaryForest),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.s(context)),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 13.5.f(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
