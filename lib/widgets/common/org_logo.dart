import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:master/theme/app_colors.dart';

/// Displays an organisation logo with an initials fallback.
///
/// Usage:
///   OrgLogo(name: 'Sunrise Community', logoUrl: url, size: 40)
///   OrgLogo(name: 'Sunrise Community', size: 32, radius: 10) // rounded square
///
/// On Flutter Web + CanvasKit, cross-origin images rendered through an HTML
/// <img> element cause a WebGL SecurityError when CanvasKit tries to upload
/// the tainted texture.  We work around this by fetching the image bytes
/// directly with Dart's http client and painting them with Image.memory —
/// Flutter's codec creates a clean, untainted ui.Image that CanvasKit can
/// texture freely.
class OrgLogo extends StatefulWidget {
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

  @override
  State<OrgLogo> createState() => _OrgLogoState();
}

class _OrgLogoState extends State<OrgLogo> {
  // Cached future so rebuilds don't re-fire the request.
  Future<Uint8List?>? _bytesFuture;

  // ── Initials ─────────────────────────────────────────────────────────────
  String get _initials {
    final parts = widget.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _scheduleWebFetch();
  }

  @override
  void didUpdateWidget(OrgLogo old) {
    super.didUpdateWidget(old);
    if (old.logoUrl != widget.logoUrl) {
      _scheduleWebFetch();
    }
  }

  void _scheduleWebFetch() {
    final url = widget.logoUrl;
    if (kIsWeb && url != null && url.isNotEmpty) {
      _bytesFuture = _fetchBytes(url);
    } else {
      _bytesFuture = null;
    }
  }

  /// Fetch image bytes through Dart's http client.
  /// This bypasses the HTML <img> → CanvasKit texImage2D CORS restriction
  /// because Flutter gets clean bytes and creates the WebGL texture itself.
  static Future<Uint8List?> _fetchBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius ?? widget.size / 2;
    final hasImage = widget.logoUrl != null && widget.logoUrl!.isNotEmpty;

    return Container(
      width: widget.size,
      height: widget.size,
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
                fontSize: widget.size * 0.33,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),

          // ── Logo image ──────────────────────────────────────────────────
          if (hasImage)
            kIsWeb
                ? _WebImage(future: _bytesFuture!)
                : CachedNetworkImage(
                    imageUrl: widget.logoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
        ],
      ),
    );
  }
}

/// Web-only image renderer that uses pre-fetched bytes to avoid the
/// CanvasKit cross-origin SecurityError.
class _WebImage extends StatelessWidget {
  final Future<Uint8List?> future;
  const _WebImage({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink(); // initials show during load
        }
        final bytes = snap.data;
        if (bytes == null || bytes.isEmpty) {
          return const SizedBox.shrink(); // fall back to initials
        }
        return Image.memory(bytes, fit: BoxFit.cover);
      },
    );
  }
}
