import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class AiParseButton extends StatelessWidget {
  const AiParseButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  final String? text;
  final Widget? child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primary,
        backgroundColor: const Color(0xFFEEFCFC),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppTheme.primary),
        ),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      onPressed: onPressed,
      child: child ?? Text(text!),
    );
  }
}
