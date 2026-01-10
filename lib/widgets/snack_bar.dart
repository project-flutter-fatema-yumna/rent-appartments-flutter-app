import 'package:flutter/material.dart';

mySnackBar(BuildContext context, String msg,{
  Color color=Colors.red, bool showIcon=true}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).cardColor,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              showIcon? Icon(Icons.error_outline, color: color):SizedBox(),
              SizedBox(width: 10),
              Text(msg, style: TextStyle(color: color)),
            ],
          ),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }