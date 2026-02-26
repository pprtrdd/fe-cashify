import 'package:cashify/core/app_config/presentation/providers/app_config_provider.dart';
import 'package:cashify/core/app_config/services/app_config_service.dart';
import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/core/widgets/primary_app_bar.dart';
import 'package:cashify/features/settings/presentation/pages/billing_period_setting_screen.dart';
import 'package:cashify/features/shared/helpers/launcher_helper.dart';
import 'package:cashify/features/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        final prov = context.read<AppConfigProvider>();
        if (prov.appConfig.author.isEmpty) {
          prov.loadAppConfig();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(title: "Configuración"),
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
            onTap: () => _showAppConfig(context),
          ),
        ],
      ),
    );
  }

  void _showAppConfig(BuildContext context) async {
    final appConfigProv = context.read<AppConfigProvider>();

    if (appConfigProv.appConfig.author.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await appConfigProv.loadAppConfig();

      if (!context.mounted) return;

      Navigator.pop(context);
    }

    final info = await AppConfigService.getAppVersion();
    final data = appConfigProv.appConfig;

    if (!context.mounted) return;

    showAboutDialog(
      context: context,
      applicationName: data.appName,
      applicationVersion: '${info['version']}+${info['buildNumber']}',
      applicationIcon: const Icon(
        Icons.account_balance_wallet,
        size: 40,
        color: AppColors.primary,
      ),
      applicationLegalese: '© ${data.lastYearDeploy} ${data.author}',
      children: [
        const SizedBox(height: 15),
        Text(data.description),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
        _buildSocialLink(
          icon: Icons.code,
          title: 'GitHub',
          subtitle: 'Source code',
          color: AppColors.github,
          url: data.githubProfile,
        ),
        const SizedBox(height: 8),
        _buildSocialLink(
          icon: Icons.link,
          title: 'LinkedIn',
          subtitle: 'Connect with me',
          color: AppColors.linkedin,
          url: data.linkedinProfile,
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Made with Flutter Web',
            style: TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String url,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: color.withValues(alpha: 0.1),
        onTap: () => LauncherHelper.openUrl(url),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.open_in_new, size: 16),
        ),
      ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
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
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textFaded,
            ),
          ),
        ),
      ),
    );
  }
}
