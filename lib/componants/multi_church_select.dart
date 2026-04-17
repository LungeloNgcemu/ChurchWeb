import 'package:flutter/material.dart';
import 'package:master/Model/existing_user_model.dart';
import 'package:master/services/api/auth_service.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/widgets/common/connect_button.dart';
import 'package:master/widgets/common/connect_text_field.dart';

Future<ExistingUser?> showChurchSelectDialog(
  BuildContext context,
  List<ExistingUser> users,
  Function(ExistingUser) onSelected,
) {
  return showDialog<ExistingUser>(
    context: context,
    barrierDismissible: true,
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
            // Connect logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.purpleLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.hub_outlined,
                  color: AppColors.white, size: 24),
            ),
            const SizedBox(height: 14),
            Text('Choose Organisation',
                style: AppTypography.headingSmall),
            const SizedBox(height: 4),
            Text('Select your organisation to continue',
                style: AppTypography.caption,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),

            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: users.length,
                separatorBuilder: (_, __) => Divider(
                    color: AppColors.surfaceAlt, height: 1),
                itemBuilder: (_, i) {
                  final user = users[i];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.purple, AppColors.purpleLight],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          (user.churchName ?? 'O')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: AppTypography.cardTitle
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                    title: Text(
                      user.churchName ?? 'Unknown Organisation',
                      style: AppTypography.cardTitle,
                    ),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted, size: 18),
                    onTap: () => onSelected(user),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ConnectButton.ghost(
              label: 'Cancel',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool?> showAdminDialog(
  BuildContext context,
  TextEditingController controllerCode,
  String uniqueChurchId,
) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      bool hasError = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusBottomSheet),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Connect logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.purple, AppColors.purpleLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.lock_outline_rounded,
                        color: AppColors.white, size: 22),
                  ),
                  const SizedBox(height: 14),
                  Text('Admin Verification',
                      style: AppTypography.headingSmall),
                  const SizedBox(height: 4),
                  Text('Enter the admin password to continue',
                      style: AppTypography.caption,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),

                  ConnectTextField(
                    label: 'Password',
                    placeholder: 'Enter password',
                    controller: controllerCode,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    errorText: hasError ? 'Password is required' : null,
                    leadingIcon: Icon(Icons.lock_outline_rounded,
                        color: AppColors.purple, size: 16),
                  ),
                  const SizedBox(height: 20),

                  ConnectButton.purple(
                    label: 'Confirm',
                    onTap: () async {
                      if (controllerCode.text.isEmpty) {
                        setState(() => hasError = true);
                        return;
                      }
                      final isValid = await AuthService.checkPassword(
                          controllerCode.text, uniqueChurchId);
                      if (context.mounted) {
                        Navigator.pop(context, isValid);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  ConnectButton.ghost(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
