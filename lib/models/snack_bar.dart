import 'package:flutter/material.dart';

mySnackBar(BuildContext context, String msg) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text(msg, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }