import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';

/// Displays an organisation logo with an initials fallback.
///
/// Usage:
///   OrgLogo(name: 'Sunrise Community', logoUrl: url, size: 40)
///   OrgLogo(name: 'Sunrise Community', size: 32, radius: 10) // rounded square
class OrgLogo extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final double size;

  /// Corner radius. Defaults to [size] / 2 (full circle).
  final double? radius;

  const OrgLogo({
    super.key,
    required this.name,
    this.logoUrl,
    this.size = 40,
    this.radius,
  });

  // ── Initials ─────────────────────────────────────────────────────────────
  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size / 2;
    final hasImage = logoUrl != null && logoUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Initials layer (always visible underneath) ──────────────────
          Container(
            color: AppColors.purple,
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.33,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
          // ── Logo image (overlays initials when loaded successfully) ─────
          if (hasImage)
            CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
