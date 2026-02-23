import '../providers/movement_provider.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/shared/mixins/form_field_error_state_mixin.dart';
import 'package:flutter/material.dart';

class CategoryDropdownField extends FormField<String> {
  final MovementProvider provider;
  final ValueChanged<String?> onChanged;

  CategoryDropdownField({
    super.key,
    required String? value,
    required this.provider,
    required this.onChanged,
  }) : super(
         initialValue: value,
         validator: (v) => v == null ? "Selecciona una categoría" : null,
         builder: (FormFieldState<String> fieldState) {
           final state = fieldState as _CategoryDropdownFieldState;
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
                         : AppColors.transparent,
                     width: 1.0,
                   ),
                 ),
                 child: DropdownButtonHideUnderline(
                   child: ButtonTheme(
                     alignedDropdown: true,
                     child: DropdownButton<String>(
                       value: state.value,
                       isExpanded: true,
                       hint: Row(
                         children: [
                           Icon(
                             Icons.category_outlined,
                             color: state.hasError && state.isErrorVisible
                                 ? AppColors.danger
                                 : AppColors.primary,
                           ),
                           const SizedBox(width: 10),
                           Text(
                             provider.isLoading ? "Cargando..." : "Categoría",
                             style: TextStyle(
                               color: state.hasError && state.isErrorVisible
                                   ? AppColors.danger
                                   : AppColors.textLight,
                               fontSize: 16,
                             ),
                           ),
                         ],
                       ),
                       items: provider.categories
                           .where(
                             (cat) => !cat.isArchived || cat.id == state.value,
                           )
                           .map((cat) {
                             final bool isExpense = cat.isExpense;
                             final Color iconColor = isExpense
                                 ? AppColors.expense
                                 : AppColors.income;

                             return DropdownMenuItem<String>(
                               value: cat.id,
                               child: Row(
                                 children: [
                                   Icon(
                                     isExpense
                                         ? Icons.remove_circle_outline
                                         : Icons.add_circle_outline,
                                     color: iconColor,
                                     size: 18,
                                   ),
                                   const SizedBox(width: 10),
                                   Text(
                                     cat.name,
                                     style: const TextStyle(
                                       color: AppColors.textPrimary,
                                     ),
                                   ),
                                 ],
                               ),
                             );
                           })
                           .toList(),
                       onChanged: (val) {
                         state.didChange(val);
                         onChanged(val);
                       },
                       onTap: () {
                         state.hideError();
                       },
                       dropdownColor: AppColors.surface,
                       borderRadius: BorderRadius.circular(16),
                       icon: const Icon(
                         Icons.arrow_drop_down,
                         color: AppColors.textLight,
                       ),
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
  FormFieldState<String> createState() => _CategoryDropdownFieldState();
}

class _CategoryDropdownFieldState extends FormFieldState<String>
    with FormFieldErrorStateMixin<String> {}
