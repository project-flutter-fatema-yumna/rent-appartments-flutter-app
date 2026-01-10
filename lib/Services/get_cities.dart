import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getCitiesAccourdingToGovernorate(
  String governorate,
) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:8000/api/apartment/validCities/${Uri.encodeComponent(governorate)}',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item.toString()).toList();
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch cities');
    }
  } catch (e) {
    rethrow;
  }
}
