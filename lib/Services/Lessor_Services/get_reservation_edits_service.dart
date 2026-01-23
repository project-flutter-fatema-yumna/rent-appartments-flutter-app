import '../../API/api.dart';
import '../../helper/Host.dart';
import '../../models/reservation_edit_model.dart';

class GetReservationEditsService {
  Future<List<ReservationEditModel>> getPending({required String token}) async {
    final data = await api().get(
      url: "http://${Host.host}:8000/api/reservation-edits/pending",
      token: token,
    );

    return (data as List)
        .map((e) => ReservationEditModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
