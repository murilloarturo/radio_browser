import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';

class StationSearchBar extends StatefulWidget {
  const StationSearchBar({
    required this.value,
    required this.onSubmitted,
    super.key,
  });

  final String value;
  final ValueChanged<String> onSubmitted;

  @override
  State<StationSearchBar> createState() => _StationSearchBarState();
}

class _StationSearchBarState extends State<StationSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant StationSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.search_rounded, color: AppColors.ink, size: 30),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSubmitted,
                decoration: InputDecoration(
                  hintText: Localizable.searchWithAiHint.text,
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            IconButton(
              tooltip: Localizable.searchWithAiHint.text,
              onPressed: () {},
              icon: const Icon(Icons.mic_none_rounded, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
