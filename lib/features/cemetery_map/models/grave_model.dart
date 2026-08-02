/// Represents a single grave plot on the cemetery orthophoto map.
///
/// Coordinates ([x], [y], [width], [height]) are absolute pixel values
/// relative to the original drone image size.
class GraveModel {
  const GraveModel({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.status,
    this.deceasedName,
  });

  final String id;
  final double x;
  final double y;
  final double width;
  final double height;

  /// One of: `'available'`, `'occupied'`, `'booked'`.
  final String status;

  final String? deceasedName;

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isBooked => status == 'booked';

  GraveModel copyWith({
    String? id,
    double? x,
    double? y,
    double? width,
    double? height,
    String? status,
    String? deceasedName,
  }) {
    return GraveModel(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      status: status ?? this.status,
      deceasedName: deceasedName ?? this.deceasedName,
    );
  }

  factory GraveModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['deceased_name'] as String? ??
        json['deceasedName'] as String?;
    final trimmedName = rawName?.trim();

    return GraveModel(
      id: json['id']?.toString() ?? '',
      x: _readDouble(json, const ['x_coordinate', 'x']) ?? 0,
      y: _readDouble(json, const ['y_coordinate', 'y']) ?? 0,
      width: _readDouble(json, const ['width']) ?? defaultGraveWidth,
      height: _readDouble(json, const ['height']) ?? defaultGraveHeight,
      status: json['status'] as String? ?? 'available',
      deceasedName:
          (trimmedName != null && trimmedName.isNotEmpty) ? trimmedName : null,
    );
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toCreateJson({required int cemeteryId}) {
    return {
      'cemetery_id': cemeteryId,
      'x_coordinate': x,
      'y_coordinate': y,
      'width': width,
      'height': height,
      'status': status,
      if (deceasedName != null && deceasedName!.isNotEmpty)
        'deceased_name': deceasedName,
    };
  }

  /// Default cemetery until multi-cemetery selection is wired.
  static const int defaultCemeteryId = 1;
  static const double defaultGraveWidth = 20;
  static const double defaultGraveHeight = 45;
}
