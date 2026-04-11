import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';

/// Connect App — Card Components
/// Source of truth: CLAUDE.md § 4.5 Cards
///
/// Variants:
///   ConnectCard         — Standard white light card
///   ConnectCard.dark    — Dark navy surface card
///   ConnectCard.hero    — Gradient purple hero card
///   ConnectSectionHeader — "Title  See all →" row

// ─── Standard Light Card ─────────────────────────────────────────────────────
class ConnectCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Border? customBorder;

  const ConnectCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.customBorder,
  });

  /// Dark navy surface card
  const factory ConnectCard.dark({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) = _DarkCard;

  /// Purple gradient hero card (greeting, stats)
  const factory ConnectCard.hero({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
  }) = _HeroCard;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusCard;
    Widget card = Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: customBorder,
        boxShadow: AppSpacing.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ─── Dark Card ────────────────────────────────────────────────────────────────
class _DarkCard extends ConnectCard {
  const _DarkCard({
    super.key,
    required super.child,
    super.padding,
    super.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ─── Hero Gradient Card ───────────────────────────────────────────────────────
class _HeroCard extends ConnectCard {
  const _HeroCard({
    super.key,
    required super.child,
    super.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.purpleCardGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusHeroCard),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.whiteFaint,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 28,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.whiteFaint,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ─── Section Header Row ───────────────────────────────────────────────────────
/// "Section Title    See all →"
class ConnectSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ConnectSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTypography.headingSmall),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: AppTypography.link),
          ),
      ],
    );
  }
}

// ─── Role / Category Badge ────────────────────────────────────────────────────
/// Coloured pill badge used on member rows, post cards, etc.
class ConnectBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ConnectBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.purpleBadge,
    this.textColor = AppColors.purple,
  });

  /// Purple variant
  const factory ConnectBadge.purple({Key? key, required String label}) =
      _PurpleBadge;

  /// Orange variant
  const factory ConnectBadge.orange({Key? key, required String label}) =
      _OrangeBadge;

  /// Navy / dark variant
  const factory ConnectBadge.dark({Key? key, required String label}) =
      _DarkBadge;

  /// Muted / grey variant
  const factory ConnectBadge.muted({Key? key, required String label}) =
      _MutedBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(color: textColor),
      ),
    );
  }
}

class _PurpleBadge extends ConnectBadge {
  const _PurpleBadge({super.key, required super.label})
      : super(
          backgroundColor: AppColors.purpleBadge,
          textColor: AppColors.purple,
        );
}

class _OrangeBadge extends ConnectBadge {
  const _OrangeBadge({super.key, required super.label})
      : super(
          backgroundColor: AppColors.orangeTint,
          textColor: AppColors.orange,
        );
}

class _DarkBadge extends ConnectBadge {
  const _DarkBadge({super.key, required super.label})
      : super(
          backgroundColor: AppColors.navy,
          textColor: AppColors.white,
        );
}

class _MutedBadge extends ConnectBadge {
  const _MutedBadge({super.key, required super.label})
      : super(
          backgroundColor: AppColors.surfaceAlt,
          textColor: AppColors.textMid,
        );
}
