import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/settings/domain/entities/user_settings_entity.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/shared/helpers/ui_helper.dart';
import 'package:cashify/features/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BillingPeriodSettingForm extends StatefulWidget {
  final UserSettingsEntity settings;

  const BillingPeriodSettingForm({super.key, required this.settings});

  @override
  State<BillingPeriodSettingForm> createState() =>
      BillingPeriodSettingFormState();
}

class BillingPeriodSettingFormState extends State<BillingPeriodSettingForm> {
  late String _billingPeriodType;
  late TextEditingController _startDayController;
  late TextEditingController _endDayController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _billingPeriodType = widget.settings.billingPeriodType;
    _startDayController = TextEditingController(
      text: widget.settings.startDay.toString(),
    );
    _endDayController = TextEditingController(
      text: widget.settings.endDay.toString(),
    );
  }

  @override
  void dispose() {
    _startDayController.dispose();
    _endDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: "FINANZAS Y FACTURACIÓN",
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _buildMainCard(),
          const SizedBox(height: 32),
          _SaveButton(onPressed: _handleSave, isSaving: _isSaving),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tipo de Período",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildPeriodToggle(),
          const SizedBox(height: 24),
          if (_billingPeriodType == 'custom_range') ...[
            const Text(
              "Rango de Fechas",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDayInput("Inicio", _startDayController)),
                const SizedBox(width: 12),
                Expanded(child: _buildDayInput("Fin", _endDayController)),
              ],
            ),
            _buildPeriodPreview(),
            const SizedBox(height: 8),
            const Text(
              "Ejemplo: Si tu tarjeta corta el 24, inicia el 24 y termina el 23.",
              style: TextStyle(fontSize: 11, color: AppColors.textFaded),
            ),
          ] else ...[
            const Text(
              "Los movimientos se agruparán automáticamente por mes calendario (del 1 al 30/31).",
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleButton("Mes Calendario", 'month_to_month'),
          _buildToggleButton("Personalizado", 'custom_range'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value) {
    final bool isSelected = _billingPeriodType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _billingPeriodType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.transparent,
            borderRadius: BorderRadius.circular(10),
            // Sombra sutil solo si está seleccionado
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.textOnPrimary : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      onChanged: (value) {
        setState(() {
          final num = int.tryParse(value) ?? 0;
          if (num > 31) {
            controller.text = '31';
            controller.selection = TextSelection.fromPosition(
              const TextPosition(offset: 2),
            );
          }
        });
      },
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _handleSave() async {
    final start = int.tryParse(_startDayController.text) ?? 1;
    final end = int.tryParse(_endDayController.text) ?? 31;

    if (_billingPeriodType == 'custom_range') {
      if (start < 1 || start > 31 || end < 1 || end > 31) {
        context.showErrorSnackBar("Los días deben estar entre 1 y 31");
        return;
      }
      if (start == end) {
        context.showErrorSnackBar(
          "El día de inicio y fin no pueden ser iguales",
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    final newSettings = UserSettingsEntity(
      billingPeriodType: _billingPeriodType,
      startDay: _billingPeriodType == 'month_to_month' ? 1 : start,
      endDay: _billingPeriodType == 'month_to_month' ? 31 : end,
    );

    try {
      await context.read<SettingsProvider>().updateSettings(newSettings);
      if (!mounted) return;
      context.showSuccessSnackBar("Configuración actualizada");
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar("Error al guardar: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildPeriodPreview() {
    if (_billingPeriodType == 'month_to_month') return const SizedBox.shrink();

    final startDay = int.tryParse(_startDayController.text) ?? 1;
    final endDay = int.tryParse(_endDayController.text) ?? 31;

    if (startDay < 1 || startDay > 31 || endDay < 1 || endDay > 31) {
      return const _PreviewBox(
        text: "Días inválidos",
        color: AppColors.warning,
      );
    }

    final now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, startDay);
    if (now.day < startDay) {
      startDate = DateTime(now.year, now.month - 1, startDay);
    }
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, endDay);

    String startStr = "${startDate.day} ${_getLocalMonthName(startDate.month)}";
    String endStr = "${endDate.day} ${_getLocalMonthName(endDate.month)}";

    return _PreviewBox(
      text: "Tu periodo actual: $startStr al $endStr",
      color: AppColors.primary,
    );
  }

  String _getLocalMonthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[(month - 1) % 12];
  }
}

class _PreviewBox extends StatelessWidget {
  final String text;
  final Color color;

  const _PreviewBox({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15))],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSaving;

  const _SaveButton({required this.onPressed, this.isSaving = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.fieldFill,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      child: isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppColors.fieldFill,
                strokeWidth: 2,
              ),
            )
          : const Text(
              "GUARDAR CAMBIOS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }
}
