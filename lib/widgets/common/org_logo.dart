import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          if (hasImage) _buildImage(logoUrl!),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    // On Flutter Web + CanvasKit, cross-origin images uploaded via a plain
    // <img> element cause a WebGL SecurityError at the texImage2D stage —
    // even after the image visually loads — because CORS headers are required
    // for GPU texture uploads.
    //
    // Workaround: set cacheWidth/cacheHeight so Flutter decodes the image
    // through its codec pipeline (bytes → ui.Image) rather than routing it
    // through an HTML ImageElement. This bypasses the CanvasKit CORS issue.
    // The errorBuilder silently falls back to the initials layer on any
    // load or decode failure.
    if (kIsWeb) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        // Force decode through Flutter's codec on web — avoids the
        // HTML <img> → WebGL texImage2D cross-origin SecurityError.
        cacheWidth: size.toInt() * 2,
        cacheHeight: size.toInt() * 2,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }

    // Native (Android / iOS): use CachedNetworkImage for disk caching.
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
