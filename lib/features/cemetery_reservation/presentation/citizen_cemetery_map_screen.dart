import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_cubit.dart';
import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_state.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/cemetery_map_loading_overlay.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/drone_image_layer.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/grave_marker.dart';
import 'package:baladeyate/features/cemetery_reservation/presentation/components/citizen_grave_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Citizen map — available graves only, tap to start reservation.
class CitizenCemeteryMapScreen extends StatefulWidget {
  const CitizenCemeteryMapScreen({super.key});

  @override
  State<CitizenCemeteryMapScreen> createState() =>
      _CitizenCemeteryMapScreenState();
}

class _CitizenCemeteryMapScreenState extends State<CitizenCemeteryMapScreen> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    context.read<CemeteryMapCubit>().loadAvailableGraves();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _onGraveTap(GraveModel grave) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CitizenGraveDetailsSheet(
        grave: grave,
        onReserve: () {
          Navigator.of(context).pop();
          context.push('/cemetery/reserve', extra: grave);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CemeteryMapCubit, CemeteryMapState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF111111),
          appBar: const CustomAppBar(showBackButton: true),
          body: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.05,
                  maxScale: 6,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: SizedBox(
                    width: state.mapWidth,
                    height: state.mapHeight,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          DroneImageLayer(
                            isAddingMode: false,
                            onMapTap: (_) {},
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
                                key: ValueKey('citizen-grave-${grave.id}'),
                                grave: grave,
                                onTap: () => _onGraveTap(grave),
                              ),
                            ),
                          ),
                          if (state.isLoading)
                            const Positioned.fill(
                              child: CemeteryMapLoadingOverlay(
                                showLoadingMessage: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (!state.isLoading && state.graves.isEmpty)
                const Center(
                  child: Text(
                    'لا توجد قبور متاحة حالياً',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: OutlinedButton.icon(
                onPressed: () => context.push('/cemetery/reservations'),
                icon: const Icon(Icons.list_alt_outlined),
                label: const Text('طلباتي'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.primaryGoldenWheat),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
