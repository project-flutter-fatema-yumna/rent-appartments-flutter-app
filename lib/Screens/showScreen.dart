import 'package:flats_app/app_colors.dart';
import 'package:flats_app/Screens/chatScreen.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'BankAccountBottomSheet.dart';

class ShowScreen extends StatefulWidget {
  static String id = 'ShowScreen';
  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  bool isFavorite = false;
  int numberImage = 0;
  late Model_Apartment model_apartment;
  /* List<String> ListImages = [
    'assets/img.png',
    'assets/img_1.png',
    'assets/img_2.png',
    'assets/img_3.png',
  ];*/
  DateTimeRange? _selectedRange;

  Future<void> _openDatePicker() async {
    final now = DateTime.now();

    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1, 12, 31),
      locale: const Locale('en'),
      helpText: 'chose rend date',
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.cardColor,
              surfaceTintColor: Colors.transparent,
              rangeSelectionBackgroundColor: theme.primaryColor.withOpacity(
                0.2,
              ),
              rangeSelectionOverlayColor: WidgetStateProperty.all(
                theme.primaryColor,
              ),
            ),
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
              onPrimary: theme.cardColor,
              surface: theme.cardColor,
              onSurface: theme.textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedRange = result;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'information',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            content: Text(
              'Booking was selected from'
              '${result.start.day}/${result.start.month}/${result.start.year} '
              'to ${result.end.day}/${result.end.month}/${result.end.year}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openDatePicker();
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openBookingSheet(this.context);
                },
                child: Text('OK',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  void _openBookingSheet(BuildContext pageContext) {
    if (_selectedRange == null) return;
    final range = _selectedRange!;
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BankAccountBottomSheet(
        token: "8|AGei4tZYe7LlDuWzJWwzzTiYRYn1Zp7RPbEx2BgKd30a0133",
        apartmentId: model_apartment.id,
        range: range,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    model_apartment =
        ModalRoute.of(context)!.settings.arguments as Model_Apartment;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
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
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 30,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).cardColor,
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
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
                              Icon(
                                Icons.location_on,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                              Text(
                                ' ${model_apartment.governorate} , ${model_apartment.city} ',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 30),
                              Text(
                                '${model_apartment.home_rate.toInt()}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
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
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color!,
                                  blurRadius: 1,
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
                                  Icon(
                                    Icons.square_foot,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    '${model_apartment.home_space} sq ft',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 80,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color!,
                                  blurRadius: 1,
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
                                  Icon(
                                    Icons.car_crash,
                                    color: Theme.of(context).primaryColor,
                                  ),

                                  Text(
                                    '${model_apartment.parking_number} parking',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 80,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color!,
                                  blurRadius: 1,
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
                                  Icon(
                                    Icons.bathtub,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    '${model_apartment.number_of_baths} bath',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                    ),
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
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color!,
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
                                  Icon(
                                    Icons.meeting_room,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    '   Rooms Number    :      ${model_apartment.rooms_number} Rooms',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.bed_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    '   bedRoom Number   :     ${model_apartment.number_of_bedrooms} ',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.roofing,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    '   Floor Number       :      ${model_apartment.floor_number}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.balcony,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    '   Balcony Number   :     ${model_apartment.balcony_number} ',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.bed_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    '   Furnished           :   ',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
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
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color!,
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
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    radius: 25,
                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(context).primaryColor,
                                      size: 30,
                                    ),
                                  ),
                                  Text(
                                    'User Name',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade100,
                                          blurRadius: 2,
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
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade100,
                                          blurRadius: 2,
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
                                        color: Colors.green[300],
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
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Monthly Rend',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              _openDatePicker();
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Reserve',
                                  style: TextStyle(
                                    color: Theme.of(context).cardColor,
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
