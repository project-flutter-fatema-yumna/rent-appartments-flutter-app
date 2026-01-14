import 'package:flutter/material.dart';

Future<void> showAppDialog(
    BuildContext context, {
      required String title,
      required String message,
      String buttonText = 'OK',
    }) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(buttonText),
        ),
      ],
    ),
  );
}
