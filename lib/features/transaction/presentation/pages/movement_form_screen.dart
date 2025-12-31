import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MovementFormScreen extends StatefulWidget {
  const MovementFormScreen({super.key});

  @override
  State<MovementFormScreen> createState() => _MovementFormScreenState();
}

final Map<String, String> _paymentOptions = {
  'Efectivo': 'CASH',
  'Débito': 'DEBIT',
  'Crédito': 'CREDIT',
};
String? _selectedPaymentMethod;

class _MovementFormScreenState extends State<MovementFormScreen> {
  DateTime _selectedDate = DateTime.now(); // Fecha inicial

  final _formKey = GlobalKey<FormState>();

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

    _periodController.text =
        "${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";
    _currentInstallmentController.text = "1";
    _totalInstallmentsController.text = "1";
  }

  @override
  void dispose() {
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

  void _save(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final movement = MovementEntity(
        description: _descController.text,
        source: _sourceController.text,
        quantity: _qtyController.text,
        amount: _amountController.text,
        currentInstallment: _currentInstallmentController.text,
        totalInstallments: _totalInstallmentsController.text,
        paymentMethod: _selectedPaymentMethod ?? 'CASH',
        billingPeriod: _periodController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await context.read<MovementProvider>().createMovement(movement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento guardado con éxito')),
        );
        _formKey.currentState!.reset();
      }

      _formKey.currentState!.reset();
      _currentInstallmentController.clear();
      _totalInstallmentsController.clear();
      setState(() {
        _selectedPaymentMethod = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovementProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Movimiento"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: "Método de Pago",
                  prefixIcon: const Icon(Icons.payment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _paymentOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    /* CASH, DEBIT, CREDIT */
                    child: Text(entry.key) /* Efectivo, Débito, Crédito */,
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Selecciona un método" : null,
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
  bool isRequired = true, // <--- Agregamos este parámetro con valor por defecto true
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
    // --- LÓGICA DE VALIDACIÓN ACTUALIZADA ---
    validator: (value) {
      if (!isRequired && (value == null || value.isEmpty)) return null;
      if (isRequired && (value == null || value.isEmpty)) return "Campo requerido";
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
}
