import 'dart:io';
import '../../API/api.dart';
import '../../helper/Host.dart';

class addApartment {
  Future<dynamic> storeApartment({
    required String token,
    required Map<String, String> data,
    required List<File> images,
  }) async {
    return await api().postApartment(
      url: 'http://${Host.host}:8000/api/apartment',
      token: token,
      fields: data,
      images: images,
    );
  }
}
