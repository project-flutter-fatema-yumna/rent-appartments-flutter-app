import 'dart:io';
import '../API/api.dart';

class addApartment {
  Future<dynamic> storeApartment({
    required String token,
    required Map<String, String> data,
    required List<File> images,
  }) async {
    return await api().postApartment(
      url: 'http://10.0.2.2:8000/api/apartment',
      token: token,
      fields: data,
      images: images,
    );
  }
}
