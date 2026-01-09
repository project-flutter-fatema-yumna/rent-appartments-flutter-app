import 'package:flats_app/authentication_screens/login_screen.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    await prefs.remove('isLoggedIn');
    Navigator.pushReplacementNamed(context, LoginScreen.id);
    return;
  }
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/logout'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      await prefs.remove('token');
      await prefs.remove('isLoggedIn');
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    } else {
      print('Logout failed: ${response.body}');
    }
  } catch (e) {
    print('Logout error: $e');
  }
}
