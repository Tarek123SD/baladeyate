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
  bool _didFitToViewport = false;
  Size? _lastViewportSize;
  double? _lastMapWidth;
  double? _lastMapHeight;

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
          previous.successMessage != current.successMessage ||
          previous.mapWidth != current.mapWidth ||
          previous.mapHeight != current.mapHeight ||
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        final message = state.errorMessage ?? state.successMessage;
        if (message != null) {
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
        }

        if (!state.isLoading) {
          _scheduleFitToViewport(state.mapWidth, state.mapHeight);
        }
      },
      buildWhen: (previous, current) =>
          previous.graves != current.graves ||
          previous.isAddingMode != current.isAddingMode ||
          previous.isLoading != current.isLoading ||
          previous.isSubmitting != current.isSubmitting ||
          previous.mapUrl != current.mapUrl ||
          previous.mapWidth != current.mapWidth ||
          previous.mapHeight != current.mapHeight,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF111111),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewport = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    if (_lastViewportSize != viewport ||
                        _lastMapWidth != state.mapWidth ||
                        _lastMapHeight != state.mapHeight) {
                      _lastViewportSize = viewport;
                      _lastMapWidth = state.mapWidth;
                      _lastMapHeight = state.mapHeight;
                      _didFitToViewport = false;
                      if (!state.isLoading) {
                        _scheduleFitToViewport(
                          state.mapWidth,
                          state.mapHeight,
                          viewport: viewport,
                        );
                      }
                    }

                    return InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.05,
                      maxScale: 6.0,
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(80),
                      child: SizedBox(
                        width: state.mapWidth,
                        height: state.mapHeight,
                        child: Directionality(
                          // Absolute map coords must ignore app RTL layout.
                          textDirection: TextDirection.ltr,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              DroneImageLayer(
                                isAddingMode: state.isAddingMode,
                                onMapTap: _onMapTapped,
                                mapWidth: state.mapWidth,
                                mapHeight: state.mapHeight,
                                imageUrl: state.mapUrl,
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
                    );
                  },
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

  void _scheduleFitToViewport(
    double mapWidth,
    double mapHeight, {
    Size? viewport,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didFitToViewport) return;
      final size = viewport ?? _lastViewportSize;
      if (size == null || size.width <= 0 || size.height <= 0) return;
      if (mapWidth <= 0 || mapHeight <= 0) return;

      final scaleX = size.width / mapWidth;
      final scaleY = size.height / mapHeight;
      // Slightly smaller than "cover" so the full map is visible, matching admin ~45%.
      final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.05, 1.0);

      _transformationController.value = Matrix4.identity()
        ..scaleByDouble(scale, scale, 1, 1);
      _didFitToViewport = true;
    });
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
      useRootNavigator: true,
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
