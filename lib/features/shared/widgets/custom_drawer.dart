import 'package:cashify/core/auth/auth_service.dart';
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
    final String? photoUrl = user?.photoURL;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            accountName: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(email),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Consumer<MovementProvider>(
                  builder: (context, provider, child) {
                    final pendingCount = provider.movements
                        .where((m) => !m.isCompleted)
                        .length;

                    return _DrawerItem(
                      icon: Icons.pending_actions,
                      label: "Movimientos Pendientes",
                      trailing: pendingCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PendingMovementsScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.credit_card,
                  label: "Cuotas Faltantes",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                _DrawerItem(
                  icon: Icons.settings,
                  label: "Configuración",
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),
          _DrawerItem(
            icon: Icons.logout,
            label: "Cerrar Sesión",
            color: Colors.red,
            onTap: () async {
              await AuthService().signOut();

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing; // 1. Agrega esta línea

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.trailing, // 2. Agrega esta línea
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: trailing, // 3. Y agrega esta línea aquí
      onTap: onTap,
    );
  }
}
