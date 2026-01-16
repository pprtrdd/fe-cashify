import 'package:cashify/core/auth/auth_service.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/configuration/presentation/pages/settings_screen.dart';
import 'package:cashify/features/configuration/presentation/providers/settings_provider.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/pending_movements_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          const _UserHeader(),
          const _PeriodDropdown(),
          const Divider(indent: 20, endIndent: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.add_circle_outline,
                  label: "Nuevo Movimiento",
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MovementFormScreen(),
                      ),
                    );
                  },
                ),
                const _PendingMovementsItem(),
              ],
            ),
          ),
          const Divider(color: AppColors.divider),
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: "Configuración",
            iconColor: AppColors.textPrimary.withValues(alpha: 180),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          _DrawerItem(
            icon: Icons.logout_rounded,
            label: "Cerrar Sesión",
            textColor: AppColors.danger,
            iconColor: AppColors.danger,
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "Usuario";
    final String email = user?.email ?? "Sin correo registrado";
    final bool hasValidPhoto =
        user?.photoURL != null && user!.photoURL!.isNotEmpty;

    final periodProv = context.watch<BillingPeriodProvider>();
    final settingsProv = context.watch<SettingsProvider>();

    final String realCurrentId = periodProv.getCurrentBillingPeriodId(
      settingsProv.settings,
    );
    final realRange = periodProv.getRangeFromId(
      realCurrentId,
      settingsProv.settings.startDay,
    );

    final String realMonthName = periodProv.formatId(realCurrentId);
    final String realDateRangeStr =
        "${realRange.start.day}/${realRange.start.month} al ${realRange.end.day}/${realRange.end.month}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF512DA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.background,
            backgroundImage: hasValidPhoto
                ? NetworkImage(user.photoURL!)
                : null,
            child: !hasValidPhoto
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            email,
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CICLO ACTUAL EN CURSO",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$realMonthName ($realDateRangeStr)",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown();

  @override
  Widget build(BuildContext context) {
    final periodProv = context.watch<BillingPeriodProvider>();
    final settingsProv = context.watch<SettingsProvider>();

    final String realCurrentId = periodProv.getCurrentBillingPeriodId(
      settingsProv.settings,
    );
    final activeViewId = periodProv.selectedPeriodId ?? realCurrentId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: DropdownButtonFormField<String>(
        initialValue: periodProv.periods.contains(activeViewId)
            ? activeViewId
            : null,
        decoration: InputDecoration(
          labelText: "ESTÁS VIENDO",
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          filled: true,
          fillColor: AppColors.primary.withAlpha(15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.remove_red_eye_outlined,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        items: periodProv.periods.map((String id) {
          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              periodProv.formatId(id),
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            periodProv.selectPeriod(newValue);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _PendingMovementsItem extends StatelessWidget {
  const _PendingMovementsItem();

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementProvider>(
      builder: (context, provider, child) {
        final pendingCount = provider.movements
            .where((m) => !m.isCompleted)
            .length;
        return _DrawerItem(
          icon: Icons.pending_actions,
          label: "Movimientos Pendientes",
          iconColor: AppColors.warning,
          trailing: pendingCount > 0
              ? Badge(
                  backgroundColor: AppColors.notification,
                  label: Text('$pendingCount'),
                )
              : null,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PendingMovementsScreen()),
            );
          },
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontSize: 15,
          fontWeight:
              (textColor != null ||
                  iconColor == AppColors.primary ||
                  iconColor == AppColors.warning)
              ? FontWeight.bold
              : FontWeight.w500,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }
}
