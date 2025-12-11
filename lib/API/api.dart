
import 'dart:convert';

import 'package:http/http.dart' as http;
class api{
  Future<dynamic> get({required String url}) async{
    http.Response response =await http.get(Uri.parse(url),headers: {
      'Accept': 'application/json',
    });
    if(response.statusCode==200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception(
        'there is a problem with status Code ${response.statusCode}',
      );
    }
  }
}