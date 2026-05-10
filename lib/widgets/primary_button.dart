import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.danger = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final style = danger
        ? FilledButton.styleFrom(
      backgroundColor: AppColors.danger,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    )
        : null;

    final button = icon == null
        ? FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(text),
    )
        : FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon),
      label: Text(text),
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 60,
      child: button,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = icon == null
        ? OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    )
        : OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 60,
      child: button,
    );
  }
}