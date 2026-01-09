import 'package:flats_app/API/api.dart';

class postChatSevices {
  Future<dynamic> postMessage({
    required String token,
    required int desId,
    required String content,
  }) async {
    final response = await api().postFormData(
      url: 'http://10.0.2.2:8000/api/user/sendMessage/${desId}',
      body: {"content": content},
      token: token,
    );
    return response;
  }
}
