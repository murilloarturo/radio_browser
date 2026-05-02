import 'package:flutter/material.dart';

SnackBar persistentErrorSnackBar({
  required BuildContext context,
  required String message,
  required String closeTooltip,
}) {
  final theme = Theme.of(context);
  final closeIconColor =
      theme.snackBarTheme.closeIconColor ?? theme.colorScheme.onInverseSurface;

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
          color: closeIconColor,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    ),
  );
}
