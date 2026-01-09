import 'package:flats_app/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/getAllWalletRequests.dart';
import '../../models/model_walletRequest.dart';
import 'WalletRequestSheetLessor.dart';

class LessorWalletScreen extends StatefulWidget {
  static String id = 'LessorWalletScreen';
  const LessorWalletScreen({super.key});

  @override
  State<LessorWalletScreen> createState() => _LessorWalletScreenState();
}

class _LessorWalletScreenState extends State<LessorWalletScreen> {
  late Future<WalletData> _futureWallet;

  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _futureWallet = _loadWallet();
  }

  Future<WalletData> _loadWallet() async {
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('token') ?? '';

    const token =
        '1|EZIEoy5aLnCdi5XP2jxeaGtnNT60yqCeYyfoaP0W9a2b30e6';

    return GetWalletService().getWalletData(token: token);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Card",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: myColors.colorWhite,
      body: FutureBuilder<WalletData>(
        future: _futureWallet,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitThreeBounce(
                color: Colors.blue,
                size: 20,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final walletData = snapshot.data!;
          final double available = walletData.wallet;
          final role = walletData.role;
          final requests = walletData.requests;

          final filteredRequests = selectedStatus == 'all'
              ? requests
              : requests
              .where((r) => r.status == selectedStatus)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Balance",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${available.toStringAsFixed(2)} ",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$role wallet",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.south_east, size: 19),
                        label: const Text(
                          "Withdraw",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (_) => Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: LessorWalletRequestSheet(
                                type: WalletRequestType.withdraw,
                                availableAmount: available,
                                message:
                                "Enter the amount you want to withdraw.",
                              ),
                            ),
                          ).then((_) {
                            setState(() {
                              _futureWallet = _loadWallet();
                            });
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.north_east,
                          size: 19,
                          color: Colors.blue,
                        ),
                        label: const Text(
                          "Add Funds",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (_) => Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: LessorWalletRequestSheet(
                                type: WalletRequestType.add,
                                availableAmount: available,
                                message: "Enter the amount you want to add.",
                              ),
                            ),
                          ).then((_) {
                            setState(() {
                              _futureWallet = _loadWallet();
                            });
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Requests",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedStatus,
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All'),
                      ),
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text('Approved'),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Rejected'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (filteredRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      'No requests for this filter',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...filteredRequests.map(
                      (r) => _RequestTile(
                    type: r.type,
                    amount: r.amount.toStringAsFixed(0),
                    status: r.status,
                    date: _formatDate(r.createdAt),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final String type; // "withdraw" / "add"
  final String amount;
  final String status; // "pending" / "approved" / "rejected"
  final String date;

  const _RequestTile({
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
  });

  Color get _statusColor {
    switch (status) {
      case "approved":
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWithdraw = type == "withdraw";
    final IconData icon = isWithdraw ? Icons.south_east : Icons.north_east;
    final String title =
    isWithdraw ? "Withdraw request" : "Add funds request";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          date,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
