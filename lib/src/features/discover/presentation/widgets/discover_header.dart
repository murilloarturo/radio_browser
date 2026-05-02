import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/localizable.dart';

class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Row(
      children: [
        Expanded(
          child: Text(
            Localizable.appTitle.text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
