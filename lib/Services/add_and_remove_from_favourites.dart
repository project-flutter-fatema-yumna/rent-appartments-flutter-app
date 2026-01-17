import 'package:flats_app/helper/Host.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<int?> toggleFavoriteStatus(int apartmentId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) return null;

  final String url = 'http://${Host.host}:8000/api/apartment/$apartmentId/favorite';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.statusCode;
    } else {
      print('Error Status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Exception: $e');
    return null;
  }
}
