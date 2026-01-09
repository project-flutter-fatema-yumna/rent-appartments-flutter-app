class ReservationCalculation {
  final String rentType;
  final int period;
  final num total;

  ReservationCalculation({
    required this.rentType,
    required this.period,
    required this.total,
  });

  factory ReservationCalculation.fromJson(Map<String, dynamic> json) {
    return ReservationCalculation(
      rentType: json['rent_type'] ?? '',
      period: json['period'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
