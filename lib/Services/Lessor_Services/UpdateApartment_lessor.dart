import '../../API/api.dart';
import '../../helper/Host.dart';

class UpdateApartmentService {
  Future<dynamic> updateApartment({
    required int apartmentId,
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await api().put(
      url: 'http://${Host.host}:8000/api/apartment/updateInfo/$apartmentId',
      body: data,
      token: token,
    );
  }
}
