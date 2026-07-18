import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SurveyPin {
  const SurveyPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.buildingId,
    this.title,
    this.address,
  });

  final String id;
  final double latitude;
  final double longitude;
  final SurveyPinStatus status;
  final int? buildingId;
  final String? title;
  final String? address;

  LatLng get position => LatLng(latitude, longitude);

  String get displayTitle =>
      title?.isNotEmpty == true ? title! : 'مسح جديد';

  String get displayLocation =>
      address?.isNotEmpty == true ? address! : _formatCoordinates();

  SurveyPin copyWith({
    String? id,
    double? latitude,
    double? longitude,
    SurveyPinStatus? status,
    int? buildingId,
    String? title,
    String? address,
  }) {
    return SurveyPin(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      buildingId: buildingId ?? this.buildingId,
      title: title ?? this.title,
      address: address ?? this.address,
    );
  }

  factory SurveyPin.fromJson(Map<String, dynamic> json) {
    return SurveyPin(
      id: json['id']?.toString() ?? '',
      latitude: _readCoordinate(json, 'latitude', 'lat'),
      longitude: _readCoordinate(json, 'longitude', 'lng'),
      status: SurveyPinStatus.fromString(json['status'] as String?),
      buildingId: json['building_id'] as int? ?? json['buildingId'] as int?,
      title: json['title'] as String? ?? json['name'] as String?,
      address: json['address'] as String?,
    );
  }

  factory SurveyPin.fromBuildingJson(Map<String, dynamic> json) {
    final id = json['id'];
    return SurveyPin(
      id: id?.toString() ?? '',
      latitude: _readCoordinate(json, 'latitude', 'lat'),
      longitude: _readCoordinate(json, 'longitude', 'lng'),
      status: json.containsKey('survey_status')
          ? SurveyPinStatus.fromString(json['survey_status'] as String?)
          : SurveyPinStatus.completed,
      buildingId: id is int ? id : int.tryParse(id?.toString() ?? ''),
      title: json['name'] as String? ?? json['building_name'] as String?,
      address: json['address'] as String? ??
          json['real_estate_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'status': status.storageValue,
        if (buildingId != null) 'building_id': buildingId,
        if (title != null) 'title': title,
        if (address != null) 'address': address,
      };

  static double _readCoordinate(
    Map<String, dynamic> json,
    String primary,
    String fallback,
  ) {
    final direct = json[primary] ?? json[fallback];
    if (direct is num) return direct.toDouble();
    final parsedDirect = double.tryParse(direct?.toString() ?? '');
    if (parsedDirect != null) return parsedDirect;

    // New survey flow posts `{ coordinates: { lat, lng } }`.
    final nested = json['coordinates'];
    if (nested is Map) {
      final nestedMap = Map<String, dynamic>.from(nested);
      final nestedValue = nestedMap[primary] ??
          nestedMap[fallback] ??
          nestedMap[primary == 'latitude' ? 'lat' : 'lng'];
      if (nestedValue is num) return nestedValue.toDouble();
      return double.tryParse(nestedValue?.toString() ?? '') ?? 0;
    }

    return 0;
  }

  String _formatCoordinates() =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}
