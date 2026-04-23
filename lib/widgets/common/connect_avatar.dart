import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';

/// Connect App — Avatar Component
/// Source of truth: CLAUDE.md § 4.6 Avatar & Member Row
///
/// Usage:
///   ConnectAvatar(name: 'James Wilson', size: AvatarSize.md)
///   ConnectAvatar(name: 'Sarah Lee', role: 'leader', size: AvatarSize.lg)
///   ConnectAvatar(name: 'Tom', imageUrl: 'https://...', showOnline: true)

enum AvatarSize { xs, sm, md, lg, xl }

class ConnectAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String? role;
  final AvatarSize size;
  final bool showOnline;

  const ConnectAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.role,
    this.size = AvatarSize.md,
    this.showOnline = false,
  });

  // ─── Size helpers ──────────────────────────────────────────────────────────
  double get _diameter {
    switch (size) {
      case AvatarSize.xs:
        return AppSpacing.avatarXs;
      case AvatarSize.sm:
        return AppSpacing.avatarSm;
      case AvatarSize.md:
        return AppSpacing.avatarMd;
      case AvatarSize.lg:
        return AppSpacing.avatarLg;
      case AvatarSize.xl:
        return AppSpacing.avatarXl;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.xs:
        return 8;
      case AvatarSize.sm:
        return 13;
      case AvatarSize.md:
        return 15;
      case AvatarSize.lg:
        return 24;
      case AvatarSize.xl:
        return 30;
    }
  }

  double get _onlineDotSize {
    switch (size) {
      case AvatarSize.xs:
        return 6;
      case AvatarSize.sm:
        return 9;
      case AvatarSize.md:
        return 10;
      case AvatarSize.lg:
        return 13;
      case AvatarSize.xl:
        return 15;
    }
  }

  // ─── Initials ──────────────────────────────────────────────────────────────
  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final d = _diameter;
    final gradient = AppColors.avatarGradientForRole(role);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Avatar circle ──────────────────────────────────────────────────
        SizedBox(
          width: d,
          height: d,
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? _NetworkImage(url: imageUrl!, diameter: d, initials: _initials, fontSize: _fontSize, gradient: gradient)
                : _InitialsCircle(initials: _initials, fontSize: _fontSize, gradient: gradient),
          ),
        ),

        // ── Online indicator ───────────────────────────────────────────────
        if (showOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: _OnlineDot(size: _onlineDotSize),
          ),
      ],
    );
  }
}

// ─── Initials circle ──────────────────────────────────────────────────────────
class _InitialsCircle extends StatelessWidget {
  final String initials;
  final double fontSize;
  final LinearGradient gradient;

  const _InitialsCircle({
    required this.initials,
    required this.fontSize,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.buttonPrimary.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Network image with initials fallback ────────────────────────────────────
class _NetworkImage extends StatelessWidget {
  final String url;
  final double diameter;
  final String initials;
  final double fontSize;
  final LinearGradient gradient;

  const _NetworkImage({
    required this.url,
    required this.diameter,
    required this.initials,
    required this.fontSize,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _InitialsCircle(
        initials: initials,
        fontSize: fontSize,
        gradient: gradient,
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _InitialsCircle(
          initials: initials,
          fontSize: fontSize,
          gradient: gradient,
        );
      },
    );
  }
}

// ─── Online dot ───────────────────────────────────────────────────────────────
class _OnlineDot extends StatelessWidget {
  final double size;
  const _OnlineDot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
    );
  }
}

// ─── Member Row ───────────────────────────────────────────────────────────────
/// Standard list tile: avatar + name/subtitle + optional trailing widget
/// Usage:
///   ConnectMemberRow(
///     name: 'James Wilson',
///     subtitle: 'Worship Leader',
///     role: 'leader',
///     trailing: ConnectBadge.purple(label: 'Leader'),
///   )
class ConnectMemberRow extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final String? role;
  final Widget? trailing;
  final VoidCallback? onTap;
  final AvatarSize avatarSize;

  const ConnectMemberRow({
    super.key,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.role,
    this.trailing,
    this.onTap,
    this.avatarSize = AvatarSize.sm,
  });

  @override
  Widget build(BuildContext context) {
    Widget row = Row(
      children: [
        ConnectAvatar(
          name: name,
          imageUrl: imageUrl,
          role: role,
          size: avatarSize,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTypography.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: row,
      );
    }
    return row;
  }
}

// ─── Avatar Stack ─────────────────────────────────────────────────────────────
/// Overlapping stack of avatars (e.g. "3 members attending")
/// Usage:
///   ConnectAvatarStack(names: ['Alice', 'Bob', 'Carol'], max: 3)
class ConnectAvatarStack extends StatelessWidget {
  final List<String> names;
  final List<String?> imageUrls;
  final List<String?> roles;
  final int max;
  final AvatarSize size;

  const ConnectAvatarStack({
    super.key,
    required this.names,
    this.imageUrls = const [],
    this.roles = const [],
    this.max = 4,
    this.size = AvatarSize.xs,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = names.length.clamp(0, max);
    final overflow = names.length - max;
    final d = _diameterForSize(size);
    const overlap = 6.0;
    final itemWidth = d - overlap;
    final totalWidth = visibleCount * itemWidth + overlap +
        (overflow > 0 ? itemWidth + overlap : 0);

    return SizedBox(
      width: totalWidth,
      height: d,
      child: Stack(
        children: [
          ...List.generate(visibleCount, (i) {
            return Positioned(
              left: i * itemWidth,
              child: _BorderedAvatar(
                name: names[i],
                imageUrl: i < imageUrls.length ? imageUrls[i] : null,
                role: i < roles.length ? roles[i] : null,
                size: size,
              ),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: visibleCount * itemWidth,
              child: _OverflowBubble(count: overflow, size: size),
            ),
        ],
      ),
    );
  }

  static double _diameterForSize(AvatarSize s) {
    switch (s) {
      case AvatarSize.xs:
        return AppSpacing.avatarXs;
      case AvatarSize.sm:
        return AppSpacing.avatarSm;
      case AvatarSize.md:
        return AppSpacing.avatarMd;
      case AvatarSize.lg:
        return AppSpacing.avatarLg;
      case AvatarSize.xl:
        return AppSpacing.avatarXl;
    }
  }
}

class _BorderedAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String? role;
  final AvatarSize size;

  const _BorderedAvatar({
    required this.name,
    this.imageUrl,
    this.role,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
      ),
      padding: const EdgeInsets.all(1.5),
      child: ConnectAvatar(
        name: name,
        imageUrl: imageUrl,
        role: role,
        size: size,
      ),
    );
  }
}

class _OverflowBubble extends StatelessWidget {
  final int count;
  final AvatarSize size;

  const _OverflowBubble({required this.count, required this.size});

  @override
  Widget build(BuildContext context) {
    final d = ConnectAvatarStack._diameterForSize(size);
    final fontSize = size == AvatarSize.xs ? 7.0 : 9.0;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.textMid,
          height: 1,
        ),
      ),
    );
  }
}
