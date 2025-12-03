import 'package:flutter/material.dart';

class Second_card_home extends StatefulWidget {
  @override
  State<Second_card_home> createState() => _Second_card_homeState();
}

class _Second_card_homeState extends State<Second_card_home> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                height: 100,
                width: 105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/image.jfif'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pelican Hill',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  Text(
                    r'$ 842.00',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.blueGrey),
                      Text(
                        ' Syria , Damascus ',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                      ),
                    ],
                  ),
                ],
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
                        '5.0',
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
    );
  }
}
