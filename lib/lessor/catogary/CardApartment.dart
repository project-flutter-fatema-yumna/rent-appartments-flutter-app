import 'package:flats_app/models/model_apartment.dart';
import 'package:flutter/material.dart';

class ApartmentCardUI extends StatelessWidget {
 final  Model_Apartment model_apartment;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ApartmentCardUI({
    required this.model_apartment,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final path = model_apartment.images[0].image.trim();
    final url='http://10.0.2.2:8000/storage/$path';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0.8,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap:onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue.shade50,
                  child: Image.network(url,  fit:BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model_apartment.governorate,
                     // maxLines: 1,
                     // overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Text(
                          "${model_apartment.rent} - ${model_apartment.rent_type}",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.blue.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            model_apartment.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star,color: Colors.orange,),
                        SizedBox(width: 5,),
                        Text(model_apartment.home_rate.toString()),
                      ],
                    )
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    tooltip: "Edit",
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: "Delete",
                    color: Colors.red,
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
