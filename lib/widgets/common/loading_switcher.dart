import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/loading_manager.dart';
import 'connect_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoadingSwitcherTile
//
// Settings row for the Profile screen APPEARANCE section.
// Shows current animation name; tap opens the full picker sheet.
// ─────────────────────────────────────────────────────────────────────────────
class LoadingSwitcherTile extends StatelessWidget {
  const LoadingSwitcherTile({super.key});

  @override
  Widget build(BuildContext context) {
    final lm = context.watch<LoadingManager>();
    final anim = lm.animation;

    return GestureDetector(
      onTap: () => _LoadingPickerSheet.show(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon tile
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.orange, AppColors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.motion_photos_on_rounded,
                  size: 16, color: AppColors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Loading style', style: AppTypography.cardTitle),
            ),
            // Current animation badge
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
                  Text(anim.emoji,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    anim.name,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple,
                    ),
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
// _LoadingPickerSheet — bottom sheet with live animation previews
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingPickerSheet extends StatelessWidget {
  const _LoadingPickerSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<LoadingManager>(),
        child: const _LoadingPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingManager>(
      builder: (context, lm, _) {
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
                        Text('Loading style',
                            style: AppTypography.headingMedium),
                        const SizedBox(height: 2),
                        Text(
                          'Choose your loading animation',
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

              // Animation options in a 2×2 grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: ConnectAnimations.all.map((option) {
                  final isActive = lm.animation.id == option.id;
                  return _AnimationCard(
                    option: option,
                    isActive: isActive,
                    onTap: () async {
                      await lm.setAnimation(option);
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
// _AnimationCard — single option card with live preview
// ─────────────────────────────────────────────────────────────────────────────
class _AnimationCard extends StatelessWidget {
  final ConnectAnimationData option;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimationCard({
    required this.option,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive
              ? Color.alphaBlend(
                  AppColors.orange.withOpacity(0.06), AppColors.card)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: isActive ? AppColors.orange : AppColors.surfaceAlt,
            width: isActive ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Live animation preview — uses a scoped provider override
            // so the preview always shows this specific animation.
            SizedBox(
              width: 64,
              height: 64,
              child: _PreviewLoader(animationId: option.id),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              option.name,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 13,
                color: isActive ? AppColors.orange : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 3),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                option.description,
                style: AppTypography.caption.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),

            if (isActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PreviewLoader — renders a specific animation regardless of global setting
// ─────────────────────────────────────────────────────────────────────────────
class _PreviewLoader extends StatelessWidget {
  final String animationId;
  const _PreviewLoader({required this.animationId});

  @override
  Widget build(BuildContext context) {
    // Override the LoadingManager in scope so ConnectLoader uses this animation.
    return ChangeNotifierProvider(
      create: (_) {
        final lm = LoadingManager();
        final option =
            ConnectAnimations.all.firstWhere((a) => a.id == animationId);
        lm.setAnimation(option);
        return lm;
      },
      child: const ConnectLoader(size: 48),
    );
  }
}
