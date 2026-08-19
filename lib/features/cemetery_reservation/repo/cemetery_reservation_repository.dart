import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/cemetery_reservation/models/grave_reservation.dart';

class CemeteryReservationRepository {
  CemeteryReservationRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<GraveReservation>> getReservations() async {
    try {
      final response = await _apiService.get(EndPoints.graveReservations);
      return ApiResponseParser.parseList(
        response.data,
        fromJson: GraveReservation.fromJson,
        fallback: 'فشل تحميل طلبات حجز القبور',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحميل طلبات حجز القبور',
      );
    }
  }

  Future<GraveReservation> getReservation(int id) async {
    try {
      final response = await _apiService.get(EndPoints.graveReservationById(id));
      return ApiResponseParser.parseItem(
        response.data,
        fromJson: GraveReservation.fromJson,
        fallback: 'فشل تحميل تفاصيل طلب الحجز',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحميل تفاصيل طلب الحجز',
      );
    }
  }

  Future<GraveReservation> submitReservation({
    required int graveId,
    required String deceasedName,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.graveReservations,
        data: {
          'grave_id': graveId,
          'deceased_name': deceasedName.trim(),
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: GraveReservation.fromJson,
        fallback: 'فشل إرسال طلب حجز القبر',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل إرسال طلب حجز القبر',
      );
    }
  }

  Future<GraveReservation> cancelReservation(int id) async {
    try {
      final response = await _apiService.patch(
        EndPoints.graveReservationCancel(id),
        data: const {},
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: GraveReservation.fromJson,
        fallback: 'فشل إلغاء طلب الحجز',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل إلغاء طلب الحجز',
      );
    }
  }
}
