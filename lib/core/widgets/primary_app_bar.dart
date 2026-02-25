import 'package:cashify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onAddPressed;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showAddButton;

  const PrimaryAppBar({
    super.key,
    required this.title,
    this.onAddPressed,
    this.actions,
    this.leading,
    this.showAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      leading: leading,
      actions: [
        if (actions != null) ...actions!,
        if (showAddButton && onAddPressed != null)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAddPressed,
          ),
        if (actions == null && !showAddButton) const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
