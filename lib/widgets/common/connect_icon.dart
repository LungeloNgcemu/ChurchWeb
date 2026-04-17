import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';

/// Connect App ring-mark icon — transparent background.
///
/// [size]     — bounding box side length (default 38)
/// [darkMode] — true = white outer ring + orange inner (for dark surfaces)
///              false = purple outer ring + orange inner (for light surfaces)
///
/// Usage:
///   ConnectIcon(size: 38)                      // light bg
///   ConnectIcon(size: 38, darkMode: true)      // dark bg (splash, crossroad)
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
    final strokeWidth = size.width * 0.07;

    final outerColor = darkMode
        ? Colors.white.withOpacity(0.30)
        : AppColors.purple.withOpacity(0.35);
    final outerDotColor = darkMode ? Colors.white : AppColors.purple;

    // Outer ring
    canvas.drawCircle(
      center,
      size.width * 0.43,
      Paint()
        ..color = outerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Inner ring — orange @ 70%
    canvas.drawCircle(
      center,
      size.width * 0.25,
      Paint()
        ..color = AppColors.orange.withOpacity(0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Center dot — outer
    canvas.drawCircle(
      center,
      size.width * 0.10,
      Paint()..color = outerDotColor,
    );

    // Center dot — inner orange
    canvas.drawCircle(
      center,
      size.width * 0.05,
      Paint()..color = AppColors.orange,
    );
  }

  @override
  bool shouldRepaint(covariant _RingMarkPainter old) =>
      old.darkMode != darkMode;
}
