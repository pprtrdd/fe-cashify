import 'package:cashify/core/theme/app_colors.dart';
import 'package:cashify/features/settings/presentation/pages/billing_period_setting_form_screen.dart';
import 'package:cashify/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillingSettingsScreen extends StatelessWidget {
  const BillingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Período de Facturación"), elevation: 0),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return BillingPeriodSettingForm(settings: provider.settings);
        },
      ),
    );
  }
}
