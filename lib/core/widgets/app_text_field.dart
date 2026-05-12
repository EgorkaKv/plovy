import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hintText,
    super.key,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
