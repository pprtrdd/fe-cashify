import 'package:cashify/core/auth/auth_service.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/utils/billing_period_utils.dart';
import 'package:cashify/features/settings/presentation/pages/settings_screen.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:cashify/features/transaction/presentation/pages/categories_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/frequent_movements_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/movements_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/pending_movements_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/billing_period_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/frequent_movement_provider.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:cashify/features/transaction/presentation/widgets/month_year_picker.dart';
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
          const _PeriodSelector(),
          const Divider(indent: 20, endIndent: 20, color: AppColors.divider),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _MovementsItem(),
                const _PendingMovementsItem(),
                const _FrequentItem(),
                const _CategoriesItem(),
              ],
            ),
          ),
          const Divider(color: AppColors.divider),
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: "Configuración",
            iconColor: AppColors.textLight,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
              if (!context.mounted) return;
              Navigator.pop(context);
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

    final String realCurrentId = BillingPeriodUtils.generateId(
      DateTime.now(),
      settingsProv.settings.startDay,
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
      decoration: BoxDecoration(
        color: AppColors.primary,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
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
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            email,
            style: TextStyle(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppColors.textOnPrimary.withValues(alpha: 0.2),
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppColors.textOnPrimary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CICLO ACTUAL EN CURSO",
                    style: TextStyle(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$realMonthName ($realDateRangeStr)",
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
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

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector();

  void _showPicker(
    BuildContext context,
    BillingPeriodProvider periodProv,
    SettingsProvider settingsProv,
  ) {
    final DateTime initialDate = BillingPeriodUtils.getDateFromId(
      periodProv.selectedPeriodId,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => MonthYearPickerSheet(
        initialDate: initialDate,
        onDateSelected: (DateTime selectedDate) {
          final String newId = BillingPeriodUtils.generateId(
            selectedDate,
            settingsProv.settings.startDay,
          );

          periodProv.selectPeriod(newId);

          Provider.of<MovementProvider>(
            context,
            listen: false,
          ).loadDataByBillingPeriod(newId);

          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodProv = context.watch<BillingPeriodProvider>();
    final settingsProv = context.watch<SettingsProvider>();

    final activeViewId = periodProv.selectedPeriodId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: InkWell(
        onTap: () => _showPicker(context, periodProv, settingsProv),
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
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
            fillColor: AppColors.primary.withValues(alpha: 0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(
              Icons.remove_red_eye_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          child: Text(
            periodProv.formatId(activeViewId),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _MovementsItem extends StatelessWidget {
  const _MovementsItem();

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementProvider>(
      builder: (context, provider, child) {
        return _DrawerItem(
          icon: Icons.history,
          label: "Historial",
          iconColor: AppColors.success,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MovementHistoryScreen()),
            );
          },
        );
      },
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

        // Solo aplicamos negrita si hay elementos pendientes
        final bool hasPending = pendingCount > 0;

        return _DrawerItem(
          icon: Icons.pending_actions,
          label: "Pendientes",
          isBold: hasPending, // Pasamos la condición
          iconColor: AppColors.warning,
          trailing: hasPending
              ? Badge(
                  backgroundColor: AppColors.notification,
                  label: Text(
                    '$pendingCount',
                    style: const TextStyle(color: AppColors.textOnPrimary),
                  ),
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

class _FrequentItem extends StatelessWidget {
  const _FrequentItem();

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      FrequentMovementProvider,
      BillingPeriodProvider,
      MovementProvider,
      SettingsProvider
    >(
      builder:
          (context, freqProv, periodProv, movementProv, settingsProv, child) {
            final pendingCount = freqProv
                .getPendingForBillingPeriod(
                  periodProv.selectedPeriodId,
                  settingsProv.settings.startDay,
                  movementProv.movements,
                  movementProv.lastLoadedBillingPeriodId,
                )
                .length;

            final bool hasPending = pendingCount > 0;

            return _DrawerItem(
              icon: Icons.auto_awesome,
              label: "Frecuentes",
              isBold: hasPending,
              iconColor: AppColors.primary,
              trailing: hasPending
                  ? Badge(
                      backgroundColor: AppColors.notification,
                      label: Text(
                        '$pendingCount',
                        style: const TextStyle(color: AppColors.textOnPrimary),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FrequentMovementsScreen(),
                  ),
                );
              },
            );
          },
    );
  }
}

class _CategoriesItem extends StatelessWidget {
  const _CategoriesItem();

  @override
  Widget build(BuildContext context) {
    return _DrawerItem(
      icon: Icons.category_outlined,
      label: "Categorías",
      iconColor: AppColors.primary,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
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
  final bool? isBold; // Nueva propiedad opcional

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.trailing,
    this.isBold, // Inicializada aquí
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
          fontWeight: isBold == true ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }
}
