import 'package:cashify/core/config/constants/config_constants.dart';
import 'package:cashify/core/config/services/config_service.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/settings/presentation/pages/billing_period_setting_screen.dart';
import 'package:cashify/features/shared/helpers/launcher_helper.dart';
import 'package:cashify/features/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Configuración"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          const SectionHeader(
            title: "CONFIGURACIÓN DE CUENTA",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.calendar_month_outlined,
            title: "Período de Facturación",
            subtitle: "Define el ciclo mensual de tus cuentas",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BillingSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const SectionHeader(title: "APLICACIÓN", icon: Icons.info_outline),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: "Acerca de",
            subtitle: "Versión, autor y detalles legales",
            onTap: () => _mostrarAcercaDe(context),
          ),
        ],
      ),
    );
  }

  void _mostrarAcercaDe(BuildContext context) async {
    final info = await AppConfigService.getAppVersion();

    if (!context.mounted) return;

    showAboutDialog(
      context: context,
      applicationName: ConfigConstants.appName,
      applicationVersion: '${info['version']}+${info['buildNumber']}',
      applicationIcon: const Icon(
        Icons.account_balance_wallet,
        size: 40,
        color: AppColors.primary,
      ),
      applicationLegalese: ConfigConstants.copyright,
      children: [
        const SizedBox(height: 15),
        Text(ConfigConstants.description),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
        Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            hoverColor: const Color(
              0xFF24292E,
            ).withValues(alpha: 0.1),
            onTap: () =>
                LauncherHelper.openUrl(ConfigConstants.githubProfile),
            child: const ListTile(
              leading: Icon(Icons.code, color: Color(0xFF24292E)),
              title: Text(
                'GitHub',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Ver código fuente'),
              trailing: Icon(Icons.open_in_new, size: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            hoverColor: const Color(
              0xFF0077B5,
            ).withValues(alpha: 0.1),
            onTap: () =>
                LauncherHelper.openUrl(ConfigConstants.linkedinProfile),
            child: const ListTile(
              leading: Icon(Icons.link, color: Color(0xFF0077B5)),
              title: Text(
                'LinkedIn',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Conectar con el autor'),
              trailing: Icon(Icons.open_in_new, size: 16),
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Hecho con Flutter Web',
            style: TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textFaded),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textFaded),
        onTap: onTap,
      ),
    );
  }
}
