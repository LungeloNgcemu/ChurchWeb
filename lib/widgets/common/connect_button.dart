import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/widgets/common/connect_loader.dart';

/// Connect App — Button Components
/// Source of truth: CLAUDE.md § 4.4 Button Styles
///
/// Three variants:
///   ConnectButton.primary  — Orange CTA (full-width pill)
///   ConnectButton.purple   — Purple action (full-width pill)
///   ConnectButton.ghost    — Outline / ghost (full-width pill)
///   ConnectButton.icon     — Topbar square icon button

// ─── Primary (Orange) ────────────────────────────────────────────────────────
class ConnectButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool fullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final EdgeInsets? padding;

  const ConnectButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.fullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.padding,
  });

  /// Orange CTA — primary call-to-action
  const factory ConnectButton.primary({
    Key? key,
    required String label,
    VoidCallback? onTap,
    bool isLoading,
    bool fullWidth,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) = _PrimaryButton;

  /// Purple action — secondary action
  const factory ConnectButton.purple({
    Key? key,
    required String label,
    VoidCallback? onTap,
    bool isLoading,
    bool fullWidth,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) = _PurpleButton;

  /// Ghost — outline button on light background
  const factory ConnectButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onTap,
    bool fullWidth,
  }) = _GhostButton;

  @override
  Widget build(BuildContext context) {
    return _PrimaryButton(label: label, onTap: onTap, isLoading: isLoading);
  }
}

// ─── Orange Primary ──────────────────────────────────────────────────────────
class _PrimaryButton extends ConnectButton {
  const _PrimaryButton({
    super.key,
    required super.label,
    super.onTap,
    super.isLoading = false,
    super.fullWidth = true,
    super.leadingIcon,
    super.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onTap: onTap,
      isLoading: isLoading,
      fullWidth: fullWidth,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      backgroundColor: AppColors.orange,
      pressedColor: AppColors.orangeDeep,
      textStyle: AppTypography.buttonPrimary,
      shadows: AppSpacing.orangeButtonShadow,
    );
  }
}

// ─── Purple Secondary ────────────────────────────────────────────────────────
class _PurpleButton extends ConnectButton {
  const _PurpleButton({
    super.key,
    required super.label,
    super.onTap,
    super.isLoading = false,
    super.fullWidth = true,
    super.leadingIcon,
    super.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      onTap: onTap,
      isLoading: isLoading,
      fullWidth: fullWidth,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      backgroundColor: AppColors.purple,
      pressedColor: AppColors.purpleLight,
      textStyle: AppTypography.buttonPrimary,
      shadows: AppSpacing.purpleButtonShadow,
    );
  }
}

// ─── Ghost / Outline ─────────────────────────────────────────────────────────
class _GhostButton extends ConnectButton {
  const _GhostButton({
    super.key,
    required super.label,
    super.onTap,
    super.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 50,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: AppColors.surfaceAlt, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTypography.buttonGhost),
        ),
      ),
    );
  }
}

// ─── Shared base implementation ───────────────────────────────────────────────
class _BaseButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool fullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Color backgroundColor;
  final Color pressedColor;
  final TextStyle textStyle;
  final List<BoxShadow> shadows;

  const _BaseButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
    required this.fullWidth,
    required this.backgroundColor,
    required this.pressedColor,
    required this.textStyle,
    required this.shadows,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  State<_BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<_BaseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      height: 56,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: disabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: disabled
                ? AppColors.surfaceAlt
                : (_pressed ? widget.pressedColor : widget.backgroundColor),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            boxShadow: disabled || _pressed ? [] : widget.shadows,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: ConnectLoader(size: 22),
                )
              : Row(
                  mainAxisSize:
                      widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.leadingIcon != null) ...[
                      widget.leadingIcon!,
                      AppSpacing.hSm,
                    ],
                    Text(
                      widget.label,
                      style: widget.textStyle.copyWith(
                        color: disabled ? AppColors.textMuted : AppColors.white,
                      ),
                    ),
                    if (widget.trailingIcon != null) ...[
                      AppSpacing.hSm,
                      widget.trailingIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Icon Button (Topbar) ─────────────────────────────────────────────────────
/// Square icon button used in topbars.
///   isDark: true  → rgba white background (on dark topbar)
///   isDark: false → surface background (on light topbar)
class ConnectIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final bool isDark;
  final int? badgeCount;

  const ConnectIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.isDark = true,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: AppSpacing.topBarIconSize,
            height: AppSpacing.topBarIconSize,
            decoration: BoxDecoration(
              color: isDark ? AppColors.navyIconBg : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.navy : AppColors.white,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
