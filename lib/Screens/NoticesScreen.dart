import 'package:flats_app/MyColors.dart';
import 'package:flats_app/models/model_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/notification_provider.dart';

class notificationScreen extends StatefulWidget {
  static String id = 'notificationScreen';

  @override
  State<notificationScreen> createState() => _notificationScreenState();
}

class _notificationScreenState extends State<notificationScreen> {
  String? token;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('token');
      if (!mounted) return;

      setState(() {
        token = t;
      });

      if (token != null) {
        context
            .read<notification_provider>()
            .getNumberMesseageUnRead(token: token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provi = context.watch<notification_provider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: provi.isLoading
          ? const Center(
        child: SpinKitThreeBounce(color: Colors.blue, size: 20),
      )
          : RefreshIndicator(
        onRefresh: () async {
          if (token == null) return;
          await provi.getNumberMesseageUnRead(token: token!);
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (provi.unReadList.isNotEmpty) ...[
              _sectionTitle("Unread"),
              const SizedBox(height: 8),
              ...provi.unReadList.map(
                    (n) => InkWell(
                  onTap: () {
                    if (token == null) return;
                    provi.markNotificationAsRead(
                      token: token!,
                      notificationId: n.id,
                    );
                    print("token = $token , id = ${n.id}");
                  },
                  child: notificationCardByType(n),
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (provi.readList.isNotEmpty) ...[
              _sectionTitle("Read"),
              const SizedBox(height: 8),
              ...provi.readList.map(
                    (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: notificationCardByType(n),
                ),
              ),
            ],
            if (provi.unReadList.isEmpty && provi.readList.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: Text("No notifications yet")),
              ),
          ],
        ),
      ),
    );
  }
}


Widget _infoRow({required IconData icon, required String text}) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey.shade700),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
        ),
      ),
    ],
  );
}

Widget _amountChip({
  required String label,
  required String amount,
  required Color color,
}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "$label: $amount",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ),
  );
}

String _formatAmount(double? value) {
  if (value == null) return "0.00";
  return value.toStringAsFixed(2);
}

String formatNotificationTime(DateTime dt) {
  return "${dt.year}-${dt.month}-${dt.day}";
}

class _SimpleMessageCard extends StatelessWidget {
  final NotificationItemModel notificationItemModel;
  final Color accent;
  final IconData icon;
  final String title;

  const _SimpleMessageCard({
    super.key,
    required this.notificationItemModel,
    required this.accent,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: myColors.colorWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 80,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatNotificationTime(notificationItemModel.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notificationItemModel.data.message.isEmpty
                      ? "Notification"
                      : notificationItemModel.data.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class TenantCancelledBookingCard extends StatelessWidget {
  final NotificationItemModel notificationItemModel;
  const TenantCancelledBookingCard({super.key, required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    final reservation = notificationItemModel.data.reservation;

    if (reservation == null) {
      return _SimpleMessageCard(
        notificationItemModel: notificationItemModel,
        accent: Colors.orange,
        icon: Icons.event_busy,
        title: "Booking cancelled",
      );
    }

    //final tenantName = reservation.user?.username ?? "Tenant";

    return Container(
      padding: const EdgeInsets.all(14),
      height: 220,
      decoration: BoxDecoration(
        color: myColors.colorWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.event_busy, color: Colors.orange),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Booking cancelled",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatNotificationTime(notificationItemModel.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Your reservation has been canceled',
                 // notificationItemModel.data.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.home_work_outlined,
                  text:
                  "Reservation : ${reservation.startDate.year} - ${reservation.startDate.month} - ${reservation.startDate.day} "
                      "To ${reservation.endDate.year} - ${reservation.endDate.month} - ${reservation.endDate.day}",
                ),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.location_on,
                  text:
                  'Location : ${reservation.apartment.governorate}-${reservation.apartment.city}',
                ),
                const SizedBox(height: 6),
                _amountChip(
                  label: "Refund to tenant",
                  amount: _formatAmount(notificationItemModel.data.refundedMoney),
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletAddedCard extends StatelessWidget {
  final NotificationItemModel notificationItemModel;
  const WalletAddedCard({super.key, required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: myColors.colorWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_card, color: Colors.green),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Money added",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatNotificationTime(notificationItemModel.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notificationItemModel.data.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                _amountChip(
                  label: "Added",
                  amount: _formatAmount(notificationItemModel.data.moneyAddedToWallet),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletWithdrawnCard extends StatelessWidget {
  final NotificationItemModel notificationItemModel;
  const WalletWithdrawnCard({super.key, required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: myColors.colorWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.payments_outlined, color: Colors.blue),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Money withdrawn",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatNotificationTime(notificationItemModel.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notificationItemModel.data.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                _amountChip(
                  label: "Withdrawn",
                  amount: _formatAmount(notificationItemModel.data.moneyWithdrawn),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingAcceptedCard extends StatelessWidget {
  final NotificationItemModel notificationItemModel;
  const BookingAcceptedCard({super.key, required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    const accent = Colors.green;
    final reservation = notificationItemModel.data.reservation;

    if (reservation == null) {
      return _SimpleMessageCard(
        notificationItemModel: notificationItemModel,
        accent: accent,
        icon: Icons.check_circle,
        title: "Booking accepted",
      );
    }

    final ownerName = reservation.apartment.owner?.username ?? "Owner";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: myColors.colorWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 130,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.check_circle, color: accent),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Booking accepted",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatNotificationTime(notificationItemModel.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notificationItemModel.data.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                _infoRow(
                  icon: Icons.verified_user_outlined,
                  text: "Owner: $ownerName",
                ),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.home_work_outlined,
                  text:
                  "Reservation : ${reservation.startDate.year} - ${reservation.startDate.month} - ${reservation.startDate.day} "
                      "To ${reservation.endDate.year} - ${reservation.endDate.month} - ${reservation.endDate.day}",
                ),
                const SizedBox(height: 6),
                _amountChip(
                  label: "Charged",
                  amount: _formatAmount(
                    double.tryParse(reservation.fullAmount.toString()),
                  ),
                  color: accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingRejectedCard extends StatelessWidget {
  final NotificationItemModel notificationItemModel;
  const BookingRejectedCard({super.key, required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    const accent = Colors.red;
    final reservation = notificationItemModel.data.reservation;

    if (reservation == null) {
      return _SimpleMessageCard(
        notificationItemModel: notificationItemModel,
        accent: accent,
        icon: Icons.cancel,
        title: "Booking rejected",
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: myColors.colorWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 120,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.cancel, color: accent),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Booking rejected",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatNotificationTime(notificationItemModel.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notificationItemModel.data.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                _infoRow(
                  icon: Icons.home_work_outlined,
                  text:
                  "Reservation : ${reservation.startDate.year} - ${reservation.startDate.month} - ${reservation.startDate.day} "
                      "To ${reservation.endDate.year} - ${reservation.endDate.month} - ${reservation.endDate.day}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingCancelledRefundCard extends StatelessWidget {
  final NotificationItemModel notificationItemModel;
  const BookingCancelledRefundCard({super.key, required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    const accent = Colors.orange;
    final reservation = notificationItemModel.data.reservation;

    if (reservation == null) {
      return _SimpleMessageCard(
        notificationItemModel: notificationItemModel,
        accent: accent,
        icon: Icons.currency_exchange,
        title: "Booking cancelled",
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: myColors.colorWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 130,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.currency_exchange, color: accent),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Booking cancelled",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      formatNotificationTime(notificationItemModel.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notificationItemModel.data.message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                _infoRow(
                  icon: Icons.home_work_outlined,
                  text:
                  "Reservation : ${reservation.startDate.year} - ${reservation.startDate.month} - ${reservation.startDate.day} "
                      "To ${reservation.endDate.year} - ${reservation.endDate.month} - ${reservation.endDate.day}",
                ),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.location_on_outlined,
                  text:
                  "Location: ${reservation.apartment.governorate}-${reservation.apartment.city}",
                ),
                const SizedBox(height: 6),
                _amountChip(
                  label: "Refunded",
                  amount: _formatAmount(notificationItemModel.data.refundedMoney),
                  color: accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionTitle(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
  );
}

Widget notificationCardByType(NotificationItemModel noti) {
  final cardType = noti.type.split('\\').last;
  switch (cardType) {
    case 'ReservationAcceptedNotification':
      return BookingAcceptedCard(notificationItemModel: noti);
    case 'ReservationRejectedNotification':
      return BookingRejectedCard(notificationItemModel: noti);
    case 'ReservationCancelledNotification':
      return BookingCancelledRefundCard(notificationItemModel: noti);
    case 'TenantCancelReservationNotification':
      return TenantCancelledBookingCard(notificationItemModel: noti);
    case 'MoneyAddedToWaletNotification':
      return WalletAddedCard(notificationItemModel: noti);
    case 'MoneywithdrawnFromWaletNotification':
      return WalletWithdrawnCard(notificationItemModel: noti);
    default:
      return _SimpleMessageCard(
        notificationItemModel: noti,
        accent: Colors.blue,
        icon: Icons.notifications,
        title: "Notification",
      );
  }
}
