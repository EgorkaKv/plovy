import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.isEnabled = true,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = isEnabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isButtonEnabled ? onPressed : null,
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Text(text),
      ),
    );
  }
}
