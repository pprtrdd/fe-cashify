import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/shared/helpers/ui_helper.dart';
import 'package:cashify/features/transaction/domain/entities/frequent_movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/frequent_movement_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/category_dropdown_field.dart';
import 'package:cashify/features/transaction/presentation/widgets/custom_text_field.dart';
import 'package:cashify/features/transaction/presentation/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FrequentFormScreen extends StatefulWidget {
  final FrequentMovementEntity? frequent;

  const FrequentFormScreen({super.key, this.frequent});

  @override
  State<FrequentFormScreen> createState() => _FrequentFormScreenState();
}

class _FrequentFormScreenState extends State<FrequentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  FrequentFrequency _frequency = FrequentFrequency.monthly;

  final _descController = TextEditingController();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _paymentDayController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.frequent != null) {
      isEditing = true;
      _selectedCategory = widget.frequent!.categoryId;
      _descController.text = widget.frequent!.description;
      _sourceController.text = widget.frequent!.source;
      _amountController.text = widget.frequent!.amount.toString();
      _paymentDayController.text = widget.frequent!.paymentDay.toString();
      _frequency = widget.frequent!.frequency;
    } else {
      _paymentDayController.text = "1";
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _sourceController.dispose();
    _amountController.dispose();
    _paymentDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? "Editar Frecuente" : "Nuevo Frecuente"),
        centerTitle: true,
      ),
      body: Consumer<FrequentMovementProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CategoryDropdownField(
                          value: _selectedCategory,
                          provider: context.read<MovementProvider>(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
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
                        CustomTextField(
                          controller: _amountController,
                          label: "Monto sugerido",
                          icon: Icons.attach_money,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 15),
                        _buildFrequencyDropdown(),
                        const SizedBox(height: 15),
                        CustomTextField(
                          controller: _paymentDayController,
                          label: "Día de pago",
                          icon: Icons.calendar_today,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SaveButton(
                    isLoading: provider.isLoading,
                    onPressed: () => _save(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<FrequentFrequency>(
      initialValue: _frequency,
      decoration: InputDecoration(
        labelText: "Frecuencia",
        prefixIcon: const Icon(Icons.repeat, color: AppColors.primary),
      ),
      items: FrequentFrequency.values
          .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
          .toList(),
      onChanged: (val) => setState(() => _frequency = val!),
    );
  }

  void _save(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        context.showErrorSnackBar("Selecciona una categoría");
        return;
      }

      final frequentProv = context.read<FrequentMovementProvider>();

      final frequent = FrequentMovementEntity(
        id: isEditing ? widget.frequent!.id : '',
        categoryId: _selectedCategory!,
        description: _descController.text,
        source: _sourceController.text,
        amount: int.parse(_amountController.text),
        frequency: _frequency,
        paymentDay: int.parse(_paymentDayController.text),
        isArchived: false,
        createdAt: isEditing ? widget.frequent!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await frequentProv.saveFrequent(frequent);
        if (context.mounted) {
          context.showSuccessSnackBar(
            isEditing ? "Frecuente actualizado" : "Frecuente guardado",
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          context.showErrorSnackBar("Error al guardar frecuente: $e");
        }
      }
    }
  }
}
