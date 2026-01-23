import '../../API/api.dart';
import '../../helper/Host.dart';

class ReservationEditActionService {
  Future<void> accept({required int editId, required String token}) async {
    await api().patch(
      url: "http://${Host.host}:8000/api/reservation-edits/$editId/accept",
      token: token,
    );
  }

  Future<void> reject({required int editId, required String token}) async {
    await api().patch(
      url: "http://${Host.host}:8000/api/reservation-edits/$editId/reject",
      token: token,
    );
  }
}
