import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/billing_period_utils.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/shared/helpers/ui_helper.dart';
import 'package:cashify/features/transaction/domain/entities/movement_entity.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/category_dropdown_field.dart';
import 'package:cashify/features/transaction/presentation/widgets/custom_text_field.dart';
import 'package:cashify/features/transaction/presentation/widgets/month_year_picker.dart';
import 'package:cashify/features/transaction/presentation/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovementFormScreen extends StatefulWidget {
  final MovementEntity? movement;

  const MovementFormScreen({super.key, this.movement});

  @override
  State<MovementFormScreen> createState() => _MovementFormScreenState();
}

class _MovementFormScreenState extends State<MovementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _createdAt = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  bool _isCompleted = true;
  bool isEditing = false;
  bool isCopying = false;
  String? _originalBillingPeriodId;

  final _idController = TextEditingController();
  final _groupIdController = TextEditingController();
  final _userIdController = TextEditingController();
  final _descController = TextEditingController();
  final _sourceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _amountController = TextEditingController();
  final _currentInstallmentController = TextEditingController();
  final _totalInstallmentsController = TextEditingController();
  final _billingPeriodController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDefaults();

    if (widget.movement != null) {
      isEditing = widget.movement!.id.isNotEmpty;
      isCopying = widget.movement!.id.isEmpty;

      _idController.text = isEditing ? widget.movement!.id : '';
      _groupIdController.text = isEditing ? widget.movement!.groupId : '';
      _userIdController.text = isEditing ? widget.movement!.userId : '';
      _selectedCategory = widget.movement!.categoryId;
      _descController.text = widget.movement!.description;
      _sourceController.text = widget.movement!.source;
      _qtyController.text = widget.movement!.quantity.toString();
      _amountController.text = widget.movement!.amount.toString();
      _currentInstallmentController.text = widget.movement!.currentInstallment
          .toString();
      _totalInstallmentsController.text = widget.movement!.totalInstallments
          .toString();
      _selectedPaymentMethod = widget.movement!.paymentMethodId;
      /* TODO: Handle billing period value on screen */
      _billingPeriodController.text = widget.movement!.billingPeriodId;
      _notesController.text = (widget.movement!.notes ?? '');
      _isCompleted = widget.movement!.isCompleted;
      _createdAt = widget.movement!.createdAt;
      _originalBillingPeriodId = widget.movement!.billingPeriodId;
      _selectedDate = BillingPeriodUtils.getDateFromId(
        widget.movement!.billingPeriodId,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProv = context.read<SettingsProvider>();
      final currentId = BillingPeriodUtils.generateId(
        DateTime.now(),
        settingsProv.settings.startDay,
      );
      context.read<MovementProvider>().loadDataByBillingPeriod(currentId);
    });
  }

  void _initializeDefaults() {
    _updateBillingPeriodTextField(_selectedDate);
    _currentInstallmentController.text = "1";
    _totalInstallmentsController.text = "1";
    _qtyController.text = "1";
  }

  void _updateBillingPeriodTextField(DateTime date) {
    final periodProv = context.read<BillingPeriodProvider>();
    final settingsProv = context.read<SettingsProvider>();

    final id = BillingPeriodUtils.generateId(
      date,
      settingsProv.settings.startDay,
    );
    _billingPeriodController.text = periodProv.formatId(id);
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
      _billingPeriodController,
      _notesController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<MovementProvider>(
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
                          provider: provider,
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
                        _buildMoneySection(),
                        const SizedBox(height: 15),
                        _buildInstallmentsSection(),
                        const SizedBox(height: 15),
                        _buildPaymentMethodDropdown(provider),
                        const SizedBox(height: 15),
                        CustomTextField(
                          controller: _billingPeriodController,
                          label: "Asignar a Período",
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: isEditing
                              ? null
                              : () => _selectPeriod(context),
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
                        _buildStatusSwitch(),
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

  Widget _buildMoneySection() {
    return Row(
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
    );
  }

  Widget _buildInstallmentsSection() {
    return Row(
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildPaymentMethodDropdown(MovementProvider provider) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 25,
          child: Container(
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
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: _selectedPaymentMethod,
          decoration: _inputStyle("Método de Pago", Icons.payment),
          items: provider.paymentMethods
              .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
              .toList(),
          onChanged: (val) => setState(() => _selectedPaymentMethod = val),
          validator: (v) => v == null ? "Requerido" : null,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: AppColors.surface,
        ),
      ],
    );
  }

  Widget _buildStatusSwitch() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _isCompleted
            ? AppColors.success.withAlpha(20)
            : AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow.withValues(alpha: 0.05))],
      ),
      child: SwitchListTile(
        activeThumbColor: AppColors.success,
        title: Text(
          _isCompleted ? "Movimiento Completado" : "Movimiento Pendiente",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isCompleted ? AppColors.success : AppColors.warning,
          ),
        ),
        secondary: Icon(
          _isCompleted ? Icons.check_circle : Icons.pending_actions,
          color: _isCompleted ? AppColors.success : AppColors.warning,
        ),
        value: _isCompleted,
        onChanged: (bool value) => setState(() => _isCompleted = value),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: false,
      helperText: ' ',
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        onDateSelected: (DateTime newDate) {
          setState(() {
            _selectedDate = newDate;
            _updateBillingPeriodTextField(newDate);
          });
        },
      ),
    );
  }

  void _save(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final settingsProv = context.read<SettingsProvider>();
      final periodProv = context.read<BillingPeriodProvider>();
      final movementProv = context.read<MovementProvider>();
      final movement = _createMovementEntity(periodProv, settingsProv);

      try {
        final currentViewId =
            periodProv.selectedPeriodId ??
            BillingPeriodUtils.generateId(
              DateTime.now(),
              settingsProv.settings.startDay,
            );

        if (isEditing) {
          await movementProv.updateMovement(movement);
          if (context.mounted) {
            context.showSuccessSnackBar("Movimiento actualizado");
          }
        } else {
          await movementProv.createMovement(
            movement,
            currentViewId,
            settingsProv.settings.startDay,
            () async {
              try {
                await periodProv.loadPeriods();
              } catch (e) {
                if (!context.mounted) return;
                context.showErrorSnackBar("Error al cargar periodos: $e");
              }
            },
          );
          if (context.mounted) {
            context.showSuccessSnackBar("Movimiento guardado correctamente");
          }
        }

        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        context.showErrorSnackBar('Error saving movement: $e');
      }
    }
  }

  MovementEntity _createMovementEntity(
    BillingPeriodProvider periodProv,
    SettingsProvider settingsProv,
  ) {
    final String calculatedId = isEditing
        ? _originalBillingPeriodId!
        : BillingPeriodUtils.generateId(
            _selectedDate,
            settingsProv.settings.startDay,
          );

    return MovementEntity(
      id: _idController.text,
      userId: _userIdController.text,
      groupId: _groupIdController.text,
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
      billingPeriodId: calculatedId,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      isCompleted: _isCompleted,
      createdAt: isEditing ? _createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
