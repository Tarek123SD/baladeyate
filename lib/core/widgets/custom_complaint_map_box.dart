import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_complaint_input_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:go_router/go_router.dart';

const LatLng _kFallbackLocation = LatLng(33.5138, 36.2765); // Damascus

/// Resolves the device position, returning `null` and optionally surfacing a
/// localized message through [onError] when it can't be determined.
Future<Position?> _resolveCurrentPosition({
  void Function(String message)? onError,
}) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    onError?.call('يرجى تفعيل خدمة الموقع (GPS)');
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    onError?.call(
      'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
    );
    if (onError != null) {
      await Geolocator.openAppSettings();
    }
    return null;
  }
  if (permission == LocationPermission.denied) {
    onError?.call('تم رفض إذن الوصول إلى الموقع');
    return null;
  }

  try {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;
  } catch (_) {}

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 6),
      ),
    );
  } catch (_) {}

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 6),
      ),
    );
  } catch (_) {
    onError?.call('تعذر تحديد موقعك الحالي. يمكنك تحريك الخريطة يدوياً.');
    return null;
  }
}

class CustomComplaintMapBox extends StatefulWidget {
  const CustomComplaintMapBox({
    super.key,
    this.onLocationSelected,
    this.onAddressChanged,
    this.initialLocation,
  });

  /// Called whenever the user picks the location from the full-screen map.
  final ValueChanged<LatLng>? onLocationSelected;

  /// Called whenever the manual address text changes.
  final ValueChanged<String>? onAddressChanged;

  /// Optional starting location. Defaults to Damascus when not provided.
  final LatLng? initialLocation;

  @override
  State<CustomComplaintMapBox> createState() => _CustomComplaintMapBoxState();
}

class _CustomComplaintMapBoxState extends State<CustomComplaintMapBox> {
  final TextEditingController _addressController = TextEditingController();
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;

    final result = await context.push<LatLng>(
      '/complains/map-picker',
      extra: _selected ?? widget.initialLocation,
    );

    if (result == null || !mounted) return;

    setState(() => _selected = result);
    widget.onLocationSelected?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPreview(context),
        SizedBox(height: 10.s(context)),
        _buildSelectedInfo(context),
        SizedBox(height: 12.s(context)),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'أو اكتب العنوان يدوياً',
            style: TextStyle(
              fontSize: 13.f(context),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryForest,
            ),
          ),
        ),
        SizedBox(height: 8.s(context)),
        CustomComplaintInputField(
          controller: _addressController,
          hint: 'مثال: شارع الجمهورية، بجوار المسجد الكبير...',
          prefixIcon: Icons.edit_location_alt_rounded,
          onChanged: widget.onAddressChanged,
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final selected = _selected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openMapPicker,
        borderRadius: BorderRadius.circular(14.r(context)),
        child: Ink(
          height: 180.h(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r(context)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.thirdForest.withValues(alpha: 0.18),
                AppColors.primaryForest.withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(
              color: AppColors.primaryForest.withValues(alpha: 0.16),
            ),
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.s(context),
                vertical: 10.s(context),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24.r(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected == null
                        ? Icons.map_rounded
                        : Icons.edit_location_alt_rounded,
                    size: 18.ic(context),
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.s(context)),
                  Text(
                    selected == null
                        ? 'اضغط لفتح الخريطة وتحديد الموقع'
                        : 'اضغط لتعديل الموقع',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.f(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedInfo(BuildContext context) {
    final selected = _selected;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 12.s(context),
        vertical: 10.s(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            selected != null
                ? Icons.location_on_rounded
                : Icons.location_off_rounded,
            size: 20.ic(context),
            color: selected != null
                ? AppColors.thirdForest
                : AppColors.secondaryCharcoal.withValues(alpha: 0.5),
          ),
          SizedBox(width: 8.s(context)),
          Expanded(
            child: Text(
              selected != null
                  ? 'الموقع المحدد: '
                      '${selected.latitude.toStringAsFixed(5)}, '
                      '${selected.longitude.toStringAsFixed(5)}'
                  : 'لم يتم تحديد موقع بعد',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.f(context),
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen map used to precisely pick a location.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  late LatLng _center;
  LatLng? _pendingCameraTarget;
  bool _locating = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initialLocation ?? _kFallbackLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachMapWhenStable());
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || _mapReady) return;
      setState(() => _mapReady = true);
      if (widget.initialLocation == null) {
        _goToMyLocation(animate: false, showErrors: false);
      }
    });
  }

  void _attachMapWhenStable() {
    if (!mounted || _mapReady) return;
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _attachMapWhenStable());
      return;
    }
    setState(() => _mapReady = true);
    if (widget.initialLocation == null) {
      _goToMyLocation(animate: false, showErrors: false);
    }
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _moveCamera(LatLng target, {required bool animate}) async {
    final controller = _mapController;
    if (controller == null) {
      _pendingCameraTarget = target;
      return;
    }

    final update = CameraUpdate.newLatLngZoom(target, 16);
    try {
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    } catch (_) {
      // Controller can be disposed while the camera animation is in flight.
    }
  }

  Future<void> _goToMyLocation({
    bool animate = true,
    bool showErrors = true,
  }) async {
    if (_locating) return;
    setState(() => _locating = true);
    final position = await _resolveCurrentPosition(
      onError: showErrors ? _showMessage : null,
    );
    if (!mounted) return;
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      _center = latLng;
      await _moveCamera(latLng, animate: animate);
    }
    if (mounted) setState(() => _locating = false);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final pending = _pendingCameraTarget;
    if (pending != null) {
      _pendingCameraTarget = null;
      controller.moveCamera(CameraUpdate.newLatLngZoom(pending, 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryForest,
        foregroundColor: Colors.white,
        title: Text(
          'تحديد الموقع',
          style: TextStyle(
            fontSize: 18.f(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_mapReady)
            MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _center, zoom: 15),
                onMapCreated: _onMapCreated,
                onCameraMove: (position) => _center = position.target,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                liteModeEnabled: false,
                markers: const <Marker>{},
                padding: const EdgeInsets.only(bottom: 80),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: Offset(0, -22.s(context)),
                child: Icon(
                  Icons.location_on,
                  size: 48.ic(context),
                  color: AppColors.alertRed,
                ),
              ),
            ),
          ),
          Positioned(
            top: 12.s(context),
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.s(context),
                  vertical: 8.s(context),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20.r(context)),
                ),
                child: Text(
                  'حرّك الخريطة لوضع الدبوس على الموقع المطلوب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.f(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 96.s(context),
            left: 16.s(context),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _locating ? null : () => _goToMyLocation(),
                child: Padding(
                  padding: EdgeInsets.all(12.s(context)),
                  child: _locating
                      ? SizedBox(
                          width: 22.s(context),
                          height: 22.s(context),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.primaryForest),
                          ),
                        )
                      : Icon(
                          Icons.my_location_rounded,
                          size: 24.ic(context),
                          color: AppColors.primaryForest,
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16.s(context),
            left: 16.s(context),
            right: 16.s(context),
            child: SizedBox(
              height: 52.h(context),
              child: ElevatedButton.icon(
                onPressed: () => context.pop(_center),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r(context)),
                  ),
                ),
                icon: Icon(Icons.check_circle_rounded, size: 20.s(context)),
                label: Text(
                  'تأكيد الموقع',
                  style: TextStyle(
                    fontSize: 15.f(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
