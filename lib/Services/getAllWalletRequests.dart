import '../API/api.dart';
import '../models/model_walletRequest.dart';

class GetWalletService {
  Future<WalletData> getWalletData({
    required String token,
  }) async {
    final response = await api().get(
      url: 'http://10.0.2.2:8000/api/my-wallet-requests',
      token: token,
    );

    final role =
    (response['role'] as String).toString();

    final walletBalance =
    (response['wallet'] as num).toDouble();

    final List<dynamic> listJson = response['requests'];

    final requests = listJson
        .map((e) => Model_wallet.fromJson(e as Map<String, dynamic>))
        .toList();

    return WalletData(role: role,wallet: walletBalance, requests: requests);
  }
}
