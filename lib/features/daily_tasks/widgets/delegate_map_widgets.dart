import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/daily_tasks/models/daily_task.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      return DailyTaskStatus.highPriority;
    case SurveyPinStatus.inProgress:
      return DailyTaskStatus.scheduled;
    case SurveyPinStatus.completed:
      return DailyTaskStatus.completed;
  }
}

String statusLabelForPin(SurveyPin pin) {
  switch (pin.status) {
    case SurveyPinStatus.assigned:
      return 'مهمة ميدانية';
    case SurveyPinStatus.inProgress:
      return 'قيد الإدخال';
    case SurveyPinStatus.completed:
      return 'مكتمل';
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
              Icons.location_off_outlined,
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

class DelegateMapControlButton extends StatelessWidget {
  const DelegateMapControlButton({
    super.key,
    this.icon,
    this.isLoading = false,
    this.isActive = false,
    required this.onTap,
  });

  final IconData? icon;
  final bool isLoading;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
  }
}

class DelegateSurveyMap extends StatelessWidget {
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
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: defaultCenter,
          zoom: 13.5,
        ),
        mapType: mapType,
        markers: _buildMarkers(),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        padding: EdgeInsets.only(bottom: bottomPadding),
        onMapCreated: onMapCreated,
        onTap: (_) => onTap(),
        onLongPress: onLongPress,
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return pins.map((pin) {
      final isSelected = pin.id == selectedPinId;
      return Marker(
        markerId: MarkerId(pin.id),
        position: pin.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          markerHueForStatus(pin.status),
        ),
        alpha: pin.status == SurveyPinStatus.completed ? 0.85 : 1,
        zIndexInt: isSelected ? 2 : 1,
        onTap: () => onMarkerTap(pin),
        infoWindow: InfoWindow(
          title: pin.displayTitle,
          snippet: pin.displayLocation,
        ),
      );
    }).toSet();
  }
}
