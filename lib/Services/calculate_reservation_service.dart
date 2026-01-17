import '../API/api.dart';
import '../helper/Host.dart';
import '../models/reservation_calculation.dart';

class CalculateReservationService {
  final api _api = api();
  static  String _baseUrl = 'http://${Host.host}:8000/api';

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Future<ReservationCalculation> calculate({
    required int apartmentId,
    required DateTime start,
    required DateTime end,
    required String token,
  }) async {
    final startStr = _formatDate(start);
    final endStr = _formatDate(end);

    final url =
        '$_baseUrl/apartment/reservations/calculate'
        '?apartment_id=$apartmentId'
        '&start_date=$startStr'
        '&end_date=$endStr';

    final res = await _api.post(
      url: url,
      body: {},
      token: token,
    );

    return ReservationCalculation.fromJson(res);
  }
}
