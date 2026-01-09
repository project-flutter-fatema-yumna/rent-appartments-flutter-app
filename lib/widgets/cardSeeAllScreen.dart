import 'dart:ui';

import 'package:flutter/material.dart';

import '../Screens/showScreen.dart';
import '../models/model_apartment.dart';

class CardSeeAll extends StatefulWidget {
  final Model_Apartment model_apartment;
  const CardSeeAll({super.key, required this.model_apartment});

  @override
  State<CardSeeAll> createState() => _CardSeeAllState();
}

class _CardSeeAllState extends State<CardSeeAll> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    if( widget.model_apartment.images.isEmpty) return Center(child: Icon(Icons.image_not_supported));

    final path = widget.model_apartment.images[0].image.trim();
    final url='http://10.0.2.2:8000/storage/$path';

    return Material(
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          ShowScreen.id,
          arguments: widget.model_apartment,
        ),
        child: SizedBox(
          height: 246,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            iconSize: 22,
                            onPressed: () => setState(() => isFavorite = !isFavorite),
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
                            const Icon(Icons.location_on,
                                color: Colors.blueGrey, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${widget.model_apartment.governorate}',
                                style: const TextStyle(
                                    color: Colors.blueGrey, fontSize: 12),
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
                            style: const TextStyle(
                                color: Colors.blueGrey, fontSize: 12),
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
                        r'$ ''${widget.model_apartment.rent}',
                        style: const TextStyle(color: Colors.blue, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.orange, size: 20),
                          Text(
                            '${widget.model_apartment.home_rate}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
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
      ),
    );
  }
}
