import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_track_complaint_card.dart';
import 'package:baladeyate/core/widgets/custom_track_filter_button.dart';
import 'package:baladeyate/core/widgets/custom_track_statistic_card.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/presentation/complaint_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TrackComplaintsScreen extends StatelessWidget {
  const TrackComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocListener<ComplaintsCubit, ComplaintsState>(
      listener: (context, state) {
        if (state is ComplaintsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.backgroundWhite),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          backgroundColor: Colors.transparent,
          appBar: const CustomAppBar(),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: null,
            onPressed: () => context.push('/complains'),
            backgroundColor: AppColors.green,
            icon: const Icon(Icons.add, color: AppColors.thirdGoldenWheat),
            label: Text(
              'شكوى جديدة',
              style: TextStyle(
                color: AppColors.thirdGoldenWheat,
                fontWeight: FontWeight.w700,
                fontSize: 13.f(context),
              ),
            ),
          ),
          body: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 900.w(context)),
                  child: BlocBuilder<ComplaintsCubit, ComplaintsState>(
                    buildWhen: (previous, current) =>
                        previous.runtimeType != current.runtimeType ||
                        (previous is ComplaintsLoaded &&
                            current is ComplaintsLoaded &&
                            (previous.complaints != current.complaints ||
                                previous.selectedFilterIndex !=
                                    current.selectedFilterIndex)),
                    builder: (context, state) {
                      if (state is ComplaintsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ComplaintsFailure) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: _buildErrorSection(
                              context,
                              message: state.message,
                              onRetry: () => context
                                  .read<ComplaintsCubit>()
                                  .loadComplaints(),
                            ),
                          ),
                        );
                      }

                      if (state is! ComplaintsLoaded) {
                        return const SizedBox.shrink();
                      }

                      final complaints = state.filtered();
                      final selectedFilter = state.selectedFilterIndex;

                      return RefreshIndicator(
                        color: AppColors.primaryForest,
                        onRefresh: () =>
                            context.read<ComplaintsCubit>().loadComplaints(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 16.h(context),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeaderCard(context)
                                    .animate()
                                    .fadeIn(duration: 350.ms)
                                    .slideY(begin: -0.1, end: 0),
                                SizedBox(height: 20.h(context)),
                                _buildStats(context, state).animate().fadeIn(
                                      duration: 350.ms,
                                      delay: 80.ms,
                                    ),
                                SizedBox(height: 22.h(context)),
                                _buildFilters(context, selectedFilter),
                                SizedBox(height: 20.h(context)),
                                _buildListHeader(context, complaints.length),
                                SizedBox(height: 12.h(context)),
                                if (complaints.isEmpty)
                                  _buildEmptyState(context)
                                else
                                  _buildComplaintsList(context, complaints),
                                SizedBox(height: 80.h(context)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
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
              Icons.track_changes_rounded,
              color: Colors.white,
              size: 30.ic(context),
            ),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مركز تتبع الشكاوى والمقترحات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.f(context),
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  'نلتزم بالشفافية والسرعة في معالجة طلباتكم لضمان جودة الخدمات العامة.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.f(context),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, ComplaintsLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          CustomTrackStatisticCard(
            title: 'إجمالي الشكاوى',
            value: '${state.totalCount} طلب',
            backgroundColor: Colors.white,
            textColor: const Color(0xFF1F3A2E),
            icon: Icons.list_alt_rounded,
          ),
          CustomTrackStatisticCard(
            title: 'قيد المعالجة',
            value: '${state.inProgressCount} طلب',
            backgroundColor: Colors.white,
            textColor: const Color(0xFF1F3A2E),
            icon: Icons.timelapse_rounded,
          ),
          CustomTrackStatisticCard(
            title: 'تم الحل',
            value: '${state.resolvedCount} طلب',
            backgroundColor: Colors.white,
            textColor: const Color(0xFF1F3A2E),
            icon: Icons.task_alt_rounded,
          ),
        ];

        // On very narrow screens stack the stats 1 + 2 for readability.
        if (constraints.maxWidth < 340.w(context)) {
          return Column(
            children: [
              Row(children: [cards[0]]),
              SizedBox(height: 12.h(context)),
              Row(
                children: [
                  cards[1],
                  SizedBox(width: 12.w(context)),
                  cards[2],
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            cards[0],
            SizedBox(width: 12.w(context)),
            cards[1],
            SizedBox(width: 12.w(context)),
            cards[2],
          ],
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, int selectedFilter) {
    return Container(
      padding: EdgeInsets.all(6.s(context)),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(26.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          CustomTrackFilterButton(
            label: 'الكل',
            isSelected: selectedFilter == 0,
            onTap: () => context.read<ComplaintsCubit>().setFilter(0),
          ),
          SizedBox(width: 6.w(context)),
          CustomTrackFilterButton(
            label: 'قيد الانتظار',
            isSelected: selectedFilter == 1,
            onTap: () => context.read<ComplaintsCubit>().setFilter(1),
          ),
          SizedBox(width: 6.w(context)),
          CustomTrackFilterButton(
            label: 'مكتملة',
            isSelected: selectedFilter == 2,
            onTap: () => context.read<ComplaintsCubit>().setFilter(2),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, int count) {
    return Row(
      children: [
        Container(
          width: 5.w(context),
          height: 20.h(context),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          'قائمة الشكاوي',
          style: TextStyle(
            fontSize: 16.f(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryForest,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 5.h(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryForest.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r(context)),
          ),
          child: Text(
            '$count نتيجة',
            style: TextStyle(
              fontSize: 12.f(context),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryForest,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintsList(
    BuildContext context,
    List<Complaint> complaints,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h(context)),
          child: CustomTrackComplaintCard(
            complaint: complaint.toTrackCardMap(),
            onTap: () => showComplaintDetailSheet(
              context,
              complaint: complaint,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (40 * index).ms)
            .slideY(begin: 0.08, end: 0);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 40.h(context),
        horizontal: 20.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.s(context)),
            decoration: BoxDecoration(
              color: AppColors.thirdGoldenWheat.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 40.ic(context),
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            'لا توجد شكاوى حالياً',
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'يمكنك تقديم شكوى جديدة عبر زر "شكوى جديدة".',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.thirdGoldenWheat.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h(context)),
          SizedBox(
            height: 44.h(context),
            child: OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryForest,
                backgroundColor:
                    AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
                side: BorderSide(
                  color: AppColors.primaryForest.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.s(context)),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
