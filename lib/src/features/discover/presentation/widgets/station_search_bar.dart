import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';

class StationSearchBar extends StatefulWidget {
  const StationSearchBar({
    required this.value,
    required this.onSubmitted,
    required this.onVoicePressed,
    this.isVoiceSearchRecording = false,
    this.isVoiceSearchProcessing = false,
    super.key,
  });

  final String value;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onVoicePressed;
  final bool isVoiceSearchRecording;
  final bool isVoiceSearchProcessing;

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
    final colors = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.search_rounded, color: colors.ink, size: 30),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(color: colors.ink),
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
              tooltip:
                  widget.isVoiceSearchRecording
                      ? Localizable.voiceSearchStop.text
                      : Localizable.voiceSearchStart.text,
              onPressed:
                  widget.isVoiceSearchProcessing ? null : widget.onVoicePressed,
              icon:
                  widget.isVoiceSearchProcessing
                      ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Icon(
                        widget.isVoiceSearchRecording
                            ? Icons.stop_rounded
                            : Icons.mic_none_rounded,
                        color:
                            widget.isVoiceSearchRecording
                                ? colors.danger
                                : colors.ink,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
