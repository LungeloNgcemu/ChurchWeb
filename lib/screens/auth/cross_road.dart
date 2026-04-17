import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/install_pwa/install_pwa.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/util/alerts.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_app_icon.dart';
import 'package:master/widgets/common/connect_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CrossRoad — Get Started / Onboarding choice screen
// Visual: Connect App v2 split layout
// Logic:  unchanged — InstallPwa check, navigation to /RegisterMember and
//         /createAccount
// ─────────────────────────────────────────────────────────────────────────────
class CrossRoad extends StatefulWidget {
  const CrossRoad({super.key});

  @override
  State<CrossRoad> createState() => _CrossRoadState();
}

class _CrossRoadState extends State<CrossRoad> {
  // ── preserved from original ───────────────────────────────────────────────
  Authenticate auth = Authenticate();
  SqlDatabase sql = SqlDatabase();
  InstallPwa installPwa = InstallPwa();

  @override
  void initState() {
    checkInstall(context); // preserved
    super.initState();
  }

  // ── preserved: exact PWA install check logic ──────────────────────────────
  Future<void> checkInstall(BuildContext context) async {
    bool isInstalled = await InstallPwa.isInstalled();
    print('isInstalled $isInstalled');

    if (!isInstalled) {
      String platform = InstallPwa.platform();
      print('platform $platform');
      if (platform == 'ios') {
        await alertIos(
            context,
            "To install this app on iOS:\n\n"
            "1. Tap the Share button (bottom center in Safari).\n"
            "2. Select 'Add to Home Screen'.\n\n"
            "This will install the app on your device for the best experience.",
            () async {
          await InstallPwa.setInstalled();
        });
      } else {
        alertInstall(context, "Install the app to get the best experience",
            () async {
          await InstallPwa.setInstalled();
          InstallPwa.showInstallPrompt();
        }, () async {
          await InstallPwa.setInstalled();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(
        children: [
          // ── Top dark hero ──────────────────────────────────────────────
          SizedBox(
            height: size.height * 0.44,
            child: Stack(
              children: [
                // Subtle purple radial glow
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.purple.withOpacity(0.28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Icon + wordmark + tagline
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40), // safe area offset
                      const ConnectAppIcon(size: 68),
                      const SizedBox(height: 18),
                      const ConnectLogo(size: 42, darkMode: true),
                      const SizedBox(height: 7),
                      Text(
                        'Your community, your way',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.whiteDim,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom white card ──────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusBottomSheet),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ────────────────────────────────────────────
                    Text('WELCOME', style: AppTypography.fieldLabel),
                    const SizedBox(height: 6),
                    Text('Join your community',
                        style: AppTypography.headingLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Connect with the people that matter most to you',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 22),

                    // ── Join a Community ──────────────────────────────────
                    _OptionCard(
                      iconBg: AppColors.purpleTint,
                      iconColor: AppColors.purple,
                      icon: Icons.group_add_outlined,
                      title: 'Join a Community',
                      subtitle: 'Enter an invite code or scan a QR link',
                      cardBg: AppColors.white,
                      borderColor: AppColors.purpleBorder,
                      onTap: () =>
                          Navigator.pushNamed(context, '/RegisterMember'),
                    ),
                    const SizedBox(height: 12),

                    // ── Create an Organisation ────────────────────────────
                    _OptionCard(
                      iconBg: AppColors.orangeTint,
                      iconColor: AppColors.orange,
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Create an Organisation',
                      subtitle: 'Set up your own community space',
                      cardBg: const Color(0xFFFFFBF5),
                      borderColor: const Color(0xFFFED7AA),
                      onTap: () =>
                          Navigator.pushNamed(context, '/createAccount'),
                    ),
                    const SizedBox(height: 28),

                    // ── Sign in link ──────────────────────────────────────
                    Center(
                      child: Text(
                        'Already a member?',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/RegisterMember'),
                        child: Text(
                          'Sign in to your account →',
                          style: AppTypography.link,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Option Card ──────────────────────────────────────────────────────────────
class _OptionCard extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color cardBg;
  final Color borderColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cardBg,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Icon tile
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.cardTitle),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium
                        .copyWith(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
