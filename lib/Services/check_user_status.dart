import 'dart:convert';
import 'package:http/http.dart' as http;

import '../helper/Host.dart';

Future<String> getUserStatus(String phone) async {
  try {
    var response = await http.post(
      Uri.parse('http://${Host.host}:8000/api/user/status'),
      headers: {"Content-Type": 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var status = json['state'];
      return status;
    } else {
      print(response.statusCode);
      throw Exception('Something went wrong');
    }
  } catch (e) {
    rethrow;
  }
}
