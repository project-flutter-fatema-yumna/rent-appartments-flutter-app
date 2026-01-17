import 'package:flats_app/API/api.dart';

import '../helper/Host.dart';
import '../models/blocked_date.dart';

class get_blocked_dates_service{
  Future<List<BlockedDate>> getBlockedDates({required int apartmentId,required String token})async{
    final response=await api().get(url: 'http://${Host.host}:8000/api/apartment/apartments/${apartmentId}/blocked-dates',token: token);
    final List list = response['data'] as List;
    return list.map((e) => BlockedDate.fromJson(e)).toList();
  }
}