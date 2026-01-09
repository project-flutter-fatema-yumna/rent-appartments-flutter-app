import 'package:flats_app/Screens/showScreen.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/material.dart';

class CardHome extends StatefulWidget {
  Model_Apartment? model_apartment;

  CardHome({this.model_apartment});

  @override
  State<CardHome> createState() => _CardHomeState();
}

class _CardHomeState extends State<CardHome> {
  /* int? height , width;
  _CardHomeState(this.height, this.width);*/

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final path = widget.model_apartment!.images[0].image.trim();
    final url = 'http://10.0.2.2:8000/storage/$path';
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          ShowScreen.id,
          arguments: widget.model_apartment,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(0, 8),
              ),
            ],
          ),
          width: 270,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        height: 200,
                        width: 260,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          color: isFavorite ? Colors.red : Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.blueGrey),
                    Text(
                      ' ${widget.model_apartment!.governorate} , ${widget.model_apartment!.city} ',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 5,right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r'$ '
                      '${widget.model_apartment!.rent.toString()} - ${widget.model_apartment!.rent_type}',
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        Text(
                          widget.model_apartment!.home_rate.toString(),
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
