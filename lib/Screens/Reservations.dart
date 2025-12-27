import 'package:flats_app/Screens/edit_reservation_dialog.dart';
import 'package:flats_app/Services/cancel_reservation.dart';
import 'package:flats_app/Services/get_my_reservations.dart';
import 'package:flats_app/models/model_order.dart';
import 'package:flats_app/models/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationsScreen extends StatefulWidget {
  static String id = 'ReservationsScreen';

  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'My Reservations',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.blue,
                indicatorColor: Colors.blue[600],
                tabs: [
                  Tab(child: Text('Pending', style: TextStyle(fontSize: 12))),
                  Tab(
                    child: Text('Accepted', style: TextStyle(fontSize: 11.65)),
                  ),
                  Tab(
                    child: Text('Rejected', style: TextStyle(fontSize: 11.9)),
                  ),
                  Tab(child: Text('Previous', style: TextStyle(fontSize: 12))),
                  Tab(
                    child: Text('Canceled', style: TextStyle(fontSize: 11.9)),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            ReservationsTab(status: 'pending'),
            ReservationsTab(status: 'accepted'),
            ReservationsTab(status: 'rejected'),
            ReservationsTab(status: 'finished'),
            ReservationsTab(status: 'canceled'),
          ],
        ),
      ),
    );
  }
}

class ReservationsTab extends StatefulWidget {
  final String status;
  const ReservationsTab({super.key, required this.status});

  @override
  State<ReservationsTab> createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<ReservationsTab> {
  bool _isLoading = true;
  List<Modal_Order> reservations = [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final token = await getToken();
      if (token == null) {
        setState(() {
          _errorMsg = 'No token found';
        });
        return;
      }

      final result = await getMyReservations(
        token: token,
        status: widget.status,
      );

      setState(() {
        reservations = result;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Something went wrong';
      });
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _cancelReservation(Modal_Order order) async {
    try {
      final token = await getToken();
      if (token == null) return;

      await cancelReservation(reservationId: order.id, token: token);

      setState(() {
        order.status = 'canceled';
      });
      mySnackBar(context, 'Reservation canceled');
    } catch (e) {
      mySnackBar(context, 'Failed to cancel reservation');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMsg != null) {
      return Center(child: Text(_errorMsg!));
    }

    if (reservations.isEmpty) {
      return const Center(child: Text('No reservations'));
    }

    return Column(
      children:[ Expanded(
        child: ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final r = reservations[index];
            final apartment = r.apartment;
        
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apartment?.city ?? 'Unknown location',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${apartment?.number_of_bedrooms ?? 0} bedrooms • ${apartment?.home_space ?? 0} m²',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.date_range, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${_formatDate(r.startDate)} → ${_formatDate(r.endDate)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ' ${r.fullAmount.toStringAsFixed(0)} \$',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusChip(r.status),
                      ],
                    ),
                    if (r.status == 'pending' || r.status == 'accepted') ...[
                      Divider(),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                showDialog(
                                  context: context,
                                  builder: (_) => EditReservationDialog(
                                    reservationId: r.id,
                                    oldStartDate: r.startDate,
                                    oldEndDate: r.endDate,
                                  ),
                                );
                              });
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue,),
                            label: const Text('Edit', style: TextStyle(color: Colors.blue,),),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _cancelReservation(r);
                              });
                            },
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      SizedBox(height: 70,)
      ]
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
