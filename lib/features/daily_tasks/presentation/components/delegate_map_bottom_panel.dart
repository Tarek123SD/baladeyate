import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_widgets.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateMapBottomPanel extends StatelessWidget {
  const DelegateMapBottomPanel({
    super.key,
    required this.onLocateTap,
    required this.onSelectedPinAction,
  });

  final VoidCallback onLocateTap;
  final ValueChanged<SurveyPin> onSelectedPinAction;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: DelegateBottomNavigationBar.clearance(context) + 8.h(context),
      child: BlocSelector<DailyTasksCubit, DailyTasksState, SurveyPin?>(
        selector: (state) => state.selectedPin,
        builder: (context, selectedPin) {
          final hasSelection = selectedPin != null;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BlocSelector<
                      DailyTasksCubit,
                      DailyTasksState,
                      ({
                        bool isLocating,
                        bool isAddPinMode,
                        MapType mapType,
                      })>(
                    selector: (state) => (
                      isLocating: state.isLocating,
                      isAddPinMode: state.isAddPinMode,
                      mapType: state.mapType,
                    ),
                    builder: (context, controls) {
                      final cubit = context.read<DailyTasksCubit>();
                      final isHybrid = controls.mapType != MapType.normal;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DelegateMapControlButton(
                            icon: controls.isLocating
                                ? null
                                : AppIcons.myLocation,
                            isLoading: controls.isLocating,
                            tooltip: 'موقعي الحالي',
                            onTap: onLocateTap,
                          ),
                          SizedBox(height: 8.h(context)),
                          DelegateMapControlButton(
                            icon: isHybrid ? AppIcons.map : AppIcons.layers,
                            isActive: isHybrid,
                            tooltip: isHybrid
                                ? 'عرض الخريطة العادية'
                                : 'عرض القمر الصناعي',
                            onTap: cubit.toggleMapType,
                          ),
                          SizedBox(height: 8.h(context)),
                          DelegateMapControlButton(
                            icon: AppIcons.addLocation,
                            onTap: cubit.toggleAddPinMode,
                            isActive: controls.isAddPinMode,
                            tooltip: controls.isAddPinMode
                                ? 'إلغاء وضع الإضافة'
                                : 'إضافة نقطة مسح',
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  if (!hasSelection) const DelegateMapStatusLegend(),
                ],
              ),
              if (hasSelection) ...[
                SizedBox(height: 10.h(context)),
                DelegateSelectedPinCard(
                  pin: selectedPin,
                  onClose: () =>
                      context.read<DailyTasksCubit>().selectPin(null),
                  onAction: () => onSelectedPinAction(selectedPin),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
