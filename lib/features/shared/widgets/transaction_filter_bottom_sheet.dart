import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/category/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/entities/payment_method_entity.dart';
import 'package:cashify/features/frequent/domain/entities/frequent_transaction_entity.dart';
import 'package:cashify/features/shared/widgets/save_button.dart';
import 'package:flutter/material.dart';

class TransactionFilterBottomSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final List<PaymentMethodEntity>? paymentMethods;

  final String? initialCategoryId;
  final String? initialPaymentMethodId;
  final String? initialType;
  final bool? initialIsCompleted;
  final FrequentFrequency? initialFrequency;
  final bool showFrequencyFilter;

  final Function({
    String? categoryId,
    String? paymentMethodId,
    String? type,
    bool? isCompleted,
    FrequentFrequency? frequency,
  })
  onApply;

  const TransactionFilterBottomSheet({
    super.key,
    required this.categories,
    this.paymentMethods,
    this.initialCategoryId,
    this.initialPaymentMethodId,
    this.initialType,
    this.initialIsCompleted,
    this.initialFrequency,
    this.showFrequencyFilter = false,
    required this.onApply,
  });

  @override
  State<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends State<TransactionFilterBottomSheet> {
  String? _categoryId;
  String? _paymentMethodId;
  String? _type;
  bool? _isCompleted;
  FrequentFrequency? _frequency;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _paymentMethodId = widget.initialPaymentMethodId;
    _type = widget.initialType;
    _isCompleted = widget.initialIsCompleted;
    _frequency = widget.initialFrequency;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filtros",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTypeSelector(),
          const SizedBox(height: 16),
          _buildStatusSelector(),
          const SizedBox(height: 16),
          _buildCategoryDropdown(),
          if (widget.paymentMethods != null) ...[
            const SizedBox(height: 16),
            _buildPaymentDropdown(),
          ],
          if (widget.showFrequencyFilter) ...[
            const SizedBox(height: 16),
            _buildFrequencyDropdown(),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _categoryId = null;
                      _paymentMethodId = null;
                      _type = null;
                      _isCompleted = null;
                      _frequency = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Limpiar",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SaveButton(
                  label: "Aplicar",
                  isLoading: false,
                  onPressed: () {
                    widget.onApply(
                      categoryId: _categoryId,
                      paymentMethodId: _paymentMethodId,
                      type: _type,
                      isCompleted: _isCompleted,
                      frequency: _frequency,
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tipo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChip("Todos", null, _type),
            const SizedBox(width: 8),
            _buildChip(
              "Ingreso",
              "income",
              _type,
              (val) => setState(() => _type = val),
            ),
            const SizedBox(width: 8),
            _buildChip(
              "Gasto",
              "expense",
              _type,
              (val) => setState(() => _type = val),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Estado",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChip("Todos", null, _isCompleted?.toString()),
            const SizedBox(width: 8),
            _buildChip(
              "Completado",
              "true",
              _isCompleted?.toString(),
              (val) => setState(() => _isCompleted = val == "true"),
            ),
            const SizedBox(width: 8),
            _buildChip(
              "Pendiente",
              "false",
              _isCompleted?.toString(),
              (val) =>
                  setState(() => _isCompleted = val == "true" ? true : false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(
    String label,
    String? value,
    String? groupValue, [
    Function(String?)? onChanged,
  ]) {
    final isSelected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onChanged != null) {
            onChanged(value);
          } else {
            setState(() {
              if (value == null) {
                if (label == "Todos") {
                  if (groupValue == _type) _type = null;
                  if (groupValue == _isCompleted?.toString()) {
                    _isCompleted = null;
                  }
                }
              }
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdownItem(
      "Categoría",
      _categoryId,
      widget.categories
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
          .toList(),
      (val) => setState(() => _categoryId = val),
    );
  }

  Widget _buildPaymentDropdown() {
    return _buildDropdownItem(
      "Método de Pago",
      _paymentMethodId,
      widget.paymentMethods!
          .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
          .toList(),
      (val) => setState(() => _paymentMethodId = val),
    );
  }

  Widget _buildFrequencyDropdown() {
    return _buildDropdownItem(
      "Frecuencia",
      _frequency,
      FrequentFrequency.values
          .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
          .toList(),
      (val) => setState(() => _frequency = val),
    );
  }

  Widget _buildDropdownItem<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    Function(T?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          icon: const Icon(Icons.arrow_drop_down),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text("Seleccionar $label..."),
            ),
            ...items,
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
