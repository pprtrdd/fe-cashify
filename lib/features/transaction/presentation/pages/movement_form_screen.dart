import 'package:cashify/core/auth/auth_service.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovementFormScreen extends StatefulWidget {
  const MovementFormScreen({super.key});

  @override
  State<MovementFormScreen> createState() => _MovementFormScreenState();
}

String? _selectedCategory;
String? _selectedPaymentMethod;

class _MovementFormScreenState extends State<MovementFormScreen> {
  DateTime _selectedDate = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController();
  final _descController = TextEditingController();
  final _sourceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _amountController = TextEditingController();
  final _currentInstallmentController = TextEditingController();
  final _totalInstallmentsController = TextEditingController();
  final _methodController = TextEditingController();
  final _periodController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovementProvider>().loadCategories();
      context.read<MovementProvider>().loadPaymentMethods();
    });

    _periodController.text =
        "${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";
    _currentInstallmentController.text = "1";
    _totalInstallmentsController.text = "1";
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descController.dispose();
    _sourceController.dispose();
    _qtyController.dispose();
    _amountController.dispose();
    _currentInstallmentController.dispose();
    _totalInstallmentsController.dispose();
    _methodController.dispose();
    _periodController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Movimientos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Cerrar Sesión"),
                  content: const Text("¿Estás seguro de que quieres salir?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Salir",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService().signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<MovementProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: provider.isLoading
                          ? "Cargando..."
                          : "Categoría",
                      prefixIcon: provider.isLoading
                          ? const SizedBox(
                              width: 10,
                              height: 10,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor:
                          Colors.grey[50],
                    ),
                    items: provider.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(
                              cat.isExpense
                                  ? Icons.remove_circle_outline
                                  : Icons.add_circle_outline,
                              color: cat.isExpense ? Colors.red : Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                    validator: (value) =>
                        value == null ? "Selecciona una categoría" : null,
                  );
                },
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _descController,
                label: "Descripción",
                icon: Icons.description,
                validator: (value) => value!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _sourceController,
                label: "Origen / Fuente",
                icon: Icons.source,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _qtyController,
                      label: "Cantidad",
                      icon: Icons.production_quantity_limits,
                      isNumeric: true,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: _amountController,
                      label: "Monto",
                      icon: Icons.attach_money,
                      isNumeric: true,
                      validator: (value) => value!.isEmpty ? "Requerido" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _currentInstallmentController,
                      label: "Cuota",
                      icon: Icons.tag,
                      isNumeric: true,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "/",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _totalInstallmentsController,
                      label: "Total Cuotas",
                      icon: Icons.layers,
                      isNumeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Consumer<MovementProvider>(
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _periodController,
                label: "Período de Facturación (Mes/Año)",
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () => _selectPeriod(context),
                validator: (value) =>
                    value!.isEmpty ? "Selecciona un período" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
    bool isNumeric = false,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
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
            return "Ingresa un número válido";
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
        quantity: int.parse(_qtyController.text),
        amount: int.parse(_amountController.text),
        currentInstallment: int.parse(_currentInstallmentController.text),
        totalInstallments: int.parse(_totalInstallmentsController.text),
        paymentMethodId: _selectedPaymentMethod!,
        billingPeriodYear: _selectedDate.year,
        billingPeriodMonth: _selectedDate.month,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await context.read<MovementProvider>().createMovement(movement);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimiento guardado con éxito')),
      );

      _formKey.currentState!.reset();
      _currentInstallmentController.clear();
      _totalInstallmentsController.clear();

      setState(() {
        _selectedCategory = null;
        _selectedPaymentMethod = null;
      });
    }
  }
}
