import '../../API/api.dart';

class updateApartment {
  Future<dynamic> upDate({
    required String token,
    required int apartmentId,
  }) async {
    return await api().put(
      url: 'http://10.0.2.2:8000/api/apartment/updateInfo/$apartmentId',
      token: token,
    );
  }
}
