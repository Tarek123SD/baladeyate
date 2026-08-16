/// Map payload for a cemetery orthophoto + grave overlays.
class CemeteryMapModel {
  const CemeteryMapModel({
    required this.cemeteryId,
    required this.mapUrl,
    required this.mapWidth,
    required this.mapHeight,
    this.name,
  });

  final int cemeteryId;
  final String mapUrl;
  final double mapWidth;
  final double mapHeight;
  final String? name;

  factory CemeteryMapModel.fromJson(Map<String, dynamic> json) {
    final width = _readDouble(json, const ['map_width', 'mapWidth']) ?? 2000;
    final height = _readDouble(json, const ['map_height', 'mapHeight']) ?? 1500;
    final url = (json['map_url'] ?? json['mapUrl'])?.toString().trim() ?? '';

    return CemeteryMapModel(
      cemeteryId: int.tryParse('${json['cemetery_id'] ?? json['cemeteryId'] ?? 1}') ?? 1,
      mapUrl: url,
      mapWidth: width <= 0 ? 2000 : width,
      mapHeight: height <= 0 ? 1500 : height,
      name: json['name']?.toString(),
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
}
