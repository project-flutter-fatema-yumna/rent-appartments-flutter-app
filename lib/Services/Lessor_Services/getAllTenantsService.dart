import 'package:flats_app/API/api.dart';

import '../../models/model_tenantUser.dart';

class get_All_Tenants{
  Future<List<Model_tenant>> getTenants({required String token})async{
    final response =await api().get(url: 'http://10.0.2.2:8000/api/lessor/getTenants',token: token);
    final List tenantsJson = response["tenants_the_lessor_can_text_first"] ?? [];

    return tenantsJson
        .map((e) => Model_tenant.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}