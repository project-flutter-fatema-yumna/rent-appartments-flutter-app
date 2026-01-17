import 'dart:convert';
import 'package:flats_app/models/model_apartment.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/Host.dart';

Future<List<Model_Apartment>> fetchFavorites() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('http://${Host.host}:8000/api/favorites'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Model_Apartment.fromJson(item)).toList();
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch favorites');
    }
  } catch (e) {
    print('Exception: $e');
    rethrow;
  }
}
