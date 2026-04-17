import 'package:flutter/material.dart';
import 'package:master/classes/church_init.dart';
import 'package:master/constants/constants.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';

// ─── Connect App logo icon (purple rounded square) ────────────────────────────
Widget _connectLogo({double size = 44}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple, AppColors.purpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.hub_outlined, color: AppColors.white, size: size * 0.45),
    );

// ─── Shared dialog shell ──────────────────────────────────────────────────────
Future<T?> _showConnectDialog<T>({
  required BuildContext context,
  required String message,
  required List<Widget> actions,
  Widget? icon,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusBottomSheet),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? _connectLogo(),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyText.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ...actions,
          ],
        ),
      ),
    ),
  );
}

// ─── _ActionButton helper ─────────────────────────────────────────────────────
Widget _actionButton({
  required BuildContext context,
  required String label,
  required VoidCallback onPressed,
  Color? color,
}) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.purple,
          foregroundColor: AppColors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 0,
        ),
        child: Text(label, style: AppTypography.buttonPrimary),
      ),
    );

// ─── Public alert functions ───────────────────────────────────────────────────

Future<bool?> alertReturn(BuildContext context, String message) {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    icon: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.error_outline_rounded,
          color: AppColors.error, size: 24),
    ),
    actions: [
      _actionButton(
        context: context,
        label: 'OK',
        onPressed: () => Navigator.pop(context),
        color: AppColors.purple,
      ),
    ],
  );
}

Future<bool?> alertWelcome(BuildContext context, String message) {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    actions: [
      _actionButton(
        context: context,
        label: 'Enter',
        onPressed: () => Navigator.pop(context),
        color: AppColors.orange,
      ),
    ],
  );
}

Future<bool?> alertDeleteMessage(BuildContext context, String message,
    Future<void> Function() delete) async {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    icon: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.delete_outline_rounded,
          color: AppColors.error, size: 24),
    ),
    actions: [
      _actionButton(
        context: context,
        label: 'Delete',
        onPressed: () async {
          await delete();
          if (context.mounted) Navigator.of(context).pop();
        },
        color: AppColors.error,
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTypography.link),
        ),
      ),
    ],
  );
}

Future<bool?> alertDelete(BuildContext context, String message,
    Future<void> Function() delete) async {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    icon: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.delete_outline_rounded,
          color: AppColors.error, size: 24),
    ),
    actions: [
      _actionButton(
        context: context,
        label: 'Delete',
        onPressed: () async {
          await delete();
          if (context.mounted) Navigator.of(context).pop();
        },
        color: AppColors.error,
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTypography.link),
        ),
      ),
    ],
  );
}

Future<bool?> alertComplete(BuildContext context, String message) {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    actions: [
      _actionButton(
        context: context,
        label: 'Done',
        onPressed: () => Navigator.pop(context),
        color: AppColors.purple,
      ),
    ],
  );
}

Future<bool?> alertSuccess(BuildContext context, String message) {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    icon: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.check_circle_outline_rounded,
          color: AppColors.success, size: 24),
    ),
    actions: [
      _actionButton(
        context: context,
        label: 'Great',
        onPressed: () => Navigator.pop(context),
        color: AppColors.success,
      ),
    ],
  );
}

Future<bool?> alertLogout(BuildContext context, String message) async {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    icon: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
    ),
    actions: [
      _actionButton(
        context: context,
        label: 'Log out',
        onPressed: () async {
          ChurchInit church = ChurchInit();
          Navigator.of(context).pop();
          await church.clearProject(context);
          Future.delayed(const Duration(seconds: 3), () {});
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed(RoutePaths.crossRoad);
          }
        },
        color: AppColors.error,
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTypography.link),
        ),
      ),
    ],
  );
}

Future<bool?> alertInstall(BuildContext context, String message,
    Future<void> Function() install,
    Future<void> Function() alreadyInstall) async {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    actions: [
      _actionButton(
        context: context,
        label: 'Install',
        onPressed: () async {
          await install();
          if (context.mounted) Navigator.of(context).pop();
        },
        color: AppColors.purple,
      ),
      const SizedBox(height: 8),
      _actionButton(
        context: context,
        label: 'Already installed',
        onPressed: () async {
          await alreadyInstall();
          if (context.mounted) Navigator.of(context).pop();
        },
        color: AppColors.orange,
      ),
    ],
  );
}

Future<bool?> alertIos(BuildContext context, String message,
    Future<void> Function() clear) async {
  return _showConnectDialog<bool>(
    context: context,
    message: message,
    actions: [
      _actionButton(
        context: context,
        label: 'OK',
        onPressed: () async {
          await clear();
          if (context.mounted) Navigator.of(context).pop();
        },
        color: AppColors.purple,
      ),
    ],
  );
}
