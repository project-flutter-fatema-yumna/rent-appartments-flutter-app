import 'dart:convert';

import 'package:flats_app/API/api.dart';

class get_all_cityes{
    Future<List<String>> getCityes({
    required String governorate,
    required String token,
})async{
    final response=await api().get(url: 'http://10.0.2.2:8000/api/apartment/validCities/$governorate',token: token);
    final List list = response as List;
    return list.map((e) => e.toString()).toList();
  }
}