import 'package:flats_app/API/api.dart';

import '../../../helper/Host.dart';

class deleteImage {
  Future<dynamic> deletedImageMethod({
    required int imageId,
    String? token,
  }) async {
    return await api().delete(
      url: 'http://${Host.host}:8000/api/apartment/deleteImage/$imageId',
      token: token,
    );
  }
}
