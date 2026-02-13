import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/shared/mixins/form_field_error_state_mixin.dart';
import 'package:flutter/material.dart';

class CustomTextField extends FormField<String> {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumeric;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    bool isRequired = true,
    this.isNumeric = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    String? Function(String?)? validator,
  }) : super(
         initialValue: controller.text,
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
           if (validator != null) {
             return validator(value);
           }
           return null;
         },
         builder: (FormFieldState<String> fieldState) {
           final state = fieldState as _CustomTextFieldState;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Container(
                 decoration: BoxDecoration(
                   color: AppColors.surface,
                   borderRadius: BorderRadius.circular(16),
                   boxShadow: [
                     BoxShadow(
                       color: AppColors.shadow.withValues(alpha: 0.05),
                       blurRadius: 10,
                       offset: const Offset(0, 4),
                     ),
                   ],
                   border: Border.all(
                     color: state.hasError && state.isErrorVisible
                         ? AppColors.danger
                         : Colors.transparent,
                     width: 1.0,
                   ),
                 ),
                 child: TextField(
                   controller: controller,
                   onChanged: (text) {
                     state.didChange(text);
                   },
                   keyboardType: isNumeric
                       ? const TextInputType.numberWithOptions(decimal: true)
                       : TextInputType.text,
                   readOnly: readOnly,
                   onTap: () {
                     state.hideError();
                     onTap?.call();
                   },
                   maxLines: maxLines,
                   style: const TextStyle(color: AppColors.textPrimary),
                   decoration: InputDecoration(
                     labelText: isRequired ? label : "$label (Opcional)",
                     labelStyle: TextStyle(
                       color: state.hasError && state.isErrorVisible
                           ? AppColors.danger
                           : AppColors.textLight,
                     ),
                     prefixIcon: Icon(
                       icon,
                       color: state.hasError && state.isErrorVisible
                           ? AppColors.danger
                           : AppColors.primary,
                     ),
                     filled: false,
                     border: InputBorder.none,
                     enabledBorder: InputBorder.none,
                     focusedBorder: InputBorder.none,
                     errorBorder: InputBorder.none,
                     contentPadding: const EdgeInsets.symmetric(
                       horizontal: 16,
                       vertical: 12,
                     ),
                   ),
                 ),
               ),
               SizedBox(
                 height: 20,
                 child: Padding(
                   padding: const EdgeInsets.only(left: 16, top: 4),
                   child: Text(
                     (state.hasError && state.isErrorVisible)
                         ? state.errorText!
                         : "",
                     style: const TextStyle(
                       color: AppColors.danger,
                       fontSize: 12,
                       height: 1.0,
                     ),
                   ),
                 ),
               ),
             ],
           );
         },
       );

  @override
  FormFieldState<String> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends FormFieldState<String>
    with FormFieldErrorStateMixin<String> {}
