import 'package:flats_app/MyColors.dart';
import 'package:flats_app/Screens/chatScreen.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../Services/reserveApartment.dart';
import '../authentication_screens/login_screen.dart';
import 'finally.dart';


class ShowScreen extends StatefulWidget {
  static String id = 'ShowScreen';

  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  bool isFavorite = false;
  int numberImage = 0;
  bool _reserved = false;
  bool _loadingReserve = false;

  void _showFinallySheet(BuildContext pageContext) {
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => const FinallyPage(),
    );
  }

  void _showWalletSheet(
      BuildContext ctx, {
        required String message,
        required double requiredAmount,
        required double availableAmount,
      }) {
    final bool isEmptyWallet = availableAmount == 0;
    final double need = (requiredAmount - availableAmount).clamp(0, double.infinity);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 55,
                color: isEmptyWallet ? Colors.red : Colors.orange,
              ),
              const SizedBox(height: 10),
              Text(
                isEmptyWallet ? 'Wallet is empty' : 'Not enough balance',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Required: $requiredAmount'),
                    Text('Available: $availableAmount'),
                    Text('Need: $need'),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    //api
                  },
                  child: const Text('Send request to admin'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }



  late Model_Apartment model_apartment;
  DateTimeRange? _selectedRange;

  Future<void> _openDatePicker() async {
    final now = DateTime.now();

    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1, 12, 31),
      locale: const Locale('en'),
      helpText: 'chose rend date',
    );

    if (result != null) {
      setState(() {
        _selectedRange = result;
      });
      final pageContext = context;
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('information'),
            content: Text(
              'Booking was selected from'
              '${result.start.day}/${result.start.month}/${result.start.year} '
              'to ${result.end.day}/${result.end.month}/${result.end.year}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _selectedRange=null;
                  Navigator.pop(dialogContext);
                  _openDatePicker();
                },
                child: Text('Edit'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  if (_selectedRange == null) return;
                  if (_loadingReserve) return;

                  setState(() => _loadingReserve = true);
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('token');
                    print("TOKEN => $token");
                    if (token == null || token.isEmpty) {
                      if (!mounted) return;
                      setState(() => _loadingReserve = false);
                      ScaffoldMessenger.of(pageContext).showSnackBar(
                        const SnackBar(content: Text('Token not found, please login again')),
                      );
                      return;
                    }
                    //200//201////////////////////////////////
                    final res = await reserveService().reserveApatment(
                      token: token,
                      apartmentId: model_apartment.id,
                      start: _selectedRange!.start,
                      end: _selectedRange!.end,
                    );
                    if (!mounted) return;
                    setState(() {
                      _reserved = true;
                      _loadingReserve = false;
                    });
                    _showFinallySheet(pageContext);
                    ////////////////////////////////////////////
                    /*final msg = (res is Map && res['message'] != null)
                        ? res['message'].toString()
                        : 'Reservation created (pending)';*/
                  /*  ScaffoldMessenger.of(pageContext).showSnackBar(
                      SnackBar(content: Text(msg)),
                    );*/
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _loadingReserve = false);
////parsing
                    final raw = e.toString().replaceFirst('Exception: ', '');
                    final parts = raw.split('|');

                    final code = int.tryParse(parts.first);
                    final bodyText = parts.length > 1 ? parts.sublist(1).join('|') : raw;

                    Map<String, dynamic>? body;
                    try {
                      body = Map<String, dynamic>.from(jsonDecode(bodyText));
                    } catch (_) {
                      body = null;
                    }
                    final msg = body?['message']?.toString() ?? bodyText;

                  //Unauthorized
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
                    //Date change
                    if (code == 409) {
                      ScaffoldMessenger.of(pageContext).showSnackBar(SnackBar(content: Text(msg)));
                      _selectedRange = null;
                      _openDatePicker();
                      return;
                    }
                    ///wallet
                   if (body != null && body.containsKey('required') && body.containsKey('available')) {
                    final requiredAmount = double.tryParse(body['required'].toString()) ?? 0;
                    final availableAmount = double.tryParse(body['available'].toString()) ?? 0;
                  _showWalletSheet(
                    pageContext,
                    message: msg,
                    requiredAmount: requiredAmount,
                    availableAmount: availableAmount,
                  );
                  return;
                   }
                    ScaffoldMessenger.of(pageContext).showSnackBar(SnackBar(content: Text(msg)));
                  }

                },
                child: const Text('OK'),
              ),


              /*   TextButton(
                onPressed: ()async {
                  Navigator.pop(context);
                  await reserveService().reserveApatment(
                      token: token,
                      apartmentId:model_apartment.id ,
                      start: _selectedRange!.start,
                      end: _selectedRange!.end
                  );
                },
                child: Text('OK'),
              ),*/
            ],
          );
        },
      );
    }
  }

///////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
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
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stack) {
                          print("IMG ERROR: $error\nURL: $url");
                          return const Center(
                            child: Icon(Icons.broken_image, size: 40),
                          );
                        },
                      );
                      /*CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (c, _) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (c, _, __) => const Icon(Icons.broken_image),
                      );*/
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
                                    'User Name',
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
                                        Navigator.pushNamed(
                                          context,
                                          ChatScreen.id,
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
                                '${model_apartment.rent_type} Rend',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: (_reserved || _loadingReserve) ? null : _openDatePicker,

                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: (_reserved || _loadingReserve) ? Colors.grey : Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                              _reserved ? 'Pending' : 'Reserve',
                                style: const TextStyle(color: Colors.white, fontSize: 20),
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
