import 'package:flutter/material.dart';

import 'button_debouncer.dart';

class ButtonCommon extends StatelessWidget {
  ButtonCommon({
    Key? key,
    this.title = '',
    this.titleTextColor,
    this.buttonContainerPadding =
        const EdgeInsets.symmetric(vertical: 8.0),
    BoxDecoration? buttonContainerDecoration,
    this.buttonContainerMargin,
    this.onTap,
    this.width,
    this.height,
  }) : super(key: key) {
    _buttonContainerDecoration = buttonContainerDecoration ??
        BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all());
  }

  final String title;
  final Color? titleTextColor;
  final EdgeInsets? buttonContainerPadding;
  final EdgeInsets? buttonContainerMargin;
  late final BoxDecoration? _buttonContainerDecoration;
  final VoidCallback? onTap;
  final ButtonDebouncer buttonDebouncer =
      ButtonDebouncer(delay: const Duration(seconds: 1));
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => buttonDebouncer.call(() => onTap?.call()),
      child: Container(
        margin: buttonContainerMargin,
        alignment: Alignment.center,
        width: width ?? 170.0,
        height: height ?? 44.0,
        padding: buttonContainerPadding,
        decoration: _buttonContainerDecoration,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: titleTextColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
