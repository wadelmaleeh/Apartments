import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({
    super.key,
    required this.message,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String message,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(
        Icons.delete_outline_rounded,
        size: 48,
        color: theme.colorScheme.error,
      ),
      title: Text(loc.delete),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(loc.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          onPressed: () {
            onConfirm();
            Navigator.pop(context, true);
          },
          child: Text(loc.delete),
        ),
      ],
    );
  }
}
