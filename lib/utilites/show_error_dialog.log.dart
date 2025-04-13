import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Future<void> showErrorDialog(BuildContext context, String errorMessage) {
  return showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Login Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}
