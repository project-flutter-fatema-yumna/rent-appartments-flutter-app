import 'package:flats_app/Services/add_and_remove_from_favourites.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/providers/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/showScreen.dart';
import '../helper/Host.dart';

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
    if (widget.model_apartment == null ||
        widget.model_apartment!.images.isEmpty)
      return Center(child: Icon(Icons.image_not_supported));

    final path = widget.model_apartment!.images[0].image.trim();
    final url = 'http://${Host.host}:8000/storage/$path';

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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    width: 100,
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: 100,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
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
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                          ),
                          Text(
                            '${widget.model_apartment!.city} ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          r'$ '
                          '${widget.model_apartment!.rent} - ${widget.model_apartment!.rent_type}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          color: isFav
                              ? Colors.red
                              : Theme.of(context).textTheme.bodyLarge!.color,
                        );
                      },
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        Text(
                          widget.model_apartment!.home_rate.toInt().toString(),
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
            ],
          ),
        ),
      ),
    );
  }
}
