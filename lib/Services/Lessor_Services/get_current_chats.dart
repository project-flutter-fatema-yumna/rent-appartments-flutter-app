import 'package:flats_app/API/api.dart';  // عدّل المسار حسب مشروعك
import 'package:flats_app/models/model_current_chat.dart';

class GetCurrentChatsService {
  Future<List<ModelCurrentChat>> getCurrentChats({
    required String token,
  }) async {
    final result = await api().get(
      url: 'http://10.0.2.2:8000/api/lessor/getCurrentChats', // نفس تبع Postman بس للـ Emulator
      token: token,
    );
    if (result is List) {
      return result
          .map((item) => ModelCurrentChat.fromJson(item))
          .toList();
    } else {
      throw Exception('Unexpected response format');
    }
  }
}
