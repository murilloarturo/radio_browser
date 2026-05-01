import 'package:flutter/material.dart';

SnackBar persistentErrorSnackBar({
  required BuildContext context,
  required String message,
  required String closeTooltip,
}) {
  return SnackBar(
    duration: const Duration(days: 365),
    behavior: SnackBarBehavior.floating,
    content: Row(
      children: [
        Expanded(child: Text(message)),
        IconButton(
          tooltip: closeTooltip,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          color: Colors.white,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    ),
  );
}
