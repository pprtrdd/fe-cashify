import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isRequired;
  final bool isNumeric;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isRequired = true,
    this.isNumeric = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: (value) {
        if (!isRequired && (value == null || value.isEmpty)) return null;
        if (isRequired && (value == null || value.isEmpty)) {
          return "Campo requerido";
        }
        if (isNumeric && value != null && value.isNotEmpty) {
          if (double.tryParse(value.replaceAll(',', '.')) == null) {
            return "Número inválido";
          }
        }
        return validator?.call(value);
      },
      decoration: InputDecoration(
        labelText: isRequired ? label : "$label (Opcional)",
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
