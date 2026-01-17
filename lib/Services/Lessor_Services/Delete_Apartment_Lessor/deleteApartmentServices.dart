import 'package:flats_app/API/api.dart';

import '../../../helper/Host.dart';

class deleteApatment {
  Future<dynamic> deleteApartmentSevic({
    required int apartmentId,
    required String token,
  }) async {
    return await api().delete(
      url: 'http://${Host.host}:8000/api/apartment/delete/$apartmentId',
      token: token,
    );
  }
}
