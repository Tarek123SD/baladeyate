import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/admin/models/grave.dart';

class AdminRepository {
  AdminRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<List<Grave>> getGraves() async {
    try {
      final response = await _apiService.get(EndPoints.graves);
      return ApiResponseParser.parseList(
        response.data,
        fromJson: Grave.fromJson,
        fallback: 'فشل تحميل المدافن',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل المدافن');
    }
  }

  Future<Grave> getGraveById(int id) async {
    try {
      final response = await _apiService.get(EndPoints.graveById(id));
      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Grave.fromJson,
        fallback: 'فشل تحميل بيانات القبر',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحميل بيانات القبر',
      );
    }
  }
}
