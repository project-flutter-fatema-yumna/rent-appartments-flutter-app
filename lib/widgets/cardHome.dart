import 'package:flats_app/Screens/showScreen.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/material.dart';

class CardHome extends StatefulWidget {
  Model_Apartment? model_apartment;

  CardHome({ this.model_apartment});

  @override
  State<CardHome> createState() => _CardHomeState();
}

class _CardHomeState extends State<CardHome> {
  /* int? height , width;
  _CardHomeState(this.height, this.width);*/
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, ShowScreen.id,arguments:widget.model_apartment );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Container(
          width: 270,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: AssetImage('assets/image.jfif'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Text(
                  r'$ 19,000,000',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                  Text(
                    ' ${widget.model_apartment!.governorate} , ${widget.model_apartment!.city} ',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
