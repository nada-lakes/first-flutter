import 'package:flutter/material.dart';

class LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType inputType;
  final String? Function(String?)? validator;

  const LabeledTextField({
    super.key,
    required this.controller,
    required this.label,
    this.inputType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(labelText: label),
          validator: validator,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
