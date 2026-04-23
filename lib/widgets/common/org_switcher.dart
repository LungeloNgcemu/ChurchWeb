import 'package:flutter/material.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/Model/user_org.dart';
import 'package:master/constants/constants.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/services/org_switch_service.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import 'package:master/widgets/common/connect_loader.dart';

/// Opens the organisation-switcher bottom sheet.
///
/// Usage:
///   showOrgSwitcher(context);
void showOrgSwitcher(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _OrgSwitcherSheet(),
  );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class _OrgSwitcherSheet extends StatefulWidget {
  const _OrgSwitcherSheet();

  @override
  State<_OrgSwitcherSheet> createState() => _OrgSwitcherSheetState();
}

class _OrgSwitcherSheetState extends State<_OrgSwitcherSheet> {
  TokenUser? _user;
  bool _loading = true;

  /// uniqueChurchId of the org currently being switched to (shows spinner).
  String? _switching;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await TokenService.tokenUser();
    if (mounted) setState(() { _user = user; _loading = false; });
  }

  Future<void> _switchTo(String uniqueChurchId) async {
    setState(() => _switching = uniqueChurchId);

    final ok = await OrgSwitchService.switchTo(
      uniqueChurchId: uniqueChurchId,
    );

    if (!mounted) return;

    if (ok) {
      // Navigate to the app shell and wipe the entire back stack.
      // ChurchScreen._initChurch() → HomeScreen._initChurch() will run fresh,
      // re-reading the new JWT and loading the new org's data.
      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutePaths.church,
        (route) => false,
      );
    } else {
      setState(() => _switching = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to switch organisation. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgs = _user?.organisations ?? [];
    final activeId = _user?.uniqueChurchId ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xl4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.purpleTint,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Text('My Organisations', style: AppTypography.headingSmall),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.surfaceAlt),

          // ── Content ─────────────────────────────────────────────────────
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: ConnectLoader()),
            )
          else if (orgs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  Icon(Icons.domain_rounded, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No organisations found',
                    style: AppTypography.cardTitle,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask a coordinator to send you an invite link to join an organisation.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyText,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: orgs.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, indent: 72, color: AppColors.surfaceAlt),
              itemBuilder: (context, i) {
                final org = orgs[i];
                final isActive = org.uniqueChurchId == activeId;
                final isSwitching = _switching == org.uniqueChurchId;
                return _OrgRow(
                  org: org,
                  isActive: isActive,
                  isSwitching: isSwitching,
                  // Disable all rows while a switch is in progress.
                  onTap: (isActive || _switching != null)
                      ? null
                      : () => _switchTo(org.uniqueChurchId),
                );
              },
            ),

          // Bottom safe-area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// ─── Org Row ──────────────────────────────────────────────────────────────────

class _OrgRow extends StatelessWidget {
  final UserOrg org;
  final bool isActive;
  final bool isSwitching;
  final VoidCallback? onTap;

  const _OrgRow({
    required this.org,
    required this.isActive,
    required this.isSwitching,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Avatar uses org name initial + a gradient based on role
            ConnectAvatar(
              name: org.churchName,
              role: org.role.toLowerCase(),
              size: AvatarSize.sm,
            ),
            const SizedBox(width: 14),

            // Name + role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org.churchName,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    org.role,
                    style: AppTypography.bodyText.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Trailing indicator
            if (isSwitching)
              const SizedBox(
                width: 22,
                height: 22,
                child: ConnectLoader(size: 22),
              )
            else if (isActive)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.white,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
