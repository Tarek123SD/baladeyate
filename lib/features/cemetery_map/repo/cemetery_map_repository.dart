import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';

class CemeteryMapRepository {
  CemeteryMapRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<GraveModel>> getGraves({
    int cemeteryId = GraveModel.defaultCemeteryId,
  }) async {
    try {
      final response = await _apiService.get(
        EndPoints.graves,
        queryParams: {'cemetery_id': cemeteryId},
      );

      final graves = ApiResponseParser.parseList(
        response.data,
        fromJson: GraveModel.fromJson,
        fallback: 'فشل تحميل القبور',
      );

      return graves
          .where((grave) => grave.width > 0 && grave.height > 0)
          .toList(growable: false);
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل القبور');
    }
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
        // Keep the exact tap-centered map coordinates the delegate chose.
        // Server payloads may omit/alias them and would otherwise move markers.
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
