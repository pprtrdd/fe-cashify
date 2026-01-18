import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/configuration/domain/entities/user_settings_entity.dart';
import 'package:cashify/features/configuration/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Configuración"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _SettingsForm(settings: provider.settings);
        },
      ),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  final UserSettingsEntity settings;

  const _SettingsForm({required this.settings});

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  late String _billingPeriodType;
  late TextEditingController _startDayController;
  late TextEditingController _endDayController;

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
          const _SectionHeader(
            title: "FINANZAS Y FACTURACIÓN",
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _buildMainCard(),
          const SizedBox(height: 32),
          _SaveButton(onPressed: _handleSave),
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
            Text(
              "Ejemplo: Si tu tarjeta corta el 24, inicia el 24 y termina el 23.",
              style: TextStyle(fontSize: 11, color: AppColors.textFaded),
            ),
          ] else ...[
            Text(
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
        labelStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
    final start = int.tryParse(_startDayController.text) ?? 1;
    final end = int.tryParse(_endDayController.text) ?? 31;

    if (_billingPeriodType == 'custom_range') {
      if (start < 1 || start > 31 || end < 1 || end > 31) {
        _showError("Los días deben estar entre 1 y 31");
        return;
      }
      if (start == end) {
        _showError("El día de inicio y fin no pueden ser iguales");
        return;
      }
    }

    final newSettings = UserSettingsEntity(
      billingPeriodType: _billingPeriodType,
      startDay: _billingPeriodType == 'month_to_month' ? 1 : start,
      endDay: _billingPeriodType == 'month_to_month' ? 31 : end,
    );

    try {
      await context.read<SettingsProvider>().updateSettings(newSettings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Configuración actualizada")),
        );
      }
    } catch (e) {
      _showError("Error al guardar: $e");
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: color),
          const SizedBox(width: 8),
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

  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text(
        "GUARDAR CAMBIOS",
        style: TextStyle(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
