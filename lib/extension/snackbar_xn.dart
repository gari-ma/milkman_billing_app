import 'package:flutter/material.dart';

void showSuccessSnackBar(
    {required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        const Icon(
          Icons.done,
          color: Colors.white,
        ),
        const SizedBox(
          width: 20,
          height: 10,
        ),
        Text(message, style: const TextStyle(color: Colors.white)),
      ],
    ),
    backgroundColor: Colors.green,
  ));
}

void showErrorSnackBar(
    {required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        const Icon(
          Icons.error,
          color: Colors.white,
        ),
        const SizedBox(
          width: 20,
          height: 10,
        ),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
      ],
    ),
    backgroundColor: Colors.red,
  ));
}
