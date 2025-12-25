import '../API/api.dart';

class reserveService {
  Future<dynamic> reserveApatment({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await api().post(
      url: 'http://10.0.2.2:8000/api/reserve',
      body: data,
      token: token
    );
  }
}
