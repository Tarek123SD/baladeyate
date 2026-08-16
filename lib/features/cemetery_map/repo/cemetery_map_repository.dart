import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/cemetery_map/models/cemetery_map_model.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';

class CemeteryMapRepository {
  CemeteryMapRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  /// Fallback orthophoto when the API omits [map_url].
  static const String fallbackMapUrl =
      'https://baladeyate.me/cemeteries/map_v1.jpg';

  Future<({CemeteryMapModel map, List<GraveModel> graves})> getMap({
    int cemeteryId = GraveModel.defaultCemeteryId,
  }) async {
    try {
      final response = await _apiService.get(
        EndPoints.cemeteryMap(cemeteryId),
      );

      final payload = ApiResponseParser.expectDataMap(
        response.data,
        fallback: 'فشل تحميل خريطة المقبرة',
      );

      final map = CemeteryMapModel.fromJson(payload);
      final resolvedMap = map.mapUrl.isEmpty
          ? CemeteryMapModel(
              cemeteryId: map.cemeteryId,
              mapUrl: fallbackMapUrl,
              mapWidth: map.mapWidth,
              mapHeight: map.mapHeight,
              name: map.name,
            )
          : map;

      final rawGraves = payload['graves'];
      final graves = <GraveModel>[];
      if (rawGraves is List) {
        for (final item in rawGraves) {
          if (item is Map<String, dynamic>) {
            final grave = GraveModel.fromJson(item);
            if (grave.width > 0 && grave.height > 0) {
              graves.add(grave);
            }
          } else if (item is Map) {
            final grave = GraveModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (grave.width > 0 && grave.height > 0) {
              graves.add(grave);
            }
          }
        }
      }

      return (map: resolvedMap, graves: List<GraveModel>.unmodifiable(graves));
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحميل خريطة المقبرة',
      );
    }
  }

  Future<List<GraveModel>> getGraves({
    int cemeteryId = GraveModel.defaultCemeteryId,
  }) async {
    final result = await getMap(cemeteryId: cemeteryId);
    return result.graves;
  }

  Future<GraveModel> createGrave({
    required double x,
    required double y,
    int cemeteryId = GraveModel.defaultCemeteryId,
    double width = GraveModel.defaultGraveWidth,
    double height = GraveModel.defaultGraveHeight,
    String status = 'available',
    String? deceasedName,
  }) async {
    try {
      final payload = <String, dynamic>{
        'cemetery_id': cemeteryId,
        'x_coordinate': x,
        'y_coordinate': y,
        'width': width,
        'height': height,
        'status': status,
      };
      if (status == 'occupied' &&
          deceasedName != null &&
          deceasedName.trim().isNotEmpty) {
        payload['deceased_name'] = deceasedName.trim();
      }

      final response = await _apiService.post(
        EndPoints.graves,
        data: payload,
      );

      final map = ApiResponseParser.expectMap(
        response.data,
        fallback: 'فشل إضافة القبر',
      );
      final data = map['data'];

      if (data is Map<String, dynamic>) {
        final parsed = GraveModel.fromJson(data);
        return parsed.copyWith(
          x: x,
          y: y,
          width: width,
          height: height,
          status: data.containsKey('status') ? parsed.status : status,
          deceasedName: parsed.deceasedName ?? deceasedName,
          id: parsed.id.isNotEmpty
              ? parsed.id
              : 'G-${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      return GraveModel(
        id: 'G-${DateTime.now().millisecondsSinceEpoch}',
        x: x,
        y: y,
        width: width,
        height: height,
        status: status,
        deceasedName: deceasedName,
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل إضافة القبر');
    }
  }
}
