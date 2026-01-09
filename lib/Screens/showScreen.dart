import 'package:flats_app/MyColors.dart';
import 'package:flats_app/Screens/walletTenantScreens/WalletRequestSheetTenant.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../Services/calculate_reservation_service.dart';
import '../Services/get_blocked_dates_service.dart';
import '../Services/reserveApartment.dart';
import '../authentication_screens/login_screen.dart';
import '../helper/alertDialog.dart';
import '../lessor/chat/chatSecondScreen.dart';
import '../models/blocked_date.dart';
import '../models/reservation_calculation.dart';
import 'finally.dart';

class ShowScreen extends StatefulWidget {
  static String id = 'ShowScreen';

  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  bool isFavorite = false;
  int numberImage = 0;
  bool _loadingReserve = false;
  String? token;
  int? myId;
  int? _reservationId;
  String? unit;


  final get_blocked_dates_service _blockedService = get_blocked_dates_service();
  List<BlockedDate> _blockedDates = [];
  bool _loadingBlocked = false;

  final CalculateReservationService _calcService =
      CalculateReservationService();
  ReservationCalculation? _calcResult;
  bool _loadingCalc = false;

  bool _isDayBlocked(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);

    for (final b in _blockedDates) {
      final start = DateTime(b.start.year, b.start.month, b.start.day);
      final end = DateTime(b.end.year, b.end.month, b.end.day);

      if (!d.isBefore(start) && !d.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  String _buildPeriodLabel() {
    if (_calcResult == null) return '';

    String unit;
    switch (_calcResult!.rentType.toLowerCase()) {
      case 'daily':
        unit = 'day';
        break;
      case 'monthly':
        unit = 'month';
        break;
      case 'yearly':
        unit = 'year';
        break;
      default:
        unit = 'day';
    }

    final int p = _calcResult!.period;
    final String unitLabel = p > 1 ? '${unit}s' : unit;

    return '$p $unitLabel';
  }


  String _reservationStatus = 'Reserve'; // none/pending/accepted/rejected
  void _showFinallySheet(BuildContext pageContext) {
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => const FinallyPage(),
    );
  }

  void _openWalletSheet({
    required BuildContext context,
    required String message,
    required double requiredAmount,
    required double availableAmount,
  }) {
    final double need = (requiredAmount - availableAmount).clamp(
      0,
      double.infinity,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TenantWalletRequestSheet(
          type: WalletRequestType.add,
          availableAmount: availableAmount,
          message:
              "You don't have enough balance to complete this reservation.\n\n"
              "Required: ${requiredAmount.toStringAsFixed(0)}\n"
              "Available: ${availableAmount.toStringAsFixed(0)}\n"
              "Please add at least ${need.toStringAsFixed(0)} to your wallet.",
        ),
      ),
    );
  }

  late Model_Apartment model_apartment;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      myId = prefs.getInt('userId');
    });

    print("ShowScreen token => $token");
    print("ShowScreen myId  => $myId");
  }

  DateTimeRange? _selectedRange;

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final pageContext = context;

    if (token == null || token!.isEmpty) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        const SnackBar(content: Text('Token not found, please login again')),
      );
      Navigator.of(
        pageContext,
      ).pushNamedAndRemoveUntil(LoginScreen.id, (route) => false);
      return;
    }

    if (_blockedDates.isEmpty && !_loadingBlocked) {
      setState(() => _loadingBlocked = true);
      try {
        _blockedDates = await _blockedService.getBlockedDates(
          apartmentId: model_apartment.id,
          token: token!,
        );
      } catch (e) {
        print('Error loading blocked dates: $e');
      } finally {
        if (mounted) {
          setState(() => _loadingBlocked = false);
        }
      }
    }

    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1, 12, 31),
      locale: const Locale('en'),
      helpText: 'chose rent date',
      selectableDayPredicate: (day, start, end) {
        final today = DateTime(now.year, now.month, now.day);
        if (day.isBefore(today)) return false;

        if (_isDayBlocked(day)) return false;

        return true;
      },
    );

    if (result != null) {
      setState(() {
        _selectedRange = result;
      });
      if (token != null && token!.isNotEmpty) {
        setState(() => _loadingCalc = true);
        try {
          _calcResult = await _calcService.calculate(
            apartmentId: model_apartment.id,
            start: result.start,
            end: result.end,
            token: token!,
          );
        } catch (e) {
          print('Error on calculate reservation: $e');
          _calcResult = null;
        } finally {
          if (mounted) {
            setState(() => _loadingCalc = false);
          }
        }
      }

      final pageContext = context;
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Reservation summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Booking from '
                              '${result.start.day}/${result.start.month}/${result.start.year} '
                              'to ${result.end.day}/${result.end.month}/${result.end.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),

                const SizedBox(height: 10),
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                if (_loadingCalc)
                  const Center(child: CircularProgressIndicator())
                else if (_calcResult != null) ...[
                  _infoRow('Rent type', _calcResult!.rentType),
                  const SizedBox(height: 6),
                  _infoRow('Period', _buildPeriodLabel()),
                  const SizedBox(height: 6),
                  _infoRow('Total', '${_calcResult!.total} \$'),
                ],

              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            actions: [
              TextButton(
                onPressed: () {
                  _selectedRange = null;
                  Navigator.pop(dialogContext);
                  _openDatePicker();
                },
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  if (_selectedRange == null) return;
                  if (_loadingReserve) return;

                  setState(() => _loadingReserve = true);
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final savedToken = prefs.getString('token');
                    if (savedToken == null || savedToken.isEmpty) {
                      if (!mounted) return;
                      setState(() => _loadingReserve = false);
                      ScaffoldMessenger.of(pageContext).showSnackBar(
                        const SnackBar(
                          content: Text('Token not found, please login again'),
                        ),
                      );
                      Navigator.of(pageContext).pushNamedAndRemoveUntil(
                        LoginScreen.id,
                        (route) => false,
                      );
                      return;
                    }

                    final res = await reserveService().reserveApatment(
                      token: savedToken,
                      apartmentId: model_apartment.id,
                      start: _selectedRange!.start,
                      end: _selectedRange!.end,
                    );
                    final data = (res is Map) ? res['data'] : null;
                    if (!mounted) return;
                    setState(() {
                      _loadingReserve = false;
                      if (data is Map) {
                        _reservationId = int.tryParse(data['id'].toString());
                        _reservationStatus =
                            data['status']?.toString() ?? 'pending';
                      } else {
                        _reservationStatus = 'pending';
                      }
                    });
                    _showFinallySheet(pageContext);
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _loadingReserve = false);

                    final raw = e.toString().replaceFirst('Exception: ', '');
                    final parts = raw.split('|');

                    final code = int.tryParse(parts.first);
                    final bodyText = parts.length > 1
                        ? parts.sublist(1).join('|')
                        : raw;

                    Map<String, dynamic>? body;
                    try {
                      body = Map<String, dynamic>.from(jsonDecode(bodyText));
                    } catch (_) {
                      body = null;
                    }
                    final msg = body?['message']?.toString() ?? bodyText;

                    // 401 Unauthorized
                    if (code == 401) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      if (!mounted) return;
                      ScaffoldMessenger.of(pageContext).showSnackBar(
                        const SnackBar(
                          content: Text('Session expired, please login again'),
                        ),
                      );
                      Navigator.of(pageContext).pushNamedAndRemoveUntil(
                        LoginScreen.id,
                        (route) => false,
                      );
                      return;
                    }

                    // 409 date conflict
                    /*if (code == 409) {
                      _selectedRange = null;
                      await showAppDialog(
                        pageContext,
                        title: 'information',
                        message:
                        'the apartment is already reserved in this date range',
                        buttonText: 'OK',
                      );
                      _openDatePicker();
                      return;
                    }*/

                    // حالة الـ wallet
                    if (body != null &&
                        body.containsKey('required') &&
                        body.containsKey('available')) {
                      final requiredAmount =
                          double.tryParse(body['required'].toString()) ?? 0;
                      final availableAmount =
                          double.tryParse(body['available'].toString()) ?? 0;

                      _openWalletSheet(
                        context: context,
                        message: msg,
                        requiredAmount: requiredAmount,
                        availableAmount: availableAmount,
                      );
                      return;
                    }

                    ScaffoldMessenger.of(
                      pageContext,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    String label;
    if (_loadingReserve)
      label = 'Loading...';
    else if (_reservationStatus == 'pending')
      label = 'Pending';
    else if (_reservationStatus == 'accepted')
      label = 'Accepted';
    else if (_reservationStatus == 'rejected')
      label = 'Reserve again';
    else
      label = 'Reserve';

    final bool disabled = _loadingReserve || _reservationStatus == 'pending';
    model_apartment =
        ModalRoute.of(context)!.settings.arguments as Model_Apartment;
    return Scaffold(
      backgroundColor: myColors.colorWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 350,
                  child: PageView.builder(
                    onPageChanged: (index) {
                      setState(() {
                        numberImage = index;
                      });
                    },
                    itemCount: model_apartment.images.length,
                    itemBuilder: (context, index) {
                      final path = model_apartment.images[index].image.trim();
                      final url = 'http://10.0.2.2:8000/storage/$path';
                      return Image.network(url, fit: BoxFit.cover);
                    },
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(model_apartment.images.length, (
                      index,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          width: numberImage == index ? 12 : 8,
                          height: numberImage == index ? 12 : 8,
                          decoration: BoxDecoration(
                            color: numberImage == index
                                ? Colors.blue
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 30,
                  child: IconButton(
                    color: Colors.grey,
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 30,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: myColors.colorWhite,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, color: Colors.blueGrey),
                              Text(
                                ' ${model_apartment.governorate} , ${model_apartment.city} ',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 30),
                              Text(
                                '${model_apartment.home_rate}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 80,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.square_foot, color: Colors.blue),
                                  Text('${model_apartment.home_space} sq ft'),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 80,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.car_crash, color: Colors.blue),

                                  Text(
                                    '${model_apartment.parking_number} parking',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 80,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.bathtub, color: Colors.blue),
                                  Text(
                                    '${model_apartment.number_of_baths} bath',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Description',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.meeting_room, color: Colors.blue),
                                  Text(
                                    '   Rooms Number       :      ${model_apartment.rooms_number} ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.bed_rounded, color: Colors.blue),
                                  Text(
                                    '   bedRoom Number   :     ${model_apartment.number_of_bedrooms} ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.roofing, color: Colors.blue),
                                  Text(
                                    '   Floor Number           :      ${model_apartment.floor_number}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.balcony, color: Colors.blue),
                                  Text(
                                    '   Balcony Number      :     ${model_apartment.balcony_number} ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.bed_rounded, color: Colors.blue),
                                  Text(
                                    '   Furnished                  :   ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Icon(
                                    model_apartment.furnished
                                        ? Icons.check
                                        : Icons.close,
                                    color: model_apartment.furnished
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Agent',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/person2.jfif',
                                    ),
                                    radius: 25,
                                  ),
                                  Text(
                                    model_apartment.owner!.username,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          blurRadius: 1,
                                          spreadRadius: 1,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return chatSecondScreen(
                                                phone: model_apartment
                                                    .owner!
                                                    .phone,
                                                title: model_apartment
                                                    .owner!
                                                    .username,
                                                myId: myId!,
                                                otherUserId:
                                                    model_apartment.owner!.id,
                                                token: token!,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.chat,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade100,
                                          blurRadius: 1,
                                          spreadRadius: 1,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        final Uri phoneUri = Uri(
                                          scheme: 'tel',
                                          path: model_apartment.phone,
                                        );

                                        if (await canLaunchUrl(phoneUri)) {
                                          await launchUrl(phoneUri);
                                        } else {
                                          print('Could not launch phone call');
                                        }
                                      },
                                      icon: Icon(
                                        Icons.phone,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                r'$ '
                                '${model_apartment.rent.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${model_apartment.rent_type} Rent',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: disabled ? null : _openDatePicker,

                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: disabled ? Colors.grey : Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _infoRow(String label, String value) {
  return Row(
    children: [
      Expanded(
        flex: 4,
        child: Text(
          '$label :',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        flex: 5,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

}


