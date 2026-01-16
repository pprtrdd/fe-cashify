import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/category_dropdown_field.dart';
import 'package:cashify/features/transaction/presentation/widgets/custom_text_field.dart';
import 'package:cashify/features/transaction/presentation/widgets/month_year_picker.dart';
import 'package:cashify/features/transaction/presentation/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashify/core/theme/app_colors.dart';

class MovementFormScreen extends StatefulWidget {
  const MovementFormScreen({super.key});

  @override
  State<MovementFormScreen> createState() => _MovementFormScreenState();
}

class _MovementFormScreenState extends State<MovementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  bool _isCompleted = true;

  final _descController = TextEditingController();
  final _sourceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _amountController = TextEditingController();
  final _currentInstallmentController = TextEditingController();
  final _totalInstallmentsController = TextEditingController();
  final _periodController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovementProvider>().loadAllData();
    });
  }

  void _initializeDefaults() {
    _periodController.text =
        "${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";
    _currentInstallmentController.text = "1";
    _totalInstallmentsController.text = "1";
    _qtyController.text = "1";
  }

  @override
  void dispose() {
    for (var c in [
      _descController,
      _sourceController,
      _qtyController,
      _amountController,
      _currentInstallmentController,
      _totalInstallmentsController,
      _periodController,
      _notesController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text("Nuevo Movimiento"),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CategoryDropdownField(
                    value: _selectedCategory,
                    provider: provider,
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: _descController,
                    label: "Descripción",
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: _sourceController,
                    label: "Origen",
                    icon: Icons.source,
                    isRequired: false,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _qtyController,
                          label: "Cant.",
                          icon: Icons.shopping_basket,
                          isNumeric: true,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: CustomTextField(
                          controller: _amountController,
                          label: "Monto",
                          icon: Icons.attach_money,
                          isNumeric: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _currentInstallmentController,
                          label: "Cuota",
                          icon: Icons.tag,
                          isNumeric: true,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "/",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomTextField(
                          controller: _totalInstallmentsController,
                          label: "Total",
                          icon: Icons.layers,
                          isNumeric: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPaymentMethod,
                    decoration: _inputStyle("Método de Pago", Icons.payment),
                    items: provider.paymentMethods
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedPaymentMethod = val),
                    validator: (v) => v == null ? "Requerido" : null,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: _periodController,
                    label: "Período",
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () => _selectPeriod(context),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: _notesController,
                    label: "Notas",
                    icon: Icons.note_add,
                    maxLines: 3,
                    isRequired: false,
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _isCompleted
                          ? AppColors.success.withValues(alpha: 0.08)
                          : AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isCompleted
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.warning.withValues(alpha: 0.2),
                      ),
                    ),
                    child: SwitchListTile(
                      activeThumbColor: AppColors.success,
                      title: Text(
                        _isCompleted
                            ? "Movimiento Completado"
                            : "Movimiento Pendiente",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isCompleted
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                      secondary: Icon(
                        _isCompleted
                            ? Icons.check_circle
                            : Icons.pending_actions,
                        color: _isCompleted
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      value: _isCompleted,
                      onChanged: (bool value) =>
                          setState(() => _isCompleted = value),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SaveButton(
                    isLoading: provider.isLoading,
                    onPressed: () => _save(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _selectPeriod(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MonthYearPickerSheet(
        initialDate: _selectedDate,
        onDateChanged: (DateTime newDate) {
          setState(() {
            _selectedDate = newDate;
            _periodController.text =
                "${newDate.month.toString().padLeft(2, '0')}/${newDate.year}";
          });
        },
      ),
    );
  }

  void _save(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final movement = MovementEntity(
        id: '',
        /* ID will be generated by the repository */
        categoryId: _selectedCategory!,
        description: _descController.text,
        source: _sourceController.text,
        quantity: int.tryParse(_qtyController.text) ?? 1,
        amount: int.tryParse(_amountController.text) ?? 0,
        currentInstallment:
            int.tryParse(_currentInstallmentController.text) ?? 1,
        totalInstallments: int.tryParse(_totalInstallmentsController.text) ?? 1,
        paymentMethodId: _selectedPaymentMethod!,
        billingPeriodYear: _selectedDate.year,
        billingPeriodMonth: _selectedDate.month,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        isCompleted: _isCompleted,
      );

      try {
        await context.read<MovementProvider>().createMovement(movement);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movimiento guardado con éxito'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
