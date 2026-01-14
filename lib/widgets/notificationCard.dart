import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum NotifType {
  cancelByTenantToLessor,
  walletDeposit,
  walletWithdraw,
  bookingAccepted,
  bookingRejected,
  bookingCancelledForTenant,
}

class AppNotif {
  final NotifType type;
  final String message;

  // Optional fields (static for now)
  final String? tenantName;
  final String? ownerName;
  final String? bookingTitle; // مثل: "شقة A - 02/01 إلى 05/01"
  final double? amount;

  final DateTime createdAt;

  AppNotif({
    required this.type,
    required this.message,
    this.tenantName,
    this.ownerName,
    this.bookingTitle,
    this.amount,
    required this.createdAt,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  static String id='NotificationsScreen';
  // بيانات ستاتيك مؤقتاً
  List<AppNotif> get dummy => [
    AppNotif(
      type: NotifType.cancelByTenantToLessor,
      message: "المستأجر قام بإلغاء الحجز قبل موعده.",
      tenantName: "Ahmad",
      bookingTitle: "شقة رقم 12 - 10/01 إلى 15/01",
      amount: 120.0, // المبلغ الراجع للمستأجر حسب المدة
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    AppNotif(
      type: NotifType.walletDeposit,
      message: "تم إضافة مبلغ إلى رصيدك.",
      amount: 250.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotif(
      type: NotifType.walletWithdraw,
      message: "تم سحب مبلغ من رصيدك.",
      amount: 80.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppNotif(
      type: NotifType.bookingAccepted,
      message: "تم قبول حجزك بنجاح.",
      ownerName: "Fatema (المالك)",
      bookingTitle: "شقة Sea View - 20/01 إلى 25/01",
      amount: 500.0, // سعر الشقة (المصاري المسحوبة)
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    ),
    AppNotif(
      type: NotifType.bookingRejected,
      message: "للأسف، تم رفض الحجز من قبل المالك.",
      ownerName: "Yamna (المالك)",
      bookingTitle: "شقة City Center - 03/02 إلى 06/02",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AppNotif(
      type: NotifType.bookingCancelledForTenant,
      message: "تم إلغاء الحجز وتمت إعادة المبلغ إلى رصيدك.",
      bookingTitle: "شقة رقم 7 - 14/02 إلى 16/02",
      amount: 200.0, // المبلغ الراجع للمستأجر
      createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: dummy.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => NotificationCard(notif: dummy[index]),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotif notif;
  const NotificationCard({super.key, required this.notif});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(notif.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // الشريط الملوّن
          Container(
            width: 6,
            height: 140,
            decoration: BoxDecoration(
              color: cfg.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: icon + title + time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cfg.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(cfg.icon, color: cfg.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cfg.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _timeAgo(notif.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // message
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade800,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // details chips/lines حسب النوع
                  ..._details(notif),

                  const SizedBox(height: 12),

                  // actions
                  Row(
                    children: [
                      if (cfg.primaryAction != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(cfg.primaryAction!)),
                              );
                            },
                            child: Text(cfg.primaryAction!),
                          ),
                        ),
                      if (cfg.secondaryAction != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(cfg.secondaryAction!)),
                              );
                            },
                            child: Text(cfg.secondaryAction!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _details(AppNotif n) {
    List<Widget> items = [];

    Widget line(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
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
      ),
    );

    switch (n.type) {
      case NotifType.cancelByTenantToLessor:
        if (n.tenantName != null) items.add(line(Icons.person, "المستأجر: ${n.tenantName}"));
        if (n.bookingTitle != null) items.add(line(Icons.home_work, "الحجز: ${n.bookingTitle}"));
        if (n.amount != null) items.add(line(Icons.currency_exchange, "المبلغ الراجع للمستأجر: €${n.amount!.toStringAsFixed(2)}"));
        break;

      case NotifType.walletDeposit:
        if (n.amount != null) items.add(line(Icons.account_balance_wallet, "المبلغ المضاف: €${n.amount!.toStringAsFixed(2)}"));
        break;

      case NotifType.walletWithdraw:
        if (n.amount != null) items.add(line(Icons.payments, "المبلغ المسحوب: €${n.amount!.toStringAsFixed(2)}"));
        break;

      case NotifType.bookingAccepted:
        if (n.ownerName != null) items.add(line(Icons.verified_user, "المالك: ${n.ownerName}"));
        if (n.bookingTitle != null) items.add(line(Icons.event_available, "الحجز: ${n.bookingTitle}"));
        if (n.amount != null) items.add(line(Icons.credit_card, "المبلغ المسحوب: €${n.amount!.toStringAsFixed(2)}"));
        break;

      case NotifType.bookingRejected:
        if (n.ownerName != null) items.add(line(Icons.person_off, "المالك: ${n.ownerName}"));
        if (n.bookingTitle != null) items.add(line(Icons.event_busy, "الحجز: ${n.bookingTitle}"));
        break;

      case NotifType.bookingCancelledForTenant:
        if (n.bookingTitle != null) items.add(line(Icons.home, "الحجز: ${n.bookingTitle}"));
        if (n.amount != null) items.add(line(Icons.currency_exchange, "المبلغ الراجع لك: €${n.amount!.toStringAsFixed(2)}"));
        break;
    }

    return items;
  }

  _NotifCfg _config(NotifType t) {
    switch (t) {
      case NotifType.cancelByTenantToLessor:
        return _NotifCfg(
          title: "إلغاء حجز من المستأجر",
          icon: Icons.cancel_schedule_send,
          color: Colors.deepOrange,
          primaryAction: "عرض الحجز",
        );

      case NotifType.walletDeposit:
        return _NotifCfg(
          title: "تمت إضافة رصيد",
          icon: Icons.add_card,
          color: Colors.green,
          primaryAction: "فتح المحفظة",
        );

      case NotifType.walletWithdraw:
        return _NotifCfg(
          title: "تم سحب رصيد",
          icon: Icons.payments,
          color: Colors.blue,
          primaryAction: "فتح المحفظة",
        );

      case NotifType.bookingAccepted:
        return _NotifCfg(
          title: "قبول الحجز",
          icon: Icons.check_circle,
          color: Colors.green,
          primaryAction: "عرض الحجز",
          secondaryAction: "مراسلة المالك",
        );

      case NotifType.bookingRejected:
        return _NotifCfg(
          title: "رفض الحجز",
          icon: Icons.cancel,
          color: Colors.red,
          primaryAction: "عرض الحجز",
        );

      case NotifType.bookingCancelledForTenant:
        return _NotifCfg(
          title: "إلغاء الحجز",
          icon: Icons.event_busy,
          color: Colors.orange,
          primaryAction: "عرض الحجز",
          secondaryAction: "المحفظة",
        );
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return "منذ ${diff.inMinutes} دقيقة";
    if (diff.inHours < 24) return "منذ ${diff.inHours} ساعة";
    return "منذ ${diff.inDays} يوم";
  }
}

class _NotifCfg {
  final String title;
  final IconData icon;
  final Color color;
  final String? primaryAction;
  final String? secondaryAction;

  _NotifCfg({
    required this.title,
    required this.icon,
    required this.color,
    this.primaryAction,
    this.secondaryAction,
  });
}