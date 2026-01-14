import 'package:flats_app/Screens/showScreen.dart';
import 'package:flats_app/Services/add_and_remove_from_favourites.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/providers/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardHome extends StatefulWidget {
  Model_Apartment? model_apartment;

  CardHome({this.model_apartment});

  @override
  State<CardHome> createState() => _CardHomeState();
}

class _CardHomeState extends State<CardHome> {
  /* int? height , width;
  _CardHomeState(this.height, this.width);*/

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
            color: Theme.of(context).cardColor,
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
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
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
                      child: Consumer<FavoriteProvider>(
                        builder: (context, favProvider, child) {
                          final bool isFav = favProvider.isFavorite(
                            widget.model_apartment!.id,
                          );

                          return IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            iconSize: 22,
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to download favourites',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: isFav ? Colors.red : Theme.of(context).cardColor,
                            ),
                          );
                        },
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
                    Icon(Icons.location_on, color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    Text(
                      ' ${widget.model_apartment!.governorate} , ${widget.model_apartment!.city} ',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r'$ '
                      '${widget.model_apartment!.rent.toString()} - ${widget.model_apartment!.rent_type}',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        Text(
                          widget.model_apartment!.home_rate.toString(),
                          style: TextStyle(color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color, fontSize: 15),
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
