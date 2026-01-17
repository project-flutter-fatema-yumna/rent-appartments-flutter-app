import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/Host.dart';

Future<Map<String, dynamic>> rateApartment({
  required int apartmentId,
  required double stars,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('No token found');
  }

  final url = Uri.parse('http://${Host.host}:8000/api/apartment/rate/$apartmentId');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'stars': stars.toInt().toString()}),
  );
  print(apartmentId);
  print(response.statusCode);
  print(response.body);

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return {
      'success': true,
      'message': data['message'],
      'home_rate': data['current apartment rate '],
    };
  } else {
    return {'success': false, 'message': data['message'], 'details': data};
  }
}
