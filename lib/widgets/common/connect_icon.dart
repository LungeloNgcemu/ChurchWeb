import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';

/// Connect App ring-mark icon — transparent background.
///
/// [size]     — bounding box side length (default 38)
/// [darkMode] — when true the wordmark (in ConnectLogo) uses white text;
///              the ring colours are the same on all backgrounds.
///
/// Usage:
///   ConnectIcon(size: 38)
///   ConnectIcon(size: 38, darkMode: true)
class ConnectIcon extends StatelessWidget {
  final double size;
  final bool darkMode;

  const ConnectIcon({super.key, this.size = 38, this.darkMode = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RingMarkPainter(darkMode: darkMode),
    );
  }
}

class _RingMarkPainter extends CustomPainter {
  final bool darkMode;
  const _RingMarkPainter({this.darkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final strokeW = size.width * 0.075;

    // Outer ring — purple, 65% opacity on light / 85% on dark
    canvas.drawCircle(
      center,
      size.width * 0.42,
      Paint()
        ..color = AppColors.purple.withOpacity(darkMode ? 0.85 : 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Inner ring — orange, solid
    canvas.drawCircle(
      center,
      size.width * 0.24,
      Paint()
        ..color = AppColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Centre dot — orange filled
    canvas.drawCircle(
      center,
      size.width * 0.09,
      Paint()..color = AppColors.orange,
    );
  }

  @override
  bool shouldRepaint(covariant _RingMarkPainter old) =>
      old.darkMode != darkMode;
}
