import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class FloorHubHeaderCard extends StatelessWidget {
  const FloorHubHeaderCard({
    super.key,
    required this.survey,
    required this.floor,
  });

  final BuildingSurvey survey;
  final FloorDraft floor;

  String get _floorTitle {
    if (floor.floorName.trim().isNotEmpty) return floor.floorName.trim();
    if (floor.floorNumber.trim().isNotEmpty) {
      return 'الطابق ${floor.floorNumber}';
    }
    return 'طابق';
  }

  String get _buildingTitle {
    final name = survey.building.name.trim();
    if (name.isNotEmpty) return name;
    if (survey.building.realEstateNumber.trim().isNotEmpty) {
      return 'رقم عقاري: ${survey.building.realEstateNumber}';
    }
    return 'المبنى';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.s(context)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryForest,
            AppColors.secondaryForest,
            AppColors.thirdForest,
          ],
        ),
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.s(context)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r(context)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.layers_rounded,
                  color: Colors.white,
                  size: 28.ic(context),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _floorTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.f(context),
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      _buildingTitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.f(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w(context),
                  vertical: 6.h(context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.thirdGoldenWheat.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20.r(context)),
                ),
                child: Text(
                  '${floor.savedApartmentCount} شقة',
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 11.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h(context)),
          Text(
            'سجّل الشقق وبيانات الأسر على هذا الطابق، ثم راجعها أو عدّلها في أي وقت.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.f(context),
              height: 1.55,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Row(
            children: [
              Expanded(
                child: FloorHubStatPill(
                  icon: Icons.meeting_room_outlined,
                  label: 'مسجلة',
                  value: '${floor.savedApartmentCount}',
                ),
              ),
              if (floor.expectedApartmentCount.trim().isNotEmpty) ...[
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: FloorHubStatPill(
                    icon: Icons.tag_outlined,
                    label: 'متوقعة',
                    value: floor.expectedApartmentCount.trim(),
                  ),
                ),
              ],
              if (floor.floorPlanNumber.trim().isNotEmpty) ...[
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: FloorHubStatPill(
                    icon: Icons.map_outlined,
                    label: 'المخطط',
                    value: floor.floorPlanNumber.trim(),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class FloorHubStatPill extends StatelessWidget {
  const FloorHubStatPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w(context),
        vertical: 10.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r(context)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.thirdGoldenWheat, size: 18.ic(context)),
          SizedBox(height: 6.h(context)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.f(context),
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h(context)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11.f(context),
            ),
          ),
        ],
      ),
    );
  }
}
