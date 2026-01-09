import 'package:flats_app/API/api.dart';

class deleteApatment {
  Future<dynamic> deleteApartmentSevic({
    required int apartmentId,
    required String token,
  }) async {
    return await api().delete(
      url: 'http://10.0.2.2:8000/api/apartment/delete/$apartmentId',
      token: token,
    );
  }
}
