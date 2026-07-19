import 'dart:async';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_complaint_input_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

const LatLng _kFallbackLocation = LatLng(30.0444, 31.2357); // Cairo

/// Resolves the device position, returning `null` and surfacing a localized
/// message through [onError] when it can't be determined.
Future<Position?> _resolveCurrentPosition(
  void Function(String message) onError,
) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    onError('يرجى تفعيل خدمة الموقع (GPS)');
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    onError('تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.');
    await Geolocator.openAppSettings();
    return null;
  }
  if (permission == LocationPermission.denied) {
    onError('تم رفض إذن الوصول إلى الموقع');
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  } catch (_) {
    onError('تعذر تحديد موقعك الحالي');
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

  /// Optional starting location. Defaults to Cairo when not provided.
  final LatLng? initialLocation;

  @override
  State<CustomComplaintMapBox> createState() => _CustomComplaintMapBoxState();
}

class _CustomComplaintMapBoxState extends State<CustomComplaintMapBox> {
  final Completer<GoogleMapController> _previewController = Completer();
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
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _MapPickerScreen(
          initialLocation: _selected ?? widget.initialLocation,
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _selected = result);
    widget.onLocationSelected?.call(result);

    if (_previewController.isCompleted) {
      final controller = await _previewController.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(result, 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _selected ?? widget.initialLocation ?? _kFallbackLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPreview(context, target),
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

  Widget _buildPreview(BuildContext context, LatLng target) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r(context)),
      child: SizedBox(
        height: 180.h(context),
        child: Stack(
          children: [
            // Non-interactive preview; interaction happens in the picker.
            IgnorePointer(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: target, zoom: 15),
                onMapCreated: (controller) {
                  if (!_previewController.isCompleted) {
                    _previewController.complete(controller);
                  }
                },
                markers: {
                  if (_selected != null)
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selected!,
                    ),
                },
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                mapToolbarEnabled: false,
                liteModeEnabled: false,
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openMapPicker,
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
                            Icons.map_rounded,
                            size: 18.ic(context),
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.s(context)),
                          Text(
                            _selected == null
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
            ),
          ],
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
class _MapPickerScreen extends StatefulWidget {
  const _MapPickerScreen({this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _selected;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
    if (_selected == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _goToMyLocation(animate: false),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _goToMyLocation({bool animate = true}) async {
    if (_locating) return;
    setState(() => _locating = true);
    final position = await _resolveCurrentPosition(_showMessage);
    if (!mounted) return;
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _selected = latLng);
      if (animate && _controller.isCompleted) {
        final controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 16),
        );
      }
    }
    if (mounted) setState(() => _locating = false);
  }

  @override
  Widget build(BuildContext context) {
    final target = _selected ?? widget.initialLocation ?? _kFallbackLocation;

    return Scaffold(
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
          GoogleMap(
            initialCameraPosition: CameraPosition(target: target, zoom: 15),
            onMapCreated: (controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            onTap: (latLng) => setState(() => _selected = latLng),
            markers: {
              if (_selected != null)
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selected!,
                  draggable: true,
                  onDragEnd: (latLng) => setState(() => _selected = latLng),
                ),
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
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
                  'اضغط على الخريطة أو اسحب العلامة لتحديد الموقع',
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
                onPressed: _selected == null
                    ? null
                    : () => Navigator.of(context).pop(_selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.secondaryCharcoal.withValues(alpha: 0.4),
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
