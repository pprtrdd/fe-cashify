import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/movement_entity.dart';
import '../providers/movement_provider.dart';
import '../widgets/custom_text_field.dart';

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

  // Controllers
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
      context
          .read<MovementProvider>()
          .loadAllData(); // Cargamos todo de una vez
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Movimiento"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<MovementProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCategoryDropdown(provider),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: _descController,
                    label: "Descripción",
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: _sourceController,
                    label: "Origen / Fuente",
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

                  _buildPaymentMethodDropdown(provider),
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
                  const SizedBox(height: 30),

                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: () => _save(context),
                          icon: const Icon(Icons.save),
                          label: const Text("Guardar Movimiento"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(MovementProvider provider) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: provider.isLoading ? "Cargando..." : "Categoría",
        prefixIcon: provider.isLoading
            ? const SizedBox(
                width: 10,
                height: 10,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.category_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: provider.categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat.id,
          child: Row(
            children: [
              Icon(
                cat.isExpense == true
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: cat.isExpense == true ? Colors.red : Colors.green,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(cat.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
      validator: (value) => value == null ? "Selecciona una categoría" : null,
    );
  }

  Widget _buildPaymentMethodDropdown(MovementProvider provider) {
    return Consumer<MovementProvider>(
      builder: (context, provider, child) {
        return DropdownButtonFormField<String>(
          initialValue: _selectedPaymentMethod,
          decoration: InputDecoration(
            labelText: provider.isLoading ? "Cargando..." : "Método de Pago",
            prefixIcon: provider.isLoading
                ? const SizedBox(
                    width: 10,
                    height: 10,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.payment),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: provider.paymentMethods.map((method) {
            return DropdownMenuItem<String>(
              value: method.id,
              child: Text(method.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          },
          validator: (value) => value == null ? "Selecciona un método" : null,
        );
      },
    );
  }

  Future<void> _selectPeriod(BuildContext context) async {
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime(2100);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.monthYear,
                  initialDateTime: _selectedDate,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      _periodController.text =
                          "${newDate.month.toString().padLeft(2, '0')}/${newDate.year}";
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _save(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final movement = MovementEntity(
        categoryId: _selectedCategory!,
        description: _descController.text,
        source: _sourceController.text,
        quantity: int.tryParse(_qtyController.text) ?? 0,
        amount: int.tryParse(_amountController.text) ?? 0,
        currentInstallment:
            int.tryParse(_currentInstallmentController.text) ?? 0,
        totalInstallments: int.tryParse(_totalInstallmentsController.text) ?? 0,
        paymentMethodId: _selectedPaymentMethod!,
        billingPeriodYear: _selectedDate.year,
        billingPeriodMonth: _selectedDate.month,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      try {
        await context.read<MovementProvider>().createMovement(movement);

        if (!context.mounted) return;

        await context.read<MovementProvider>().loadMovementsByMonth();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movimiento guardado con éxito'),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
