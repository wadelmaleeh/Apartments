import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../main.dart';
import '../localization/app_localizations.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void _showLogoutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.logout),
        content: Text(loc.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(loc.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showLogoutDialog(context),
      tooltip: AppLocalizations.of(context).logout,
      icon: const Icon(Icons.power_settings_new_rounded, size: 22),
      color: AppColors.danger,
    );
  }
}
