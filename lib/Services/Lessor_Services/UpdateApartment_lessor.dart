import '../../API/api.dart';

class UpdateApartmentService {
  Future<dynamic> updateApartment({
    required int apartmentId,
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await api().put(
      url: 'http://10.0.2.2:8000/api/apartment/updateInfo/$apartmentId',
      body: data,
      token: token,
    );
  }
}
