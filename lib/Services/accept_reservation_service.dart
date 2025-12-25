import 'package:flats_app/API/api.dart';

class AcceptReservationService {
  Future<dynamic> accept({
    required int reservationId,
    required String token,
  }) async {
    return await api().patch(
      url: 'http://10.0.2.2:8000/api/lessor/reservations/$reservationId/accept',
      token: token,
    );
  }
}
