import 'package:flats_app/Services/Lessor_Services/accept_reservation_service.dart';
import 'package:flats_app/Services/Lessor_Services/reject_reservation_service.dart';
import 'package:flats_app/models/model_order.dart';
import 'package:flutter/material.dart';
import '../Services/Lessor_Services/GetAllOrderServices.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Modal_Order>> OrdersFutur;
  List<Modal_Order> allOrders=[];
  String selectedFilter="all";

  List<Modal_Order> get filteredOrders {
    if (selectedFilter == "all") return allOrders;
    return allOrders.where((o) => o.status == selectedFilter).toList();
  }


  @override
  void initState() {
    super.initState();
    OrdersFutur = getAllOrders().getAllReservation(token: '9|c3hNZQ6edWTejdujij2NCDd5cxuva6seMemvBknc79b62022');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Booking Requests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              "Review requests and accept or reject",
              style: TextStyle(color: Colors.grey.shade600,fontSize: 18),
            ),

            const SizedBox(height: 20),
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterChip(label: "All", selected: selectedFilter=="all", onTap: () {
                    setState(() {
                      selectedFilter="all";
                    });
                  }),
                  filterChip(label: "Pending", selected: selectedFilter=="pending", onTap: () {
                    setState(() {
                      selectedFilter="pending";
                    });
                  }),
                  filterChip(label: "Accepted", selected: selectedFilter=="accepted", onTap: () {
                    setState(() {
                      selectedFilter="accepted";
                    });
                  }),
                  filterChip(label: "Rejected", selected: selectedFilter=="rejected", onTap: () {
                    setState(() {
                      selectedFilter="rejected";
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // List
            Expanded(
              child: FutureBuilder(
                future: OrdersFutur,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No orders yet"));
                  }
                  if(allOrders.isEmpty){
                   allOrders = snapshot.data!;
                  }
                  final showOrders=filteredOrders;
                  if (showOrders.isEmpty) {
                    return const Center(child: Text("No orders in this filter"));
                  }

                  return ListView.separated(
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      return OrderCard(
                        modal_order: showOrders[index],
                        onAccept: () async {
                          try {
                            await AcceptReservationService().accept(
                              reservationId: showOrders[index].id,
                              token:
                                  '9|c3hNZQ6edWTejdujij2NCDd5cxuva6seMemvBknc79b62022',
                            );
                            if (!mounted) return;
                            setState(() {
                              showOrders[index].status = 'accepted';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Accepted ")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                        onReject: () async {
                          try {
                            await RejectReservationService().reject(
                              reservationId: showOrders[index].id,
                              token:
                                  '9|c3hNZQ6edWTejdujij2NCDd5cxuva6seMemvBknc79b62022',
                            );
                            if (!mounted) return;
                            setState(() {
                              showOrders[index].status = 'rejected';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Rejected ")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                        onOpenDetails: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onOpenDetails;

  final Modal_Order modal_order;

  const OrderCard({
    required this.onAccept,
    required this.onReject,
    required this.onOpenDetails,
    required this.modal_order,
  });

  @override
  Widget build(BuildContext context) {
    // final isPending = status == "pending";

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpenDetails,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.home_rounded,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${modal_order.apartment.governorate}-${modal_order.apartment.city}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                modal_order.user?.username??'Guest',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  statusChip(status: modal_order.status),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: InfoTile(
                      icon: Icons.date_range,
                      title: "From - To",
                      value:
                          "${modal_order.startDate.year}-${modal_order.startDate.month}-${modal_order.startDate.day} → ${modal_order.endDate.year}-${modal_order.endDate.month}-${modal_order.endDate.day}",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoTile(
                      icon: Icons.payments_rounded,
                      title: "Total",
                      value:
                          "${modal_order.fullAmount} - ${modal_order.apartment.rent_type}",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (modal_order.status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close),
                        label: const Text("Reject"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check),
                        label: const Text("Accept"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    modal_order.status == "accepted"
                        ? "Accepted ✔"
                        : "Rejected ✖",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: modal_order.status == "accepted"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xffF6F7FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class statusChip extends StatelessWidget {
  final String status;
  const statusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color background;
    Color colorText;
    String text;

    switch (status) {
      case "accepted":
        background = Colors.green.shade50;
        colorText = Colors.green.shade800;
        text = "Accepted";
        break;
      case "rejected":
        background = Colors.red.shade50;
        colorText = Colors.red.shade800;
        text = "Rejected";
        break;
      default:
        background = Colors.orange.shade50;
        colorText = Colors.orange.shade800;
        text = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colorText,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class filterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function() onTap;

  const filterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? Colors.blue.shade900 : Colors.black87,
        ),
      ),
    );
  }
}
