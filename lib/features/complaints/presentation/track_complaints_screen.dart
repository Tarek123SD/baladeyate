import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/presentation/complaint_details_screen.dart';
import 'package:baladeyate/features/complaints/presentation/components/track_complaint_card.dart';
import 'package:baladeyate/features/complaints/presentation/components/track_complaints_empty_state.dart';
import 'package:baladeyate/features/complaints/presentation/components/track_complaints_error_section.dart';
import 'package:baladeyate/features/complaints/presentation/components/track_complaints_filters.dart';
import 'package:baladeyate/features/complaints/presentation/components/track_complaints_header_card.dart';
import 'package:baladeyate/features/complaints/presentation/components/track_complaints_list_header.dart';
import 'package:baladeyate/features/complaints/presentation/components/track_complaints_stats.dart';
import 'package:baladeyate/routes/app_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TrackComplaintsScreen extends StatefulWidget {
  const TrackComplaintsScreen({super.key});

  @override
  State<TrackComplaintsScreen> createState() => _TrackComplaintsScreenState();
}

class _TrackComplaintsScreenState extends State<TrackComplaintsScreen>
    with RouteAware {
  static const _trackShellIndex = 2;

  bool _routeSubscribed = false;
  int? _lastShellIndex;

  @override
  void initState() {
    super.initState();
    ComplaintsCubit.listVersion.addListener(_reloadComplaints);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      final index = shell.currentIndex;
      if (index == _trackShellIndex &&
          _lastShellIndex != null &&
          _lastShellIndex != _trackShellIndex) {
        _reloadComplaints();
      }
      _lastShellIndex = index;
    }

    if (_routeSubscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void didPopNext() => _reloadComplaints();

  void _reloadComplaints() {
    if (!mounted) return;
    context.read<ComplaintsCubit>().loadComplaints();
  }

  @override
  void dispose() {
    ComplaintsCubit.listVersion.removeListener(_reloadComplaints);
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

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
                            child: TrackComplaintsErrorSection(
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
                                    const TrackComplaintsHeaderCard()
                                        .animate()
                                        .fadeIn(duration: 300.ms)
                                        .slideY(begin: -0.05, end: 0),
                                    SizedBox(height: 14.h(context)),
                                    TrackComplaintsStats(state: state)
                                        .animate()
                                        .fadeIn(duration: 300.ms, delay: 60.ms),
                                    SizedBox(height: 16.h(context)),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TrackComplaintsFilters(
                                      selectedFilter: selectedFilter,
                                    ),
                                    SizedBox(height: 16.h(context)),
                                    TrackComplaintsListHeader(
                                      count: complaints.length,
                                    ),
                                    SizedBox(height: 12.h(context)),
                                  ],
                                ),
                              ),
                            ),
                            if (complaints.isEmpty)
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                sliver: const SliverToBoxAdapter(
                                  child: TrackComplaintsEmptyState(),
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
                                      return TrackComplaintCard(
                                        complaint: complaint,
                                        onTap: () => _openComplaintDetails(
                                          context,
                                          complaint,
                                        ),
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
}
