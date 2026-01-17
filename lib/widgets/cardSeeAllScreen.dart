import 'dart:ui';

import 'package:flats_app/Services/add_and_remove_from_favourites.dart';
import 'package:flats_app/providers/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/showScreen.dart';
import '../helper/Host.dart';
import '../models/model_apartment.dart';

class CardSeeAll extends StatefulWidget {
  final Model_Apartment model_apartment;
  const CardSeeAll({super.key, required this.model_apartment});

  @override
  State<CardSeeAll> createState() => _CardSeeAllState();
}

class _CardSeeAllState extends State<CardSeeAll> {
  @override
  Widget build(BuildContext context) {
    if (widget.model_apartment.images.isEmpty)
      return Center(child: Icon(Icons.image_not_supported));

    final path = widget.model_apartment.images[0].image.trim();
    final url = 'http://${Host.host}:8000/storage/$path';

    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          ShowScreen.id,
          arguments: widget.model_apartment,
        ),
        child: Container(
          height: 246,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  children: [
                    ClipRRect(
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
                              widget.model_apartment.id,
                            );
                            return IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              iconSize: 22,
                              onPressed: () async {
                                favProvider.toggleFavorite(
                                  widget.model_apartment.id,
                                );
                                final result = await toggleFavoriteStatus(
                                  widget.model_apartment.id,
                                );
                                if (result == null) {
                                  favProvider.toggleFavorite(
                                    widget.model_apartment.id,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error updating favorite'),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                color: isFav
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  height: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${widget.model_apartment.governorate}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          '${widget.model_apartment.city}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r'$ '
                      '${widget.model_apartment.rent}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        Text(
                          '${widget.model_apartment.home_rate}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}
