import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/connect_theme_data.dart';
import '../../theme/theme_manager.dart';

/// A tap target that shows the current theme name + colour swatch.
/// Tap it to open the full [_ThemePickerSheet].
///
/// Drop this anywhere — e.g. in the Profile screen settings list:
///   ThemeSwitcherTile()
class ThemeSwitcherTile extends StatelessWidget {
  const ThemeSwitcherTile({super.key});

  @override
  Widget build(BuildContext context) {
    final tm = context.watch<ThemeManager>();
    final theme = tm.colors;

    return GestureDetector(
      onTap: () => _ThemePickerSheet.show(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Colour swatch icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primary, theme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.palette_outlined,
                  size: 16, color: AppColors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Appearance',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ),
            // Current theme badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.purpleTint,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.purpleBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(theme.emoji,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    theme.name,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purple),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.surfaceAlt),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// The bottom sheet with 5 circular theme previews.
// ─────────────────────────────────────────────────────────────────────────────
class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ThemePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, tm, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
              24, 12, 24, MediaQuery.of(context).padding.bottom + 32),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appearance',
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Choose a theme for your experience',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: AppColors.textMid),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Theme grid — 5 cards
              Column(
                children: ConnectThemes.all.map((theme) {
                  final isActive = tm.colors.id == theme.id;
                  return _ThemeCard(
                    theme: theme,
                    isActive: isActive,
                    onTap: () async {
                      await tm.setTheme(theme);
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// One row in the theme picker — shows colour dots, name, and a checkmark.
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final ConnectThemeData theme;
  final bool isActive;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? Color.alphaBlend(
                  theme.primary.withOpacity(0.06), AppColors.white)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: isActive ? theme.primary : AppColors.surfaceAlt,
            width: isActive ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Colour preview circles
            _ColourDots(theme: theme),
            const SizedBox(width: 14),

            // Name + tagline
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        theme.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        theme.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? theme.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tagline(theme.id),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Checkmark / radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? theme.primary : Colors.transparent,
                border: Border.all(
                  color: isActive ? theme.primary : AppColors.surfaceAlt,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _tagline(String id) {
    switch (id) {
      case 'midnight': return 'Navy & purple — the classic Connect look';
      case 'cloud':    return 'Crisp white with blue accents';
      case 'ocean':    return 'Deep sea vibes with cyan highlights';
      case 'sunset':   return 'Warm cream tones with coral energy';
      case 'forest':   return 'Rich greens with golden accents';
      default:         return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Three stacked circles previewing background, primary and accent colours.
// ─────────────────────────────────────────────────────────────────────────────
class _ColourDots extends StatelessWidget {
  final ConnectThemeData theme;
  const _ColourDots({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 42,
      child: Stack(
        children: [
          // Background swatch (largest, furthest back)
          Positioned(
            left: 0,
            top: 2,
            child: _dot(38, theme.background,
                border: AppColors.surfaceAlt),
          ),
          // Primary swatch
          Positioned(
            left: 12,
            top: 2,
            child: _dot(38, theme.primary),
          ),
          // Accent swatch (smallest, front)
          Positioned(
            left: 24,
            top: 2,
            child: _dot(38, theme.accent),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color, {Color? border}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: border ?? AppColors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );
}
