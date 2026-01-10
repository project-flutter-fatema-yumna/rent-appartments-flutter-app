import 'package:flats_app/Services/add_and_remove_from_favourites.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/providers/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/showScreen.dart';

class Second_card_home extends StatefulWidget {
  Model_Apartment? model_apartment;
  final VoidCallback? onToggleSuccess;

  Second_card_home({required this.model_apartment, this.onToggleSuccess});

  @override
  State<Second_card_home> createState() => _Second_card_homeState();
}

class _Second_card_homeState extends State<Second_card_home> {
  late bool isFavorite;

  @override
  void initState() {
    isFavorite = widget.onToggleSuccess != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.model_apartment!.images;

    final ImageProvider imageProvider = images.isNotEmpty
        ? NetworkImage('http://10.0.2.2:8000/storage/${images.first.image}')
        : const AssetImage('assets/no_image.jpg');

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          ShowScreen.id,
          arguments: widget.model_apartment,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pelican Hill',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 20),
                    ),
                    Text(
                      r'$ 842.00',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        Text(
                          '${widget.model_apartment!.governorate} ',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<FavoriteProvider>(
                      builder: (context, favProvider, child) {
                        final bool isFav = favProvider.isFavorite(
                          widget.model_apartment!.id,
                        );

                        return IconButton(
                          onPressed: () async {
                            favProvider.toggleFavorite(
                              widget.model_apartment!.id,
                            );
                            final result = await toggleFavoriteStatus(
                              widget.model_apartment!.id,
                            );
                            if (result == null) {
                              favProvider.toggleFavorite(
                                widget.model_apartment!.id,
                              );
                            } else {
                              if (widget.onToggleSuccess != null) {
                                widget.onToggleSuccess!();
                              }
                            }
                          },
                          icon: Icon(
                            isFav
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                          ),
                          color: isFav ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color,
                        );
                      },
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        Text(
                          widget.model_apartment!.home_rate.toInt().toString(),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 15),
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
