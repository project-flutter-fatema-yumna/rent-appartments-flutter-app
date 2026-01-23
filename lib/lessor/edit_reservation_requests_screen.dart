import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flats_app/global_data.dart';
import 'package:flats_app/widgets/snack_bar.dart';
import 'package:flats_app/helper/Host.dart';

import 'package:flats_app/models/reservation_edit_model.dart';
import 'package:flats_app/Services/Lessor_Services/get_reservation_edits_service.dart';
import 'package:flats_app/Services/Lessor_Services/reservation_edit_action_service.dart';

class EditReservationRequestScreen extends StatefulWidget {
  static String id = 'EditReservationRequestScreen';
  const EditReservationRequestScreen({super.key});

  @override
  State<EditReservationRequestScreen> createState() => _EditReservationRequestScreenState();
}

class _EditReservationRequestScreenState extends State<EditReservationRequestScreen> {
  final String token = userToken;

  final _getService = GetReservationEditsService();
  final _actionService = ReservationEditActionService();

  late Future<List<ReservationEditModel>> _future;
  List<ReservationEditModel> _items = [];

  // to disable buttons per-card while calling API
  final Set<int> _processing = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ReservationEditModel>> _load() async {
    final data = await _getService.getPending(token: token);
    _items = data;
    return data;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _fmt(DateTime d) => "${d.year}-${_two(d.month)}-${_two(d.day)}";

  Future<void> _acceptEdit(ReservationEditModel edit) async {
    if (_processing.contains(edit.id)) return;
    setState(() => _processing.add(edit.id));

    try {
      await _actionService.accept(editId: edit.id, token: token);

      if (!mounted) return;
      setState(() {
        _items.removeWhere((e) => e.id == edit.id);
        _processing.remove(edit.id);
      });

      mySnackBar(context, 'edit_accepted'.tr(), color: Colors.green);
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing.remove(edit.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _rejectEdit(ReservationEditModel edit) async {
    if (_processing.contains(edit.id)) return;
    setState(() => _processing.add(edit.id));

    try {
      await _actionService.reject(editId: edit.id, token: token);

      if (!mounted) return;
      setState(() {
        _items.removeWhere((e) => e.id == edit.id);
        _processing.remove(edit.id);
      });

      mySnackBar(context, 'edit_rejected'.tr());
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing.remove(edit.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'edit_requests_title'.tr(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 6),
            Text(
              'edit_requests_subtitle'.tr(),
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: FutureBuilder<List<ReservationEditModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitThreeBounce(color: Colors.blue, size: 20),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                   if (_items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(child: Text('no_edit_requests'.tr())),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final edit = _items[index];
                        final reservation = edit.reservation;

                        final hasImage = reservation.apartment.images.isNotEmpty;
                        final url = hasImage
                            ? 'http://${Host.host}:8000/storage/${reservation.apartment.images[0].image.trim()}'
                            : null;

                        final isBusy = _processing.contains(edit.id);

                        return Material(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 0.6,
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
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: hasImage
                                            ? Image.network(url!, width: 44, height: 44, fit: BoxFit.cover)
                                            : Icon(Icons.home, color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${reservation.apartment.governorate}-${reservation.apartment.city}",
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.person, size: 16, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  reservation.user?.username ?? 'Guest',
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Edit badge + always pending in your endpoint
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'edit_request'.tr(),
                                            style: TextStyle(
                                              color: Colors.blue.shade800,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        _statusChip(context, edit.status),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Show OLD vs NEW (this is the main customization for edit requests)
                                _DiffBlock(
                                  title: 'dates'.tr(),
                                  oldValue: "${_fmt(reservation.startDate)} → ${_fmt(reservation.endDate)}",
                                  newValue: "${_fmt(edit.startDate)} → ${_fmt(edit.endDate)}",
                                ),
                                const SizedBox(height: 10),
                                _DiffBlock(
                                  title: 'total'.tr(),
                                  oldValue: "${reservation.fullAmount} - ${(reservation.apartment.rent_type ?? '').tr()}",
                                  newValue: "${edit.fullAmount} - ${(reservation.apartment.rent_type ?? '').tr()}",
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: isBusy ? null : () => _rejectEdit(edit),
                                        icon: isBusy
                                            ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                            : const Icon(Icons.close),
                                        label: Text('reject'.tr()),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: isBusy ? null : () => _acceptEdit(edit),
                                        icon: isBusy
                                            ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                            : const Icon(Icons.check),
                                        label: Text('accept'.tr()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    Color background;
    Color colorText;
    String text;

    switch (status) {
      case "accepted":
        background = Colors.green.shade50;
        colorText = Colors.green.shade800;
        text = 'accepted'.tr();
        break;
      case "rejected":
        background = Colors.red.shade50;
        colorText = Colors.red.shade800;
        text = 'rejected'.tr();
        break;
      default:
        background = Colors.orange.shade50;
        colorText = Colors.orange.shade800;
        text = 'pending'.tr();
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

class _DiffBlock extends StatelessWidget {
  final String title;
  final String oldValue;
  final String newValue;

  const _DiffBlock({
    required this.title,
    required this.oldValue,
    required this.newValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MiniLine(
                  label: 'old'.tr(),
                  value: oldValue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniLine(
                  label: 'new'.tr(),
                  value: newValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  final String label;
  final String value;

  const _MiniLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
