import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/font_manager.dart';

/// A tap target that shows the current font name.
/// Tap it to open the [_FontPickerSheet].
///
/// Drop into the Profile screen settings list:
///   FontSwitcherTile()
class FontSwitcherTile extends StatelessWidget {
  const FontSwitcherTile({super.key});

  @override
  Widget build(BuildContext context) {
    final fm = context.watch<FontManager>();
    final font = fm.font;

    return GestureDetector(
      onTap: () => _FontPickerSheet.show(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Font icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.text_fields_rounded,
                  size: 16, color: AppColors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Typography',
                style: AppTypography.cardTitle,
              ),
            ),
            // Current font badge
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
                  Text(font.emoji,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    font.name,
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
class _FontPickerSheet extends StatelessWidget {
  const _FontPickerSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _FontPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontManager>(
      builder: (context, fm, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
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
                        Text('Typography',
                            style: AppTypography.headingMedium),
                        const SizedBox(height: 2),
                        Text(
                          'Choose your preferred font style',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
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

              const SizedBox(height: 24),

              // Font list
              Column(
                children: ConnectFonts.all.map((fontOption) {
                  final isActive = fm.font.id == fontOption.id;
                  return _FontCard(
                    fontOption: fontOption,
                    isActive: isActive,
                    onTap: () async {
                      await fm.setFont(fontOption);
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
class _FontCard extends StatelessWidget {
  final ConnectFontData fontOption;
  final bool isActive;
  final VoidCallback onTap;

  const _FontCard({
    required this.fontOption,
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? Color.alphaBlend(
                  AppColors.purple.withOpacity(0.06), AppColors.card)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: isActive ? AppColors.purple : AppColors.surfaceAlt,
            width: isActive ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Font name rendered in its own typeface
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(fontOption.emoji,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        fontOption.name,
                        style: GoogleFonts.getFont(
                          ConnectFonts.familyFor(fontOption.id),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppColors.purple
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    // Show tagline in the font itself so the user can preview it
                    '"${fontOption.tagline}"',
                    style: GoogleFonts.getFont(
                      ConnectFonts.familyFor(fontOption.id),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark / radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.purple : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppColors.purple : AppColors.surfaceAlt,
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
}
