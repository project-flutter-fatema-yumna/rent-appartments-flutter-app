import 'package:flats_app/models/model_apartment.dart';

class Modal_Order {
  final int id;
  final int userId;
  final int apartmentId;
  final DateTime startDate;
  final DateTime endDate;
  final double fullAmount;
   String status; // pending / accepted / rejected
  final int bankId;
  final DateTime? acceptedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Model_Apartment apartment;
  final ReservationUser? user;

  Modal_Order({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.startDate,
    required this.endDate,
    required this.fullAmount,
    required this.status,
    required this.bankId,
    required this.acceptedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.apartment,
    required this.user,
  });

  factory Modal_Order.fromJson(Map<String, dynamic> json) {
    return Modal_Order(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      apartmentId: _asInt(json['apartment_id']),
      startDate: DateTime.parse(json['start_date'].toString()),
      endDate: DateTime.parse(json['end_date'].toString()),
      fullAmount: _asDouble(json['full_amount']),
      status: json['status'].toString(),
      bankId: _asInt(json['bank_id']),
      acceptedAt: _parseNullableDate(json['accepted_at']),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      
      apartment: Model_Apartment.fromJson(json['apartment']),
      user: json.containsKey('user') && json['user'] != null
          ? ReservationUser.fromJson(json['user'])
          : null,
    );
  }

  static List<Modal_Order> listFromJson(dynamic data) {
    if (data is List) {
      return data.map((e) => Modal_Order.fromJson(e)).toList();
    }
    return [];
  }

  static int _asInt(dynamic v) => int.tryParse(v.toString()) ?? 0;
  static double _asDouble(dynamic v) => double.tryParse(v.toString()) ?? 0.0;

  static DateTime? _parseNullableDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return DateTime.tryParse(s);
  }
}

class ReservationUser {
  final int id;
  final String username;

  ReservationUser({required this.id, required this.username});

  factory ReservationUser.fromJson(Map<String, dynamic> json) {
    return ReservationUser(
      id: int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'].toString(),
    );
  }
}
