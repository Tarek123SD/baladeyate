import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_track_complaint_card.dart';
import 'package:baladeyate/core/widgets/custom_track_filter_button.dart';
import 'package:baladeyate/core/widgets/custom_track_statistic_card.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:baladeyate/features/complaints/presentation/complaint_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TrackComplaintsScreen extends StatefulWidget {
  const TrackComplaintsScreen({super.key});

  @override
  State<TrackComplaintsScreen> createState() => _TrackComplaintsScreenState();
}

class _TrackComplaintsScreenState extends State<TrackComplaintsScreen> {
  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.isMobile ? 16.w(context) : 24.w(context);

    return BlocProvider(
      create: (_) => sl<ComplaintsCubit>()..loadComplaints(),
      child: BlocListener<ComplaintsCubit, ComplaintsState>(
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
              image: AssetImage('assets/images/background_white.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(),
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () {
                context.go('/complains');
              },
              backgroundColor: AppColors.green,
              child: const Icon(
                Icons.add,
                color: AppColors.thirdGoldenWheat,
              ),
            ),
            body: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 900.w(context)),
                    child: BlocBuilder<ComplaintsCubit, ComplaintsState>(
                      builder: (context, state) {
                        if (state is ComplaintsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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

                        final complaints = state.filtered(selectedFilter);

                        return RefreshIndicator(
                          onRefresh: () =>
                              context.read<ComplaintsCubit>().loadComplaints(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: 20.h(context),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(height: 14.h(context)),
                                  Center(
                                    child: Text(
                                      'مركز تتبع الشكاوي والمقترحات',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: AppColors.primaryForest,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: 12.h(context)),
                                  Text(
                                    'نلتزم بالشفافية و السرعة في معالجة طلباتكم لضمان جودة الخدمات العامة في كافة المحافظات.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: const Color(0xFF3A4B3F),
                                          height: 1.7,
                                        ),
                                  ),
                                  SizedBox(height: 24.h(context)),
                                  Row(
                                    children: [
                                      CustomTrackStatisticCard(
                                        title: 'إجمالي الشكاوى',
                                        value: '${state.totalCount} طلب',
                                        backgroundColor: Colors.white,
                                        textColor: const Color(0xFF1F3A2E),
                                      ),
                                      SizedBox(width: 12.w(context)),
                                      CustomTrackStatisticCard(
                                        title: 'قيد المعالجة',
                                        value: '${state.inProgressCount} طلب',
                                        backgroundColor: Colors.white,
                                        textColor: const Color(0xFF1F3A2E),
                                      ),
                                      SizedBox(width: 12.w(context)),
                                      CustomTrackStatisticCard(
                                        title: 'تم الحل',
                                        value: '${state.resolvedCount} طلب',
                                        backgroundColor:
                                            AppColors.primaryForest,
                                        textColor: Colors.white,
                                        icon: Icons.task_alt,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.h(context)),
                                  Row(
                                    children: [
                                      CustomTrackFilterButton(
                                        label: 'الكل',
                                        isSelected: selectedFilter == 0,
                                        onTap: () =>
                                            setState(() => selectedFilter = 0),
                                      ),
                                      SizedBox(width: 8.w(context)),
                                      CustomTrackFilterButton(
                                        label: 'قيد الانتظار',
                                        isSelected: selectedFilter == 1,
                                        onTap: () =>
                                            setState(() => selectedFilter = 1),
                                      ),
                                      SizedBox(width: 8.w(context)),
                                      CustomTrackFilterButton(
                                        label: 'مكتملة',
                                        isSelected: selectedFilter == 2,
                                        onTap: () =>
                                            setState(() => selectedFilter = 2),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.h(context)),
                                  if (complaints.isEmpty)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 32.h(context)),
                                      child: Center(
                                        child: Text(
                                          'لا توجد شكاوى حالياً',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color:
                                                    AppColors.secondaryCharcoal,
                                              ),
                                        ),
                                      ),
                                    )
                                  else
                                    Column(
                                      children: complaints.map((complaint) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 16.h(context),
                                          ),
                                          child: CustomTrackComplaintCard(
                                            complaint:
                                                complaint.toTrackCardMap(),
                                            onTap: () => showComplaintDetailSheet(
                                              context,
                                              complaint: complaint,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
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
