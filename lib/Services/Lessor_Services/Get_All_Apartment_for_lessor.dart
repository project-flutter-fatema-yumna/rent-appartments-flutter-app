import '../../API/api.dart';
import '../../models/model_apartment.dart';

class get_all_apartment_for_lessor {
  Future<List<Model_Apartment>> getApatment_Lessor({required String token}) async {
    final response = await api().get(
      url: 'http://10.0.2.2:8000/api/apartment/ownedApartments',
      token: token,
    );
      print("the response is : $response");
    if (response is List) {
      return response.map((e) => Model_Apartment.fromJson(e)).toList();
    }

    if (response is Map<String, dynamic>) {
      final data = response['owned apartments'];

      if (data is List) {
        return data.map((e) => Model_Apartment.fromJson(e)).toList();
      }

      if (data is Map && data['owned apartments'] is List) {
        final List list = data['owned apartments'];
        return list.map((e) => Model_Apartment.fromJson(e)).toList();
      }
    }

    throw Exception("Unexpected response format: ${response.runtimeType}");
  }
}
