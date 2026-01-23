import 'model_order.dart';

class ReservationEditModel {
  final int id; // editId
  final DateTime startDate;
  final DateTime endDate;
  final double fullAmount;
  final String status; // pending
  final Modal_Order reservation;

  ReservationEditModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.fullAmount,
    required this.status,
    required this.reservation,
  });

  factory ReservationEditModel.fromJson(Map<String, dynamic> json) {
    return ReservationEditModel(
      id: int.parse(json['id'].toString()),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      fullAmount: double.parse(json['full_amount'].toString()),
      status: (json['status'] ?? 'pending').toString(),
      reservation: Modal_Order.fromJson(json['reservation']),
    );
  }
}