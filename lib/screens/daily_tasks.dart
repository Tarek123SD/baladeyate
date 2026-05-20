import 'dart:async';

import 'package:baladeyate/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import '../utils/constants.dart';

class DailyTasks extends StatefulWidget {
  const DailyTasks({super.key});

  @override
  State<DailyTasks> createState() => _DailyTasksState();
}

class _DailyTasksState extends State<DailyTasks> {
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  bool _permissionDenied = false;
  String? _locationError;
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _permissionDenied = true;
          _locationError = 'يرجى تفعيل خدمات الموقع على جهازك.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _permissionDenied = true;
          _locationError = 'لم يتم منح إذن الوصول إلى الموقع.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentPosition = position;
        _permissionDenied = false;
        _locationError = null;
      });
      _moveCameraToPosition(position);
    } catch (error) {
      setState(() {
        _permissionDenied = true;
        _locationError = 'حدث خطأ أثناء الحصول على الموقع.';
      });
    }
  }

  Future<void> _moveCameraToPosition(Position position) async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  Future<void> _centerOnLocation() async {
    if (_currentPosition != null) {
      await _moveCameraToPosition(_currentPosition!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background_white.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 14.h(context)),
                _buildMapSection(context),
                _buildTaskPanel(context),
                SizedBox(height: 14.h(context)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    final mapHeight = context.isDesktop ? 420.h(context) : 360.h(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w(context)),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 980.w(context)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.r(context)),
            child: Stack(
              children: [
                SizedBox(
                  height: mapHeight,
                  child: _permissionDenied
                      ? _buildLocationError(context, mapHeight)
                      : _currentPosition == null
                          ? Container(
                              color: const Color(0xFFF6F0E6),
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(_currentPosition!.latitude,
                                    _currentPosition!.longitude),
                                zoom: 15,
                              ),
                              mapType: _mapType,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              markers: {
                                Marker(
                                  markerId: const MarkerId('currentLocation'),
                                  position: LatLng(_currentPosition!.latitude,
                                      _currentPosition!.longitude),
                                  infoWindow:
                                      const InfoWindow(title: 'موقعك الحالي'),
                                ),
                              },
                              onMapCreated: (controller) {
                                if (!_mapController.isCompleted) {
                                  _mapController.complete(controller);
                                }
                              },
                            ),
                ),
                Positioned(
                  top: 18.h(context),
                  left: 18.w(context),
                  child: Column(
                    children: [
                      _buildMapAction(
                        context,
                        icon: Icons.my_location_rounded,
                        label: 'موقعي',
                        onTap: _centerOnLocation,
                      ),
                      SizedBox(height: 12.h(context)),
                      _buildMapAction(
                        context,
                        icon: Icons.layers_rounded,
                        label: _mapType == MapType.normal ? 'خريطة' : 'هجين',
                        onTap: _toggleMapType,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 38.h(context),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h(context),
                        horizontal: 20.w(context),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        'المهمة القادمة',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: AppConstants.primaryForest,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.s(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationError(BuildContext context, double height) {
    return Container(
      height: height,
      color: const Color(0xFFF6F0E6),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
          child: Text(
            _locationError ?? 'يتطلب التطبيق إذن الموقع لعرض الخريطة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppConstants.primaryForest,
              fontSize: 15.s(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.w(context),
        height: 52.w(context),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppConstants.primaryForest, size: 24.s(context)),
            SizedBox(height: 2.h(context)),
            Text(
              label,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppConstants.primaryForest,
                fontSize: 9.s(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskPanel(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 18.h(context), bottom: 14.h(context)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(36.r(context))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24.w(context),
            24.h(context),
            24.w(context),
            24.h(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'قائمة المهام اليومية',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryForest,
                              ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w(context),
                      vertical: 8.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8E9DC),
                      borderRadius: BorderRadius.circular(18.r(context)),
                    ),
                    child: Text(
                      '3 مهام متبقية',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppConstants.primaryForest,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.s(context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h(context)),
              Text(
                'المفوّض: أحمد منصور • دمشق، المزة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: const Color(0xFF6D6D6D),
                  fontSize: 13.s(context),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 22.h(context)),
              _buildPrimaryTaskCard(context),
              SizedBox(height: 18.h(context)),
              _buildSecondaryTaskCard(context),
              SizedBox(height: 20.h(context)),
              _buildTaskSummaryRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryTaskCard(BuildContext context) {
    final isMobile = context.isMobile;

    final taskDetails = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مسح المنشأة',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.s(context),
            color: AppConstants.primaryForest,
          ),
        ),
        SizedBox(height: 4.h(context)),
        Text(
          'التعليمية #412',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.s(context),
            color: AppConstants.primaryForest,
          ),
        ),
        SizedBox(height: 14.h(context)),
        Row(
          children: [
            Icon(Icons.place,
                size: 16.s(context), color: AppConstants.primaryForest),
            SizedBox(width: 4.w(context)),
            Text(
              '1.2 كم',
              style: TextStyle(
                color: AppConstants.primaryForest,
                fontSize: 12.s(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 16.w(context)),
            Icon(Icons.access_time_filled,
                size: 16.s(context), color: AppConstants.primaryForest),
            SizedBox(width: 4.w(context)),
            Text(
              '09:30 صباحاً',
              style: TextStyle(
                color: AppConstants.primaryForest,
                fontSize: 12.s(context),
              ),
            ),
          ],
        ),
      ],
    );

    final taskAvatar = Container(
      width: 96.w(context),
      height: 96.w(context),
      decoration: BoxDecoration(
        color: AppConstants.primaryGoldenWheat,
        borderRadius: BorderRadius.circular(24.r(context)),
      ),
      child:
          Icon(Icons.school_rounded, color: Colors.white, size: 36.s(context)),
    );

    final startButton = ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryForest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r(context)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 18.w(context),
          vertical: 16.h(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back_ios_new_rounded, size: 18.s(context)),
          SizedBox(height: 4.h(context)),
          Text(
            'ابدأ',
            style: TextStyle(
              fontSize: 14.s(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'المسح',
            style: TextStyle(
              fontSize: 14.s(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EA),
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(color: const Color(0xFFE9E1D6)),
      ),
      padding: EdgeInsets.all(18.w(context)),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                taskDetails,
                SizedBox(height: 18.h(context)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    taskAvatar,
                    SizedBox(width: 12.w(context)),
                    Expanded(child: startButton),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: taskDetails),
                SizedBox(width: 12.w(context)),
                taskAvatar,
                SizedBox(width: 14.w(context)),
                startButton,
              ],
            ),
    );
  }

  Widget _buildSecondaryTaskCard(BuildContext context) {
    final isMobile = context.isMobile;

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'تقييم الأضرار - القطاع الشمالي',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.s(context),
            color: AppConstants.primaryForest,
          ),
        ),
        SizedBox(height: 10.h(context)),
        Text(
          'وثائق المشروع جاهزة • 08:00 صباحاً',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: const Color(0xFF6D6D6D),
            fontSize: 13.s(context),
          ),
        ),
      ],
    );

    final iconBadge = Container(
      width: 54.w(context),
      height: 54.w(context),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E4F0),
        borderRadius: BorderRadius.circular(18.r(context)),
      ),
      child: Icon(Icons.work,
          color: AppConstants.primaryForest, size: 28.s(context)),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 18.w(context),
        vertical: 18.h(context),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                cardContent,
                SizedBox(height: 16.h(context)),
                Align(alignment: Alignment.centerRight, child: iconBadge),
              ],
            )
          : Row(
              children: [
                Expanded(child: cardContent),
                SizedBox(width: 12.w(context)),
                iconBadge,
              ],
            ),
    );
  }

  Widget _buildTaskSummaryRow(BuildContext context) {
    final isMobile = context.isMobile;

    Widget buildSummaryCard(String title, String value) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F0E6),
          borderRadius: BorderRadius.circular(20.r(context)),
        ),
        padding: EdgeInsets.all(16.w(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppConstants.primaryForest,
                fontSize: 13.s(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h(context)),
            Text(
              value,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppConstants.primaryForest,
                fontSize: 18.s(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return isMobile
        ? Column(
            children: [
              buildSummaryCard('الحالة الحالية', 'قيد التنفيذ'),
              SizedBox(height: 12.h(context)),
              buildSummaryCard('المهام القادمة', '4 مهام'),
            ],
          )
        : Row(
            children: [
              Expanded(
                  child: buildSummaryCard('الحالة الحالية', 'قيد التنفيذ')),
              SizedBox(width: 12.w(context)),
              Expanded(child: buildSummaryCard('المهام القادمة', '4 مهام')),
            ],
          );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final iconSize = 22.s(context);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r(context)),
        topRight: Radius.circular(20.r(context)),
      ),
      child: BottomNavigationBar(
        iconSize: iconSize,
        selectedFontSize: 11.s(context),
        unselectedFontSize: 10.s(context),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppConstants.secondaryForest,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (index) => _onBottomBarTap(context, index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: iconSize),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: iconSize),
            label: 'الملف الشخصي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism, size: iconSize),
            label: 'التبرعات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined, size: iconSize),
            label: 'الشكاوي',
          ),
        ],
      ),
    );
  }

  void _onBottomBarTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/main');
        break;
      case 1:
        GoRouter.of(context).go('/profile');
        break;
      case 2:
        GoRouter.of(context).go('/donations');
        break;
      case 3:
        GoRouter.of(context).go('/track');
        break;
    }
  }
}
