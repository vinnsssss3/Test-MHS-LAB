import 'package:flutter/material.dart';

class ValidatedField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int maxLines;

  const ValidatedField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:  controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines:    maxLines,
      style:       const TextStyle(color: Color(0xFFE6E8EF)),
      decoration: InputDecoration(
        labelText:   label,
        hintText:    hint,
        hintStyle:   const TextStyle(color: Color(0xFF6B6F82)),
        suffixIcon:  suffixIcon,
      ),
      validator:   validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
