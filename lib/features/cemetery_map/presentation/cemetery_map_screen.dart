import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_cubit.dart';
import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_state.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/add_grave_dialog.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/adding_mode_banner.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/cemetery_map_loading_overlay.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/cemetery_snack_bar_content.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/drone_image_layer.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/grave_details_sheet.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/grave_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Interactive cemetery map with pan/zoom over a drone orthophoto overlay.
class CemeteryMapScreen extends StatefulWidget {
  const CemeteryMapScreen({super.key});

  @override
  State<CemeteryMapScreen> createState() => _CemeteryMapScreenState();
}

class _CemeteryMapScreenState extends State<CemeteryMapScreen> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CemeteryMapCubit, CemeteryMapState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.successMessage;
        if (message == null) return;

        final isError = state.errorMessage != null;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              elevation: 6,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              duration: const Duration(seconds: 3),
              content: CemeterySnackBarContent(
                message: message,
                isError: isError,
              ),
            ),
          );
        context.read<CemeteryMapCubit>().clearMessages();
      },
      buildWhen: (previous, current) =>
          previous.graves != current.graves ||
          previous.isAddingMode != current.isAddingMode ||
          previous.isLoading != current.isLoading ||
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(showBackButton: true),
          floatingActionButton: FloatingActionButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.read<CemeteryMapCubit>().toggleAddingMode(),
            backgroundColor: state.isAddingMode
                ? AppColors.primaryGoldenWheat
                : AppColors.primaryForest,
            tooltip:
                state.isAddingMode ? 'إلغاء وضع الإضافة' : 'إضافة قبر جديد',
            child: Icon(
              state.isAddingMode
                  ? Icons.close_rounded
                  : AppIcons.addLocation,
              color: Colors.white,
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1,
                  maxScale: 4.0,
                  constrained: false,
                  child: SizedBox(
                    width: mapWidth,
                    height: mapHeight,
                    child: Directionality(
                      // Absolute map coords must ignore app RTL layout.
                      textDirection: TextDirection.ltr,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          DroneImageLayer(
                            isAddingMode: state.isAddingMode,
                            onMapTap: _onMapTapped,
                          ),
                          ...state.graves.map(
                            (grave) => Positioned(
                              left: grave.x,
                              top: grave.y,
                              width: grave.width,
                              height: grave.height,
                              child: GraveMarker(
                                key: ValueKey('grave-${grave.id}'),
                                grave: grave,
                                onTap: state.isAddingMode
                                    ? null
                                    : () => _showGraveDetails(grave),
                              ),
                            ),
                          ),
                          if (state.isLoading || state.isSubmitting)
                            Positioned.fill(
                              child: CemeteryMapLoadingOverlay(
                                showLoadingMessage: state.isLoading,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.isAddingMode)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AddingModeBanner(),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMapTapped(Offset localPosition) async {
    final cubit = context.read<CemeteryMapCubit>();
    if (!cubit.state.isAddingMode || cubit.state.isSubmitting) return;

    const defaultWidth = GraveModel.defaultGraveWidth;
    const defaultHeight = GraveModel.defaultGraveHeight;
    final centeredX = localPosition.dx - (defaultWidth / 2);
    final centeredY = localPosition.dy - (defaultHeight / 2);

    final result = await showDialog<AddGraveDialogResult>(
      context: context,
      builder: (dialogContext) => AddGraveDialog(
        x: centeredX,
        y: centeredY,
        width: defaultWidth,
        height: defaultHeight,
      ),
    );

    if (result == null || !mounted) return;

    await cubit.createGraveAt(
      x: centeredX,
      y: centeredY,
      width: defaultWidth,
      height: defaultHeight,
      status: result.status,
      deceasedName: result.deceasedName,
    );
  }

  void _showGraveDetails(GraveModel grave) {
    final deceasedName = grave.deceasedName?.trim();
    final showDeceasedName = grave.status == 'occupied' &&
        deceasedName != null &&
        deceasedName.isNotEmpty;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return GraveDetailsSheet(
          grave: grave,
          deceasedName: showDeceasedName ? deceasedName : null,
        );
      },
    );
  }
}
