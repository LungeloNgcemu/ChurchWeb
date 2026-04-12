import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';

/// Shared Connect App icon tile — purple gradient rounded square with
/// custom connectivity arc icon. Used on Splash, CrossRoad, RegisterMember.
///
/// Usage:
///   ConnectAppIcon(size: 68)
class ConnectAppIcon extends StatelessWidget {
  final double size;

  const ConnectAppIcon({super.key, this.size = 68});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.purpleCardGradient,
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.42),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.48, size * 0.48),
        painter: _ConnectIconPainter(),
      ),
    );
  }
}

class _ConnectIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Colors.white;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final anchorY = size.height * 0.64;

    // Centre dot
    canvas.drawCircle(Offset(cx, anchorY), 2.4, Paint()..color = color);

    // Inner arc — counter-clockwise through top half
    final ir = size.width * 0.22;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, anchorY), width: ir * 2, height: ir * 2),
      pi, -pi, false, strokePaint,
    );

    // Outer arc
    final or_ = size.width * 0.42;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, anchorY), width: or_ * 2, height: or_ * 2),
      pi, -pi, false, strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
