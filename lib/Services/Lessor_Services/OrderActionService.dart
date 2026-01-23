import '../../API/api.dart';
import '../../helper/Host.dart';

enum OrderActionType { normal, edit }

class OrderActionService {
  Future<void> accept({
    required int id,
    required OrderActionType type,
    required String token,
  }) async {
    final url = type == OrderActionType.edit
        ? "http://${Host.host}:8000/api/reservation-edits/$id/accept"
        : "http://${Host.host}:8000/api/lessor/reservations/$id/accept";

    await api().patch(url: url, token: token);
  }

  Future<void> reject({
    required int id,
    required OrderActionType type,
    required String token,
  }) async {
    final url = type == OrderActionType.edit
        ? "http://${Host.host}:8000/api/reservation-edits/$id/reject"
        : "http://${Host.host}:8000/api/lessor/reservations/$id/reject";

    await api().patch(url: url, token: token);
  }
}
