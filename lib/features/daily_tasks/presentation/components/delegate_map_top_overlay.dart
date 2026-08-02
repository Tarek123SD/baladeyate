import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_header.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_widgets.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateMapTopOverlay extends StatelessWidget {
  const DelegateMapTopOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8.h(context),
            horizontalPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocSelector<DailyTasksCubit, DailyTasksState,
                  ({int totalTasks, int completedTasks})>(
                selector: (state) => (
                  totalTasks: state.totalTasks,
                  completedTasks: state.completedTasks,
                ),
                builder: (context, stats) {
                  return DelegateMapHeader(
                    completedTasks: stats.completedTasks,
                    totalTasks: stats.totalTasks,
                  );
                },
              ),
              SizedBox(height: 8.h(context)),
              BlocSelector<DailyTasksCubit, DailyTasksState, SurveyPinStatus?>(
                selector: (state) => state.pinStatusFilter,
                builder: (context, filter) {
                  return DelegateMapFilterChips(
                    selected: filter,
                    onChanged:
                        context.read<DailyTasksCubit>().setPinStatusFilter,
                  );
                },
              ),
              BlocSelector<DailyTasksCubit, DailyTasksState,
                  ({bool isAddPinMode, String? locationMessage})>(
                selector: (state) => (
                  isAddPinMode: state.isAddPinMode,
                  locationMessage: state.locationMessage,
                ),
                builder: (context, banners) {
                  if (banners.isAddPinMode) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h(context)),
                      child: DelegateAddPinBanner(
                        onCancel: () =>
                            context.read<DailyTasksCubit>().toggleAddPinMode(),
                      ),
                    );
                  }
                  if (banners.locationMessage != null) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h(context)),
                      child: DelegateLocationBanner(
                        message: banners.locationMessage!,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
