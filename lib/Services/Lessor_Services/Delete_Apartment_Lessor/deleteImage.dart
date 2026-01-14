import 'package:flats_app/API/api.dart';

class deleteImage {
  Future<dynamic> deletedImageMethod({
    required int imageId,
    String? token,
  }) async {
    return await api().delete(
      url: 'http://10.0.2.2:8000/api/apartment/deleteImage/$imageId',
      token: token,
    );
  }
}
