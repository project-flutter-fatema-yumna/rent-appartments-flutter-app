import 'package:flats_app/Screens/edit_reservation_dialog.dart';
import 'package:flats_app/Services/cancel_reservation.dart';
import 'package:flats_app/Services/get_my_reservations.dart';
import 'package:flats_app/Services/rate_apartment.dart';
import 'package:flats_app/models/model_order.dart';
import 'package:flats_app/widgets/snack_bar.dart';
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
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            'My Reservations',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              color: Theme.of(context).cardColor,
              child: TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                tabs: [
                  Tab(
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Accepted',
                      style: TextStyle(
                        fontSize: 11.65,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Rejected',
                      style: TextStyle(
                        fontSize: 11.9,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Canceled',
                      style: TextStyle(
                        fontSize: 11.9,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
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
          _isLoading = false;
        });
        return;
      }

      final result = await getMyReservations(
        token: token,
        status: widget.status,
      );

      setState(() {
        reservations = result;
        _errorMsg = null;
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
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }

    if (_errorMsg != null) {
      return Center(child: Text(_errorMsg!));
    }

    if (reservations.isEmpty) {
      return Center(
        child: Text(
          'No reservations',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final r = reservations[index];
                final apartment = r.apartment;
      
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apartment?.city ?? 'Unknown location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${apartment?.number_of_bedrooms ?? 0} bedrooms • ${apartment?.home_space ?? 0} m²',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        Divider(
                          height: 20,
                          color: Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color!,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_formatDate(r.startDate)} → ${_formatDate(r.endDate)}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color!,
                              ),
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
                          Divider(
                            color: Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
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
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                ),
                                label: Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
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
                        if (r.status == 'finished') ...[
                          Divider(
                            color: Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                          if (!r.isRated)
                            Align(
                              alignment: Alignment.center,
                              child: TextButton.icon(
                                icon: const Icon(Icons.star, color: Colors.amber),
                                label: Text(
                                  'Rate apartment',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  _openRatingSheet(r);
                                },
                              ),
                            )
                          else
                            Row(
                              children: [
                                const Text(
                                  'You rated this apartment: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < (r.userRate ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
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
          SizedBox(height: 70),
        ],
      ),
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
      case 'finished':
        color = Colors.green.shade900;
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

  void _openRatingSheet(Modal_Order r) {
    double selectedRate = r.userRate ?? 0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Rate this apartment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRate
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setSheetState(() {
                              selectedRate = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).cardColor,
                      ),
                      onPressed: () async {
                        print(r.apartmentId);

                        if (selectedRate != 0) {
                          await rateApartment(
                            apartmentId: r.apartmentId,
                            stars: selectedRate,
                          );

                          setState(() {
                            r.isRated = true;
                            r.userRate = selectedRate;
                          });

                          Navigator.pop(context);

                          mySnackBar(
                            context,
                            'Thanks for rating ⭐',
                            color: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!,
                            showIcon: false,
                          );
                        }
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
