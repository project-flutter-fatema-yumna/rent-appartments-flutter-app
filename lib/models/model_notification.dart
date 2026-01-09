import 'package:flats_app/models/model_order.dart';

class NotificationsResponseModel {
  final List<NotificationItemModel> unread;
  final List<NotificationItemModel> read;

  NotificationsResponseModel({
    required this.unread,
    required this.read,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    List<NotificationItemModel> parseList(String key) {
      final list = (json[key] as List? ?? []);
      return list
          .map((e) => NotificationItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return NotificationsResponseModel(
      unread: parseList('unread'),
      read: parseList('read'),
    );
  }

  List<NotificationItemModel> get all => [...unread, ...read];
}

///read //unread
class NotificationItemModel {
  final String id;
  final String type; // App\\Notifications\\ReservationAcceptedNotification
  final String? notifiableType;
  final int? notifiableId;

  final NotificationDataModel data;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? readAt;

  NotificationItemModel({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    this.readAt,
    this.notifiableType,
    this.notifiableId,
  });

  bool get isRead => readAt != null;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      notifiableType: json['notifiable_type']?.toString(),
      notifiableId: _asIntNullable(json['notifiable_id']),
      data: NotificationDataModel.fromJson(
        (json['data'] as Map<String, dynamic>?) ?? {},
      ),
      readAt: _parseNullableDate(json['read_at']),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

//data
class NotificationDataModel {
  final Map<String, dynamic> raw;

  NotificationDataModel({required this.raw});

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(raw: json);
  }

  String get message {
    final direct = getString('message') ?? getString('Message');
    if (direct != null) return direct;

    for (final entry in raw.entries) {
      final key = entry.key.toString().trim().toLowerCase();
      if (key == 'message') {
        final value = entry.value.toString().trim();
        if (value.isNotEmpty) return value;
      }
    }
    return '';
  }

  double? get moneyAddedToWallet {
    return getDouble('Money added to you wallet') ??
        getDouble('money added to your wallet');
  }

  double? get moneyWithdrawnFromWallet {
    return getDouble('Money withdrawn from you wallet') ??
        getDouble('money withdrawn from you wallet') ??
        getDouble('money withdrawn form your wallet');
  }

  double? get moneyWithdrawn => moneyWithdrawnFromWallet;

  double? get refundedMoney {
    return getDouble('Refund money') ??
        getDouble('refund money') ??
        getDouble('money refunded to your wallet');
  }

  Modal_Order? get reservation {
    final r1 = raw['reservation'];
    if (r1 is Map<String, dynamic>) {
      return Modal_Order.fromJson(r1);
    }

    final r2 = raw['Reservaion'];
    if (r2 is Map<String, dynamic>) {
      return Modal_Order.fromJson(r2);
    }

    for (final entry in raw.entries) {
      final key = entry.key.toString().trim().toLowerCase();
      if (key == 'reservation' || key == 'reservaion') {
        final v = entry.value;
        if (v is Map<String, dynamic>) {
          return Modal_Order.fromJson(v);
        }
      }
    }
    return null;
  }

  String? getString(String key) {
    final v = raw[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  double? getDouble(String key) => _asDoubleNullable(raw[key]);
}

int? _asIntNullable(dynamic v) => int.tryParse(v?.toString() ?? '');

double? _asDoubleNullable(dynamic v) => double.tryParse(v?.toString() ?? '');

DateTime? _parseNullableDate(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return null;
  return DateTime.tryParse(s);
}





