import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showShareDialog(BuildContext context,
    {required bool isAdmin, String? shareUrlA, String? shareUrlB}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      bool copyMemberDone = false;
      bool copyAdminDone = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(
                24, 12, 24, MediaQuery.of(context).padding.bottom + 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Row(
                  children: [
                    // Connect logo icon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.purple, AppColors.purpleLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(Icons.hub_outlined,
                          color: AppColors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Share Invite', style: AppTypography.headingMedium),
                          Text('Invite people to your community',
                              style: AppTypography.caption),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 16, color: AppColors.textMid),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Member Access Section
                _ShareSection(
                  label: 'MEMBER ACCESS',
                  icon: Icons.people_outline_rounded,
                  iconColor: AppColors.purple,
                  iconBg: AppColors.purpleTint,
                  title: 'Member Link',
                  subtitle: 'Anyone with this link joins as a member',
                  copyDone: copyMemberDone,
                  onCopy: () async {
                    if (shareUrlB == null) return;
                    await Clipboard.setData(ClipboardData(text: shareUrlB));
                    setState(() => copyMemberDone = true);
                  },
                  onShare: () async {
                    if (shareUrlB == null) return;
                    final uri = Uri.parse(shareUrlB);
                    await SharePlus.instance
                        .share(ShareParams(uri: uri))
                        .then((_) {
                      if (context.mounted) Navigator.pop(context);
                    });
                  },
                ),

                if (isAdmin) ...[
                  const SizedBox(height: 12),

                  // Admin Access Section
                  _ShareSection(
                    label: 'ADMIN ACCESS',
                    icon: Icons.admin_panel_settings_outlined,
                    iconColor: AppColors.orange,
                    iconBg: AppColors.orangeTint,
                    title: 'Admin Link',
                    subtitle: 'Only share this with trusted admins',
                    copyDone: copyAdminDone,
                    onCopy: () async {
                      if (shareUrlA == null) return;
                      await Clipboard.setData(ClipboardData(text: shareUrlA));
                      setState(() => copyAdminDone = true);
                    },
                    onShare: () async {
                      if (shareUrlA == null) return;
                      final uri = Uri.parse(shareUrlA);
                      await SharePlus.instance
                          .share(ShareParams(uri: uri))
                          .then((_) {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

class _ShareSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool copyDone;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _ShareSection({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.copyDone,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(label,
              style: AppTypography.fieldLabel.copyWith(
                color: AppColors.textMuted,
              )),
          const SizedBox(height: 10),

          // Icon + title
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.cardTitle),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: copyDone
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.purpleTint,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      border: Border.all(
                        color: copyDone
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.purpleBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          copyDone
                              ? Icons.check_rounded
                              : Icons.copy_rounded,
                          size: 14,
                          color: copyDone ? AppColors.success : AppColors.purple,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          copyDone ? 'Copied!' : 'Copy link',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: copyDone
                                ? AppColors.success
                                : AppColors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded,
                            size: 14, color: AppColors.white),
                        const SizedBox(width: 6),
                        Text('Share via...',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
