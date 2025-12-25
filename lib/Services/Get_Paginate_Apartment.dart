import 'package:flats_app/models/model_apartment.dart';

import '../API/api.dart';

class get_apartment {

  Future<List<Model_Apartment>> getAllApartment({required String token}) async {
    final response = await api().get(
      url: 'http://10.0.2.2:8000/api/apartment/paginate',
      token: token,
    );
    //print('the Response is $response');
    List<dynamic> data = response['data'];
    List<Model_Apartment> apartmentList=data.map((item)=>Model_Apartment.fromJson(item)).toList();
    return apartmentList;
  }


}