class BlockedDate {
  final DateTime start;
  final DateTime end;

  BlockedDate({
    required this.start,
    required this.end,
  });

  factory BlockedDate.fromJson(Map<String, dynamic> json) {
    return BlockedDate(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}
