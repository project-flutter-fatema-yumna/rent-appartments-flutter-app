import '../../API/api.dart';
import '../models/model_pagaination.dart';

class ApartmentsPaginationService {
  Future<model_page> getFirstPage({required String token}) async {
    final res = await api().get(
      url: 'http://10.0.2.2:8000/api/apartment/paginate?page=1',
      token: token,
    );
    return model_page.fromJson(res);
  }

  Future<model_page> getByUrl({required String url, required String token}) async {
    final res = await api().get(url: url, token: token);
    return model_page.fromJson(res);
  }
}
