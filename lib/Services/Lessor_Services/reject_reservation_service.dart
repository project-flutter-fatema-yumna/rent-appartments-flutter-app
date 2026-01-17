import 'package:flats_app/API/api.dart';

import '../../helper/Host.dart';

class RejectReservationService {
  Future<dynamic> reject({
    required int reservationId,
    required String token,
  }) async {
    return await api().patch(
      url: 'http://${Host.host}:8000/api/lessor/reservations/$reservationId/reject',
      token: token,
    );
  }
}
