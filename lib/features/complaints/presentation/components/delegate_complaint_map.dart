import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:url_launcher/url_launcher.dart';

class DelegateComplaintMap extends StatelessWidget {
  const DelegateComplaintMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;

  Future<void> _openExternalMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final target = LatLng(latitude, longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r(context)),
          child: SizedBox(
            height: 220.h(context),
            child: kIsWeb
                ? _MapFallback(
                    latitude: latitude,
                    longitude: longitude,
                    onOpen: _openExternalMaps,
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: target,
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('complaint-location'),
                        position: target,
                        infoWindow: InfoWindow(
                          title: address?.isNotEmpty == true
                              ? address
                              : 'موقع الشكوى',
                        ),
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    liteModeEnabled: false,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                  ),
          ),
        ),
        SizedBox(height: 10.h(context)),
        if (address != null && address!.isNotEmpty)
          Text(
            address!,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13.f(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        Text(
          '${latitude.toStringAsFixed(5)} ، ${longitude.toStringAsFixed(5)}',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12.f(context),
          ),
        ),
        SizedBox(height: 8.h(context)),
        OutlinedButton.icon(
          onPressed: _openExternalMaps,
          icon: const Icon(Icons.directions_outlined),
          label: const Text('فتح في الخرائط للوصول إلى الموقع'),
        ),
      ],
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback({
    required this.latitude,
    required this.longitude,
    required this.onOpen,
  });

  final double latitude;
  final double longitude;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryForest.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onOpen,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                color: AppColors.primaryForest,
                size: 36.ic(context),
              ),
              SizedBox(height: 8.h(context)),
              Text(
                'اضغط لعرض الموقع على الخريطة',
                style: TextStyle(
                  color: AppColors.primaryForest,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.f(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
