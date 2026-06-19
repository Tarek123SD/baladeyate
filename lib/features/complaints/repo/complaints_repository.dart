import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';

class ComplaintsRepository {
  ComplaintsRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<List<Complaint>> getComplaints() async {
    try {
      final response = await _apiService.get(EndPoints.complaints);
      return _parseComplaintsList(response.data);
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل الشكاوى');
    }
  }

  Future<Complaint> getComplaintById(int id) async {
    try {
      final response = await _apiService.get(EndPoints.complaintById(id));
      return _parseComplaint(response.data);
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل الشكوى');
    }
  }

  Future<Complaint> createComplaint({
    required String description,
    required String priority,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.complaints,
        data: {
          'description': description,
          'priority': priority,
        },
      );

      return _parseComplaint(response.data);
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل إرسال الشكوى');
    }
  }

  Future<Complaint> updateComplaint({
    required int id,
    required String description,
    required String priority,
  }) async {
    try {
      final response = await _apiService.put(
        EndPoints.complaintById(id),
        data: {
          'description': description,
          'priority': priority,
        },
      );

      return _parseComplaint(response.data);
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحديث الشكوى');
    }
  }

  Future<void> deleteComplaint(int id) async {
    try {
      final response = await _apiService.delete(
        EndPoints.complaintById(id),
        data: const {},
      );
      ApiResponseParser.expectMap(
        response.data,
        fallback: 'فشل حذف الشكوى',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل حذف الشكوى');
    }
  }

  List<Complaint> _parseComplaintsList(dynamic data) {
    final map = ApiResponseParser.expectMap(data, fallback: 'فشل تحميل الشكاوى');
    final payload = map['data'];
    final List<dynamic> rawList;

    if (payload is List) {
      rawList = payload;
    } else if (payload is Map<String, dynamic> && payload['data'] is List) {
      rawList = payload['data'] as List<dynamic>;
    } else {
      rawList = const [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Complaint.fromJson)
        .toList();
  }

  Complaint _parseComplaint(dynamic data) {
    final payload = ApiResponseParser.expectData(data);
    if (payload is! Map<String, dynamic>) {
      throw Exception('استجابة غير صالحة من الخادم');
    }

    return Complaint.fromJson(payload);
  }
}
