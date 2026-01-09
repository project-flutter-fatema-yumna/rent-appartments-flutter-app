import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/material.dart';

import '../Screens/showScreen.dart';

class Second_card_home extends StatefulWidget {
  Model_Apartment? model_apartment;

  Second_card_home({required this.model_apartment});

  @override
  State<Second_card_home> createState() => _Second_card_homeState();
}

class _Second_card_homeState extends State<Second_card_home> {
  bool isFavorite = false;


  @override
  Widget build(BuildContext context) {

    if(widget.model_apartment==null || widget.model_apartment!.images.isEmpty) return Center(child: Icon(Icons.image_not_supported));

    final path = widget.model_apartment!.images[0].image.trim();
    final url='http://10.0.2.2:8000/storage/$path';

    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, ShowScreen.id,arguments: widget.model_apartment);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child:ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    width: 105,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          widget.model_apartment!.governorate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: Colors.blueGrey),
                          Text(
                            '${widget.model_apartment!.city} ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          r'$ ' '${widget.model_apartment!.rent} - ${widget.model_apartment!.rent_type}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      icon: isFavorite
                          ? Icon(Icons.favorite)
                          : Icon(Icons.favorite_border_outlined),
                      color: isFavorite ? Colors.red : Colors.grey,
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
