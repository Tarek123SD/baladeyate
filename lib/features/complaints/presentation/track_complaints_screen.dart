import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/presentation/complaint_details_screen.dart';
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
    final primaryColor = Theme.of(context).colorScheme.primary;

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
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor: Colors.transparent,
          appBar: const CustomAppBar(),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: null,
            onPressed: () => context.push('/complains'),
            backgroundColor: primaryColor,
            elevation: 3,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'شكوى جديدة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
                        color: primaryColor,
                        onRefresh: () =>
                            context.read<ComplaintsCubit>().loadComplaints(),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            // 1. Top Header & Stats (SliverToBoxAdapter)
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                16.h(context),
                                horizontalPadding,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildHeaderCard(context)
                                        .animate()
                                        .fadeIn(duration: 300.ms)
                                        .slideY(begin: -0.05, end: 0),
                                    SizedBox(height: 14.h(context)),
                                    _buildStats(context, state)
                                        .animate()
                                        .fadeIn(duration: 300.ms, delay: 60.ms),
                                    SizedBox(height: 16.h(context)),
                                  ],
                                ),
                              ),
                            ),

                            // 2. Filter Chips & Section Header (SliverToBoxAdapter)
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildFilters(context, selectedFilter),
                                    SizedBox(height: 16.h(context)),
                                    _buildListHeader(context, complaints.length),
                                    SizedBox(height: 12.h(context)),
                                  ],
                                ),
                              ),
                            ),

                            // 3. Complaint Cards List (SliverList)
                            if (complaints.isEmpty)
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildEmptyState(context),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final complaint = complaints[index];
                                      return _buildComplaintCard(
                                        context,
                                        complaint,
                                      )
                                          .animate()
                                          .fadeIn(
                                            duration: 250.ms,
                                            delay: (30 * index).ms,
                                          )
                                          .slideY(begin: 0.05, end: 0);
                                    },
                                    childCount: complaints.length,
                                  ),
                                ),
                              ),

                            // Bottom spacing for FAB & bottom nav bar clearance
                            SliverToBoxAdapter(
                              child: SizedBox(height: 80.h(context)),
                            ),
                          ],
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

  /// Compact Header Card with Radius 16 and dark green container
  Widget _buildHeaderCard(BuildContext context) {
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
              Icons.track_changes_rounded,
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
                  'مركز تتبع الشكاوى',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'متابعة فورية ومباشرة لحالة بلاغاتك ومعالجتها',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.f(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact Summary Cards ("إجمالي", "قيد المعالجة", "تم الحل")
  Widget _buildStats(BuildContext context, ComplaintsLoaded state) {
    final items = [
      (
        title: 'إجمالي',
        value: '${state.totalCount}',
        color: AppColors.primaryForest,
        icon: Icons.assignment_outlined,
      ),
      (
        title: 'قيد المعالجة',
        value: '${state.inProgressCount}',
        color: const Color(0xFFB26A00),
        icon: Icons.timelapse_rounded,
      ),
      (
        title: 'تم الحل',
        value: '${state.resolvedCount}',
        color: const Color(0xFF1B7B3A),
        icon: Icons.task_alt_rounded,
      ),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w(context)),
            padding: EdgeInsets.symmetric(
              horizontal: 10.w(context),
              vertical: 10.h(context),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r(context)),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 11.f(context),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Icon(item.icon, size: 16.ic(context), color: item.color),
                  ],
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 17.f(context),
                    fontWeight: FontWeight.bold,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Filter Chips ("الكل", "قيد الانتظار", "مكتملة") using sleek ChoiceChips
  Widget _buildFilters(BuildContext context, int selectedFilter) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final filters = [
      (index: 0, label: 'الكل'),
      (index: 1, label: 'قيد الانتظار'),
      (index: 2, label: 'مكتملة'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter.index;
          return Padding(
            padding: EdgeInsets.only(left: 8.w(context)),
            child: ChoiceChip(
              label: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12.f(context),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) {
                context.read<ComplaintsCubit>().setFilter(filter.index);
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? primaryColor : Colors.grey.shade300,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r(context)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12.w(context),
                vertical: 6.h(context),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, int count) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 4.w(context),
          height: 16.h(context),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          'قائمة الشكاوي',
          style: TextStyle(
            fontSize: 15.f(context),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w(context),
            vertical: 4.h(context),
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
          child: Text(
            '$count نتيجة',
            style: TextStyle(
              fontSize: 12.f(context),
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _openComplaintDetails(BuildContext context, Complaint complaint) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ComplaintsCubit>(),
          child: ComplaintDetailsScreen(complaint: complaint),
        ),
      ),
    );
  }

  /// Completely redesigned Complaint Card with exact ticketing specs
  Widget _buildComplaintCard(BuildContext context, Complaint complaint) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: InkWell(
          onTap: () => _openComplaintDetails(context, complaint),
          borderRadius: BorderRadius.circular(16.r(context)),
          child: Padding(
            padding: EdgeInsets.all(16.s(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ROW 1 (Header): Title & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        complaint.displayTitle,
                        style: TextStyle(
                          fontSize: 15.f(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w(context),
                        vertical: 6.h(context),
                      ),
                      decoration: BoxDecoration(
                        color: complaint.statusBackground,
                        borderRadius: BorderRadius.circular(8.r(context)),
                      ),
                      child: Text(
                        complaint.statusText,
                        style: TextStyle(
                          color: complaint.statusForeground,
                          fontSize: 12.f(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h(context)),

                // ROW 2 (Meta Info): Ticket Number, Separator, Date
                Row(
                  children: [
                    Text(
                      '#${complaint.id}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.f(context),
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.f(context),
                      ),
                    ),
                    Text(
                      complaint.formattedDate,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13.f(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h(context)),

                // ROW 3 (Description)
                Text(
                  complaint.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.f(context),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // DIVIDER
                SizedBox(height: 12.h(context)),
                Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                  thickness: 1,
                ),
                SizedBox(height: 12.h(context)),

                // ROW 4 (Footer - Tags & Action)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Right side (Leading): Tags
                    Row(
                      children: [
                        if (complaint.priority == 'urgent')
                          Padding(
                            padding: EdgeInsets.only(left: 6.w(context)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w(context),
                                vertical: 4.h(context),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius:
                                    BorderRadius.circular(6.r(context)),
                              ),
                              child: Text(
                                'طارئ',
                                style: TextStyle(
                                  color: const Color(0xFFC62828),
                                  fontSize: 11.f(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        else if (complaint.priorityText.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 6.w(context)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w(context),
                                vertical: 4.h(context),
                              ),
                              decoration: BoxDecoration(
                                color: complaint.priorityColor
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(6.r(context)),
                              ),
                              child: Text(
                                complaint.priorityText,
                                style: TextStyle(
                                  color: complaint.priorityColor,
                                  fontSize: 11.f(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (complaint.aiCategory != null &&
                            complaint.aiCategory!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w(context),
                              vertical: 4.h(context),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius:
                                  BorderRadius.circular(6.r(context)),
                            ),
                            child: Text(
                              complaint.aiCategory!,
                              style: TextStyle(
                                color: const Color(0xFF2E7D32),
                                fontSize: 11.f(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Left side (Trailing): "التفاصيل" with chevron_left icon
                    InkWell(
                      onTap: () => _openComplaintDetails(context, complaint),
                      borderRadius: BorderRadius.circular(4.r(context)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'التفاصيل',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.f(context),
                            ),
                          ),
                          SizedBox(width: 2.w(context)),
                          Icon(
                            Icons.chevron_left,
                            color: primaryColor,
                            size: 20.ic(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
