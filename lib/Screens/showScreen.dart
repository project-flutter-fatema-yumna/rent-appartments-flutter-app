import 'package:flats_app/MyColors.dart';
import 'package:flats_app/Screens/chatScreen.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowScreen extends StatefulWidget {
  static String id = 'ShowScreen';
  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  bool isFavorite = false;
  int numberImage = 0;

 /* List<String> ListImages = [
>>>>>>> fatema_branch
    'assets/img.png',
    'assets/img_1.png',
    'assets/img_2.png',
    'assets/img_3.png',
<<<<<<< HEAD
  ];
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

      if (result.start.year == result.end.year) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('information'),
              content: Text(
                'Booking was selected from'
                '${result.start.day}/${result.start.month} '
                'to ${result.end.day}/${result.end.month}',
              ),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(context);
                  _openDatePicker();
                }, child: Text('Edit')),
                TextButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text('OK')),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('information'),
              content: Text(
                'Booking was selected from '
                    '${result.start.day}/${result.start.month}/${result.start.year} '
                    'to  ${result.end.day}/${result.end.month}${result.end.year} ',
              ),
              actions: [
                TextButton(onPressed: () {}, child: Text('Edit')),
                TextButton(onPressed: () {}, child: Text('OK')),
              ],
            );
          },
        );
      }
    }
  }
=======
  ];*/

  DateTimeRange? _selectedRange;


  @override
  Widget build(BuildContext context) {
    Model_Apartment model_apartment =
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
                      return Image.network('http://10.0.2.2:8000/storage/${model_apartment.images[index].image}', fit: BoxFit.cover);
                    },
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(model_apartment.images.length, (index) {
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
                                  Text('${model_apartment.parking_number} parking'),
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
                                  Text('${model_apartment.number_of_baths} bath'),
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
                                    '   Rooms Number    :      ${model_apartment.rooms_number} Rooms',
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
                                    '   Floor Number       :      ${model_apartment.floor_number}',
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
                                    '   Balcony Number   :     ${model_apartment.balcony_number} ',
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
                                    '   Furnished           :   ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Icon(
                                    model_apartment.furnished? Icons.check:Icons.close,
                                    color: model_apartment.furnished?Colors.green:Colors.red,
                                  )

                                ],

                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.date_range, color: Colors.blue),
                                  Text(
                                    '   Created at   :   ${model_apartment.created_at.split('T')[0]}',
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
                                  Icon(Icons.date_range_outlined, color: Colors.blue),
                                  Text(
                                    '   Updated at    :   ${model_apartment.updated_at.split('T')[0]}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,)
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
                                          path: '0988892049',
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
                                r'$1,345',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Monthly Rend',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Rent now',
                                  style: TextStyle(
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
