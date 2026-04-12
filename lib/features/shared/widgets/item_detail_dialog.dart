import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/shared/widgets/dialog_action_button.dart';
import 'package:flutter/material.dart';

/// Configuración del header del dialog de detalle.
class DialogHeader {
  final IconData icon;
  final Color color;
  final String? amount;
  final String title;
  final String? badgeText;
  final Widget? titleTrailing;

  const DialogHeader({
    required this.icon,
    required this.color,
    this.amount,
    required this.title,
    this.badgeText,
    this.titleTrailing,
  });
}

/// Configuración de una acción del dialog.
class DialogAction {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const DialogAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

/// Dialog genérico de detalle reutilizable para categorías, transacciones
/// y movimientos frecuentes.
class ItemDetailDialog extends StatelessWidget {
  final DialogHeader header;
  final List<Widget> detailSections;
  final List<DialogAction> actions;

  const ItemDetailDialog({
    super.key,
    required this.header,
    required this.detailSections,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              ...detailSections,
              const SizedBox(height: 32),
              _buildActions(context),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cerrar",
                  style: TextStyle(color: AppColors.textFaded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: header.color.withValues(alpha: 0.1),
          child: Icon(header.icon, color: header.color, size: 32),
        ),
        const SizedBox(height: 16),
        if (header.amount != null) ...[
          Text(
            header.amount!,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: header.color,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                header.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: header.amount != null ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (header.titleTrailing != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: header.titleTrailing!,
              ),
          ],
        ),
        if (header.badgeText != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: header.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              header.badgeText!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: header.color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions
          .map(
            (action) => DialogActionButton(
              icon: action.icon,
              label: action.label,
              color: action.color,
              onTap: action.onTap,
            ),
          )
          .toList(),
    );
  }
}
