import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/complaints/cubits/delegate_complaints_cubit/delegate_complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/delegate_complaints_cubit/delegate_complaints_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/presentation/components/delegate_complaint_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateComplaintsScreen extends StatelessWidget {
  const DelegateComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DelegateComplaintsCubit>()..fetch(),
      child: const _DelegateComplaintsView(),
    );
  }
}

class _DelegateComplaintsView extends StatelessWidget {
  const _DelegateComplaintsView();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundWhite),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(showBackButton: true),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocConsumer<DelegateComplaintsCubit, DelegateComplaintsState>(
              listener: (context, state) {
                if (state is DelegateComplaintsError) {
                  AppSnackBar.showError(context, state.message);
                }
              },
              builder: (context, state) {
                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () =>
                      context.read<DelegateComplaintsCubit>().fetch(),
                  child: ResponsiveBody(
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 8.h(context),
                              bottom: 16.h(context),
                            ),
                            child: Text(
                              'شكاوى الكشف الميداني',
                              style: TextStyle(
                                fontSize: 18.f(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (state is DelegateComplaintsLoading)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.pageProgress(context),
                              ),
                            ),
                          )
                        else if (state is DelegateComplaintsLoaded &&
                            state.complaints.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'لا توجد شكاوى بانتظار الكشف حالياً',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.f(context),
                                ),
                              ),
                            ),
                          )
                        else if (state is DelegateComplaintsLoaded)
                          SliverList.builder(
                            itemCount: state.complaints.length,
                            itemBuilder: (context, index) {
                              final complaint = state.complaints[index];
                              return DelegateComplaintTile(
                                complaint: complaint,
                                onOpen: () => _openDetails(context, complaint),
                              );
                            },
                          )
                        else
                          const SliverToBoxAdapter(child: SizedBox.shrink()),
                        SliverToBoxAdapter(
                          child: SizedBox(height: 24.h(context)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(
    BuildContext context,
    Complaint complaint,
  ) async {
    final cubit = context.read<DelegateComplaintsCubit>();
    final reported = await context.push<bool>(
      '/delegate/complaints/${complaint.id}',
      extra: complaint,
    );
    if (reported == true && context.mounted) {
      await cubit.fetch();
    }
  }
}
