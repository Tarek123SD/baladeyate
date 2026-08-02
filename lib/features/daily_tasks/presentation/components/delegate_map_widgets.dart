import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/daily_tasks/models/daily_task.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_marker_icons.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide Cluster, ClusterManager;
import 'package:responsive_x_toolkit/responsive_x.dart';

double markerHueForStatus(SurveyPinStatus status) {
  switch (status) {
    case SurveyPinStatus.assigned:
      return BitmapDescriptor.hueRed;
    case SurveyPinStatus.inProgress:
      return BitmapDescriptor.hueOrange;
    case SurveyPinStatus.completed:
      return BitmapDescriptor.hueGreen;
  }
}

DailyTaskStatus cardStatusForPin(SurveyPin pin) {
  switch (pin.status) {
    case SurveyPinStatus.assigned:
      return DailyTaskStatus.scheduled;
    case SurveyPinStatus.inProgress:
      return DailyTaskStatus.highPriority;
    case SurveyPinStatus.completed:
      return DailyTaskStatus.completed;
  }
}

String statusLabelForPin(SurveyPin pin) => statusLabelForStatus(pin.status);

String statusLabelForStatus(SurveyPinStatus status) {
  switch (status) {
    case SurveyPinStatus.assigned:
      return 'مُسند';
    case SurveyPinStatus.inProgress:
      return 'قيد الإدخال';
    case SurveyPinStatus.completed:
      return 'مكتمل';
  }
}

String actionLabelForPin(SurveyPin pin) {
  switch (pin.status) {
    case SurveyPinStatus.completed:
      return 'عرض على الخريطة';
    case SurveyPinStatus.inProgress:
      return 'متابعة المسح';
    case SurveyPinStatus.assigned:
      return 'بدء المسح';
  }
}

void showPinInfoSheet(BuildContext context, SurveyPin pin) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20.w(context),
          8.h(context),
          20.w(context),
          24.h(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              pin.displayTitle,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 17.f(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h(context)),
            Text(
              pin.displayLocation,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.8),
                fontSize: 14.f(context),
              ),
            ),
            SizedBox(height: 8.h(context)),
            Text(
              'الحالة: ${statusLabelForPin(pin)}',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                fontSize: 13.f(context),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _SurveyPinClusterItem with ClusterItem {
  _SurveyPinClusterItem(this.pin);

  final SurveyPin pin;

  @override
  LatLng get location => pin.position;
}

class DelegateLocationBanner extends StatelessWidget {
  const DelegateLocationBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(12.r(context)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w(context),
          vertical: 10.h(context),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              AppIcons.locationOff,
              color: AppColors.primaryGoldenWheat,
              size: 18.ic(context),
            ),
            SizedBox(width: 8.w(context)),
            Expanded(
              child: Text(
                message,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.primaryForest,
                  fontSize: 12.f(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DelegateAddPinBanner extends StatelessWidget {
  const DelegateAddPinBanner({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryForest,
      borderRadius: BorderRadius.circular(14.r(context)),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          8.w(context),
          10.h(context),
          12.w(context),
          10.h(context),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 20.ic(context),
            ),
            SizedBox(width: 8.w(context)),
            Expanded(
              child: Text(
                'اضغط مطولاً على الخريطة لإضافة نقطة مسح',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.f(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 4.w(context)),
            InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(20.r(context)),
              child: Padding(
                padding: EdgeInsets.all(6.s(context)),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18.ic(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DelegateMapStatusLegend extends StatelessWidget {
  const DelegateMapStatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(14.r(context)),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w(context),
          vertical: 8.h(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            for (final entry in _legendEntries) ...[
              if (entry != _legendEntries.first) SizedBox(width: 10.w(context)),
              _LegendDot(
                color: DelegateMapMarkerIcons.colorForStatus(entry.$1),
                label: entry.$2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _legendEntries = <(SurveyPinStatus, String)>[
    (SurveyPinStatus.assigned, 'مُسند'),
    (SurveyPinStatus.inProgress, 'قيد الإدخال'),
    (SurveyPinStatus.completed, 'مكتمل'),
  ];
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 9.s(context),
          height: 9.s(context),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        SizedBox(width: 4.w(context)),
        Text(
          label,
          style: TextStyle(
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.85),
            fontSize: 10.f(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DelegateMapFilterChips extends StatelessWidget {
  const DelegateMapFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final SurveyPinStatus? selected;
  final ValueChanged<SurveyPinStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <(SurveyPinStatus?, String)>[
      (null, 'الكل'),
      (SurveyPinStatus.assigned, 'مُسند'),
      (SurveyPinStatus.inProgress, 'قيد الإدخال'),
      (SurveyPinStatus.completed, 'مكتمل'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (final option in options) ...[
            _FilterChip(
              label: option.$2,
              selected: selected == option.$1,
              color: option.$1 == null
                  ? AppColors.primaryForest
                  : DelegateMapMarkerIcons.colorForStatus(option.$1!),
              onTap: () => onChanged(option.$1),
            ),
            SizedBox(width: 8.w(context)),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(20.r(context)),
      elevation: selected ? 2 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r(context)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 7.h(context),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primaryForest,
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class DelegateSelectedPinCard extends StatelessWidget {
  const DelegateSelectedPinCard({
    super.key,
    required this.pin,
    required this.onClose,
    required this.onAction,
  });

  final SurveyPin pin;
  final VoidCallback onClose;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final statusColor = DelegateMapMarkerIcons.colorForStatus(pin.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r(context)),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14.w(context),
          12.h(context),
          14.w(context),
          12.h(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.s(context),
                  height: 40.s(context),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.location,
                    color: statusColor,
                    size: 22.ic(context),
                  ),
                ),
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pin.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontSize: 14.f(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h(context)),
                      Text(
                        pin.displayLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: AppColors.secondaryCharcoal
                              .withValues(alpha: 0.7),
                          fontSize: 11.f(context),
                        ),
                      ),
                      SizedBox(height: 6.h(context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w(context),
                          vertical: 3.h(context),
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20.r(context)),
                        ),
                        child: Text(
                          statusLabelForPin(pin),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10.f(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(20.r(context)),
                  child: Padding(
                    padding: EdgeInsets.all(4.s(context)),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.ic(context),
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h(context)),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryForest,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 11.h(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r(context)),
                  ),
                ),
                child: Text(
                  actionLabelForPin(pin),
                  style: TextStyle(
                    fontSize: 13.f(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DelegateMapControlButton extends StatelessWidget {
  const DelegateMapControlButton({
    super.key,
    this.icon,
    this.isLoading = false,
    this.isActive = false,
    this.tooltip,
    required this.onTap,
  });

  final IconData? icon;
  final bool isLoading;
  final bool isActive;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: isActive ? AppColors.primaryForest : Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: EdgeInsets.all(11.s(context)),
          child: isLoading
              ? SizedBox(
                  width: 20.s(context),
                  height: 20.s(context),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  icon,
                  size: 20.ic(context),
                  color: isActive ? Colors.white : AppColors.primaryForest,
                ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class DelegateSurveyMap extends StatefulWidget {
  const DelegateSurveyMap({
    super.key,
    required this.defaultCenter,
    required this.pins,
    required this.selectedPinId,
    required this.mapType,
    required this.onMapCreated,
    required this.onTap,
    required this.onLongPress,
    required this.onMarkerTap,
    this.isAddPinMode = false,
    this.bottomPadding = 0,
  });

  final LatLng defaultCenter;
  final List<SurveyPin> pins;
  final String? selectedPinId;
  final MapType mapType;
  final void Function(GoogleMapController controller) onMapCreated;
  final VoidCallback onTap;
  final void Function(LatLng position) onLongPress;
  final void Function(SurveyPin pin) onMarkerTap;
  final bool isAddPinMode;
  final double bottomPadding;

  @override
  State<DelegateSurveyMap> createState() => _DelegateSurveyMapState();
}

class _DelegateSurveyMapState extends State<DelegateSurveyMap> {
  late ClusterManager<_SurveyPinClusterItem> _clusterManager;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _clusterManager = ClusterManager<_SurveyPinClusterItem>(
      _toItems(widget.pins),
      _onMarkersUpdated,
      markerBuilder: _buildMarker,
      stopClusteringZoom: 16.5,
      levels: const [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
    );
  }

  @override
  void didUpdateWidget(covariant DelegateSurveyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pinsChanged = oldWidget.pins != widget.pins;
    final selectionChanged = oldWidget.selectedPinId != widget.selectedPinId;
    final modeChanged = oldWidget.isAddPinMode != widget.isAddPinMode;

    if (pinsChanged) {
      _clusterManager.setItems(_toItems(widget.pins));
    } else if (selectionChanged || modeChanged) {
      _clusterManager.updateMap();
    }
  }

  List<_SurveyPinClusterItem> _toItems(List<SurveyPin> pins) {
    return pins.map(_SurveyPinClusterItem.new).toList();
  }

  void _onMarkersUpdated(Set<Marker> markers) {
    if (!mounted) return;
    setState(() => _markers = markers);
  }

  Future<Marker> _buildMarker(Cluster<_SurveyPinClusterItem> cluster) async {
    if (cluster.isMultiple) {
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        onTap: () => _zoomIntoCluster(cluster.location),
        icon: await DelegateMapMarkerIcons.cluster(cluster.count),
        zIndexInt: 3,
        consumeTapEvents: true,
      );
    }

    final pin = cluster.items.first.pin;
    final selected = pin.id == widget.selectedPinId;
    return Marker(
      markerId: MarkerId(pin.id),
      position: pin.position,
      onTap: widget.isAddPinMode ? null : () => widget.onMarkerTap(pin),
      icon: await DelegateMapMarkerIcons.forStatus(
        pin.status,
        selected: selected,
      ),
      alpha: pin.status == SurveyPinStatus.completed && !selected ? 0.88 : 1,
      zIndexInt: selected ? 2 : 1,
      consumeTapEvents: !widget.isAddPinMode,
    );
  }

  Future<void> _zoomIntoCluster(LatLng location) async {
    final controller = _mapController;
    if (controller == null) return;
    final zoom = await controller.getZoomLevel();
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(location, (zoom + 2).clamp(12, 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.defaultCenter,
          zoom: 13.5,
        ),
        mapType: widget.mapType,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        onMapCreated: (controller) {
          _mapController = controller;
          _clusterManager.setMapId(controller.mapId);
          widget.onMapCreated(controller);
        },
        onCameraMove: _clusterManager.onCameraMove,
        onCameraIdle: _clusterManager.updateMap,
        onTap: (_) => widget.onTap(),
        onLongPress: widget.onLongPress,
      ),
    );
  }
}
