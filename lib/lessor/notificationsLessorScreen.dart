import 'package:flats_app/MyColors.dart';
import 'package:flats_app/models/model_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/notification_provider.dart';

class notificationsLessor extends StatefulWidget {
  static String id = 'notificationsLessor';

  @override
  State<notificationsLessor> createState() => _notificationsLessorState();
}

class _notificationsLessorState extends State<notificationsLessor> {
  final String token='1|EZIEoy5aLnCdi5XP2jxeaGtnNT60yqCeYyfoaP0W9a2b30e6';
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<notification_provider>().getNumberMesseageUnRead(
        token: token,
      );
    });
  }

 /* @override
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
        context.read<notification_provider>()
            .getNumberMesseageUnRead(token: token!);
      }
      print(token);
    });
  }*/


  @override
  Widget build(BuildContext context) {
    final provi = context.watch<notification_provider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: provi.isLoading
          ? Center(child: SpinKitThreeBounce(color: Colors.blue, size: 20))
          : RefreshIndicator(
              onRefresh: () => provi.getNumberMesseageUnRead(token: token!),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (provi.unReadList.isNotEmpty) ...[
                    _sectionTitle("Unread"),
                    const SizedBox(height: 8),
                    ...provi.unReadList.map((n)=>InkWell(
                      onTap: (){
                        provi.markNotificationAsRead(token: token!, notificationId:n.id);
                      },
                      child: notificationCardByType(n),
                    )),

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
                  if(provi.unReadList.isEmpty && provi.readList.isEmpty)
                    const Padding(padding: EdgeInsets.only(top: 80),
                    child: Center(child: Text("No notifications yet"),),
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
String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '${date.day} ${_monthName(date.month)}';
}

String _monthName(int month) {
  const names = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return names[month];
}
String formatNotificationTime(DateTime createdAt) {
  final now = DateTime.now();
  final diff = now.difference(createdAt);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d';

  return _formatDate(createdAt);
}


class TenantCancelledBookingCard extends StatelessWidget {
  final NotificationItemModel notificationItemModel;
  const TenantCancelledBookingCard({super.key,required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
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
          // Left accent
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
                // Header: icon + title + time
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
                      "15m",
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
                // Details
                _infoRow(icon: Icons.person_outline, text: "Tenant: ${notificationItemModel.data.reservation!.user!.username}"),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.home_work_outlined,
                  text: "Reservation :"
                      " ${notificationItemModel.data.reservation!.startDate.year} - ${notificationItemModel.data.reservation!.startDate.month} - ${notificationItemModel.data.reservation!.startDate.day} "
                      "To"
                      " ${notificationItemModel.data.reservation!.endDate.year} - ${notificationItemModel.data.reservation!.endDate.month} - ${notificationItemModel.data.reservation!.endDate.day}",
                ),
                const SizedBox(height: 6),
                _infoRow(icon: Icons.location_on, text: 'Location : ${notificationItemModel.data.reservation!.apartment.governorate}-${notificationItemModel.data.reservation!.apartment.city}'),
                const SizedBox(height: 6),
                _amountChip(
                  label: "Refund to tenant",
                  amount: notificationItemModel.data.refundedMoney.toString(),
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
  const WalletAddedCard({super.key,required this.notificationItemModel});

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
          // Left accent
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
                // Header
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
                      "${formatNotificationTime(notificationItemModel.createdAt)}",
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
                  amount: notificationItemModel.data.moneyAddedToWallet.toString(),
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
  const WalletWithdrawnCard({super.key,required this.notificationItemModel});

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
          // Left accent
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
                // Header
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: Colors.blue,
                      ),
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
                      "${formatNotificationTime(notificationItemModel.createdAt)}",
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
                  amount: notificationItemModel.data.moneyWithdrawn.toString(),
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
  const BookingAcceptedCard({super.key,required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    const accent = Colors.green;

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
          // Left accent
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
                // Header
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
                      "${formatNotificationTime(notificationItemModel.createdAt)}",
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
                  text: "Owner:${notificationItemModel.data.reservation!.apartment.owner!.username}",
                ),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.home_work_outlined,
                  text: "Reservation :"
                      " ${notificationItemModel.data.reservation!.startDate.year} - ${notificationItemModel.data.reservation!.startDate.month} - ${notificationItemModel.data.reservation!.startDate.day} "
                      "To"
                      " ${notificationItemModel.data.reservation!.endDate.year} - ${notificationItemModel.data.reservation!.endDate.month} - ${notificationItemModel.data.reservation!.endDate.day}",
                ),
                const SizedBox(height: 6),

                _amountChip(
                  label: "Charged",
                  amount: "${notificationItemModel.data.reservation!.fullAmount}",
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
  const BookingRejectedCard({super.key,required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    const accent = Colors.red;

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
          // Left accent
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
                // Header
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
                      "${formatNotificationTime(notificationItemModel.createdAt)}",
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

                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.home_work_outlined,
                  text: "Reservation :"
                      " ${notificationItemModel.data.reservation!.startDate.year} - ${notificationItemModel.data.reservation!.startDate.month} - ${notificationItemModel.data.reservation!.startDate.day} "
                      "To"
                      " ${notificationItemModel.data.reservation!.endDate.year} - ${notificationItemModel.data.reservation!.endDate.month} - ${notificationItemModel.data.reservation!.endDate.day}",
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
  const BookingCancelledRefundCard({super.key,required this.notificationItemModel});

  @override
  Widget build(BuildContext context) {
    const accent = Colors.orange;

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
          // Left accent
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
                // Header
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
                      "${formatNotificationTime(notificationItemModel.createdAt)}",
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
                  text: "Reservation :"
                      " ${notificationItemModel.data.reservation!.startDate.year} - ${notificationItemModel.data.reservation!.startDate.month} - ${notificationItemModel.data.reservation!.startDate.day} "
                      "To"
                      " ${notificationItemModel.data.reservation!.endDate.year} - ${notificationItemModel.data.reservation!.endDate.month} - ${notificationItemModel.data.reservation!.endDate.day}",
                ),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.location_on_outlined,
                  text: "Location: ${notificationItemModel.data.reservation!.apartment.governorate}-${notificationItemModel.data.reservation!.apartment.city}",
                ),
                const SizedBox(height: 6),

                _amountChip(
                  label: "Refunded",
                  amount: notificationItemModel.data.refundedMoney.toString(),
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

Widget _notifTile(
  BuildContext context, {
  required String id,
  required String message,
  required String type,
  required bool isUnread,
}) {
  final p = context.read<notification_provider>();
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: () {
        if (isUnread) {
          p.MoveUnreadTORead(id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isUnread
                ? Colors.blue.withOpacity(0.25)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6, right: 10),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.isEmpty ? "Notification" : message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.split('\\').last,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget notificationCardByType(NotificationItemModel noti){
  final cardType=noti.type.split('\\').last;
  //print("TYPE = ${noti.type}");
  //print("cardType = ${noti.type.split('\\').last}");
  switch (cardType){
    case 'ReservationAcceptedNotification':
      return  BookingAcceptedCard(notificationItemModel:noti,);
    case 'ReservationRejectedNotification':
      return  BookingRejectedCard(notificationItemModel: noti,);
    case 'ReservationCancelledNotification':
      return  BookingCancelledRefundCard(notificationItemModel: noti,);
    case 'TenantCancelReservationNotification':
      return  TenantCancelledBookingCard(notificationItemModel: noti,);
    case 'MoneyAddedToWaletNotification':
      return  WalletAddedCard(notificationItemModel: noti,);
    case 'MoneywithdrawnFromWaletNotification':
      return  WalletWithdrawnCard(notificationItemModel: noti,);
    default:
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(noti.data.message),
      );
  }
}
