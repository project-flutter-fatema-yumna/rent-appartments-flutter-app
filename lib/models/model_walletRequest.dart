class Model_wallet {
  final int id;
  final double amount;
  final String type;   // withdraw / add
  final String status; // pending / accepted / rejected
  final DateTime createdAt;

  Model_wallet({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory Model_wallet.fromJson(Map<String, dynamic> json) {
    return Model_wallet(
      id: json['id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WalletData {
  final String role;
  final double wallet;
  final List<Model_wallet> requests;

  WalletData({required this.role,required this.wallet, required this.requests});
}
