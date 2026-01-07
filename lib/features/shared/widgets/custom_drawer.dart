import 'package:cashify/core/auth/auth_service.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/transaction/presentation/pages/movement_form_screen.dart';
import 'package:cashify/features/transaction/presentation/pages/pending_movements_screen.dart';
import 'package:cashify/features/transaction/presentation/providers/movement_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "Usuario";
    final String email = user?.email ?? "Sin correo registrado";
    final bool hasValidPhoto =
        user?.photoURL != null && user!.photoURL!.isNotEmpty;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF512DA8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.background,
              backgroundImage: hasValidPhoto
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: !hasValidPhoto
                  ? Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    )
                  : null,
            ),
            accountName: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                const Divider(
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.divider,
                ),
                Consumer<MovementProvider>(
                  builder: (context, provider, child) {
                    final pendingCount = provider.movements
                        .where((m) => !m.isCompleted)
                        .length;

                    return Column(
                      children: [
                        _DrawerItem(
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
                              MaterialPageRoute(
                                builder: (_) => const PendingMovementsScreen(),
                              ),
                            );
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.credit_card_outlined,
                          label: "Cuotas Restantes",
                          iconColor: AppColors.warning,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider),
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
          fontWeight: (textColor != null || iconColor == AppColors.warning)
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
