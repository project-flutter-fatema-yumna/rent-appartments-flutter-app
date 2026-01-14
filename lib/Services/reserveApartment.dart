import 'package:flats_app/API/api.dart';
import 'package:http/http.dart';

class reserveService {
  Future<dynamic> reserveApatment({
    required String token,
    required int apartmentId,
    required DateTime start,
    required DateTime end,
  }) async {
    return await api().postFormData(
      url: 'http://10.0.2.2:8000/api/reserve',
      body: {
        "apartment_id": apartmentId.toString(),
        "start_date": start.toIso8601String().split('T').first,
        "end_date": end.toIso8601String().split('T').first,
      },
      token: token
    );
  }
}
