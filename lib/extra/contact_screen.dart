import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/theme_manager.dart';
import '../screens/chat/message_screen.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Navy topbar ───────────────────────────────────────────────
          _ChatTopBar(),

          // ── Chat content (preserved MessageScreen) ────────────────────
          const Expanded(
            child: MessageScreen(),
          ),
        ],
      ),

      // ── Compose FAB ────────────────────────────────────────────────────
      floatingActionButton: GestureDetector(
        onTap: () {},
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.purpleCardGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colors.primary.withOpacity(0.33),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.edit_outlined,
              color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}

// ── Chat topbar ───────────────────────────────────────────────────────────────
class _ChatTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    return Container(
      height: AppSpacing.topBarHeight + MediaQuery.of(context).padding.top,
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(
          18, MediaQuery.of(context).padding.top, 18, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Chat',
                    style:
                        AppTypography.screenTitle.copyWith(fontSize: 20)),
                const SizedBox(width: 8),
                // Unread badge placeholder
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('•',
                      style: AppTypography.labelTiny.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.navyIconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add_outlined,
                  size: 17, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
