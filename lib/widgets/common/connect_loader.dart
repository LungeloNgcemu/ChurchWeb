import 'dart:math' show pi, sin;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/loading_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ConnectLoader
//
// Reads LoadingManager from context and renders the user's chosen animation.
// Drop-in replacement for CircularProgressIndicator.
//
//   ConnectLoader()           // 48px, default
//   ConnectLoader(size: 24)   // smaller, for inline use
// ─────────────────────────────────────────────────────────────────────────────
class ConnectLoader extends StatelessWidget {
  final double size;
  const ConnectLoader({super.key, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    final id = context.watch<LoadingManager>().animation.id;
    return switch (id) {
      'dual_spin'    => _DualSpinLoader(size: size),
      'comet_trail'  => _CometTrailLoader(size: size),
      'ripple_pulse' => _RipplePulseLoader(size: size),
      _              => _ExpandRippleLoader(size: size),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. EXPAND RIPPLE (default)
//    4 rings expand outward from center, alternating purple / orange,
//    each delayed by 0.25 of the 2-second cycle.
// ─────────────────────────────────────────────────────────────────────────────
class _ExpandRippleLoader extends StatefulWidget {
  final double size;
  const _ExpandRippleLoader({required this.size});
  @override
  State<_ExpandRippleLoader> createState() => _ExpandRippleLoaderState();
}

class _ExpandRippleLoaderState extends State<_ExpandRippleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ExpandRipplePainter(_ctrl.value),
      ),
    );
  }
}

class _ExpandRipplePainter extends CustomPainter {
  final double progress;
  const _ExpandRipplePainter(this.progress);

  static final _colors = [
    AppColors.purple,
    AppColors.orange,
    AppColors.purple,
    AppColors.orange,
  ];
  static const _offsets = [0.0, 0.25, 0.5, 0.75];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.44;
    final strokeW = size.width * 0.055;

    for (int i = 0; i < 4; i++) {
      final t = (progress + _offsets[i]) % 1.0;
      final r = maxR * t;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      canvas.drawCircle(
        c,
        r.clamp(0.01, maxR),
        Paint()
          ..color = _colors[i].withOpacity(opacity * 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
    }

    // Center dot: purple fill + orange pip
    canvas.drawCircle(c, size.width * 0.12, Paint()..color = AppColors.purple);
    canvas.drawCircle(c, size.width * 0.05, Paint()..color = AppColors.orange);
  }

  @override
  bool shouldRepaint(_ExpandRipplePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. DUAL SPIN
//    Outer purple arc (1.2 s, clockwise) + inner orange arc (1.8 s, CCW).
// ─────────────────────────────────────────────────────────────────────────────
class _DualSpinLoader extends StatefulWidget {
  final double size;
  const _DualSpinLoader({required this.size});
  @override
  State<_DualSpinLoader> createState() => _DualSpinLoaderState();
}

class _DualSpinLoaderState extends State<_DualSpinLoader>
    with TickerProviderStateMixin {
  late AnimationController _outerCtrl;
  late AnimationController _innerCtrl;

  @override
  void initState() {
    super.initState();
    _outerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _innerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _outerCtrl.dispose();
    _innerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_outerCtrl, _innerCtrl]),
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _DualSpinPainter(_outerCtrl.value, _innerCtrl.value),
      ),
    );
  }
}

class _DualSpinPainter extends CustomPainter {
  final double outerP;
  final double innerP;
  const _DualSpinPainter(this.outerP, this.innerP);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final outerR = size.width * 0.41;
    final innerR = size.width * 0.27;
    final sw = size.width * 0.06;
    const sweep = 4 * pi / 3; // 240°

    // Outer purple arc — clockwise
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: outerR),
      outerP * 2 * pi - pi / 2,
      sweep,
      false,
      Paint()
        ..color = AppColors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    // Inner orange arc — counter-clockwise (negative direction)
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: innerR),
      -innerP * 2 * pi - pi / 2,
      sweep,
      false,
      Paint()
        ..color = AppColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw * 0.9
        ..strokeCap = StrokeCap.round,
    );

    // Center dot
    canvas.drawCircle(c, size.width * 0.11, Paint()..color = AppColors.purple);
    canvas.drawCircle(c, size.width * 0.05, Paint()..color = AppColors.orange);
  }

  @override
  bool shouldRepaint(_DualSpinPainter old) =>
      old.outerP != outerP || old.innerP != innerP;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. COMET TRAIL
//    Short sweeping arcs at different speeds (same direction) with a fading
//    trail. Center dot pulses gently.
// ─────────────────────────────────────────────────────────────────────────────
class _CometTrailLoader extends StatefulWidget {
  final double size;
  const _CometTrailLoader({required this.size});
  @override
  State<_CometTrailLoader> createState() => _CometTrailLoaderState();
}

class _CometTrailLoaderState extends State<_CometTrailLoader>
    with TickerProviderStateMixin {
  late AnimationController _outerCtrl;
  late AnimationController _innerCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _outerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _innerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _outerCtrl.dispose();
    _innerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_outerCtrl, _innerCtrl, _pulseCtrl]),
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _CometTrailPainter(
          _outerCtrl.value,
          _innerCtrl.value,
          _pulseCtrl.value,
        ),
      ),
    );
  }
}

class _CometTrailPainter extends CustomPainter {
  final double outerP;
  final double innerP;
  final double pulse;
  const _CometTrailPainter(this.outerP, this.innerP, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final outerR = size.width * 0.41;
    final innerR = size.width * 0.27;
    final sw = size.width * 0.06;

    // Draw comet trail: head + 3 trailing arcs with fading opacity
    const trailCount = 4;
    const trailSweep = pi / 6; // 30° per segment
    const baseOpacity = 0.9;

    for (int t = trailCount - 1; t >= 0; t--) {
      final tOpacity = baseOpacity * ((trailCount - t) / trailCount);
      final outerStart = outerP * 2 * pi - pi / 2 - t * trailSweep;
      final innerStart = innerP * 2 * pi - pi / 2 - t * trailSweep;

      canvas.drawArc(
        Rect.fromCircle(center: c, radius: outerR),
        outerStart,
        trailSweep,
        false,
        Paint()
          ..color = AppColors.purple.withOpacity(tOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw * (0.5 + 0.5 * ((trailCount - t) / trailCount))
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawArc(
        Rect.fromCircle(center: c, radius: innerR),
        innerStart,
        trailSweep,
        false,
        Paint()
          ..color = AppColors.orange.withOpacity(tOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw * 0.85 * (0.5 + 0.5 * ((trailCount - t) / trailCount))
          ..strokeCap = StrokeCap.round,
      );
    }

    // Pulsing center dot
    final centerR = size.width * 0.08 + size.width * 0.04 * pulse;
    canvas.drawCircle(c, centerR, Paint()..color = AppColors.purple);
    canvas.drawCircle(c, size.width * 0.04, Paint()..color = AppColors.orange);
  }

  @override
  bool shouldRepaint(_CometTrailPainter old) =>
      old.outerP != outerP || old.innerP != innerP || old.pulse != pulse;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. RIPPLE PULSE
//    4 static rings whose opacity pulses in sequence (0.3s stagger).
//    Colours alternate purple / orange from outside in.
// ─────────────────────────────────────────────────────────────────────────────
class _RipplePulseLoader extends StatefulWidget {
  final double size;
  const _RipplePulseLoader({required this.size});
  @override
  State<_RipplePulseLoader> createState() => _RipplePulseLoaderState();
}

class _RipplePulseLoaderState extends State<_RipplePulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _RipplePulsePainter(_ctrl.value),
      ),
    );
  }
}

class _RipplePulsePainter extends CustomPainter {
  final double progress;
  const _RipplePulsePainter(this.progress);

  static const _radiiFactors = [0.44, 0.33, 0.22, 0.12];
  static const _offsets = [0.0, 0.1875, 0.375, 0.5625]; // 0.3s / 1.6s each
  static final _colors = [
    AppColors.purple,
    AppColors.orange,
    AppColors.purple,
    AppColors.orange,
  ];
  static const _strokeFactors = [0.055, 0.05, 0.045, 0.04];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 4; i++) {
      final t = (progress + _offsets[i]) % 1.0;
      // sin wave: 0→1→0 over one cycle
      final opacity = (sin(t * pi)).clamp(0.15, 1.0);
      canvas.drawCircle(
        c,
        size.width * _radiiFactors[i],
        Paint()
          ..color = _colors[i].withOpacity(opacity * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * _strokeFactors[i],
      );
    }

    // Center dot
    canvas.drawCircle(c, size.width * 0.10, Paint()..color = AppColors.purple);
    canvas.drawCircle(c, size.width * 0.045, Paint()..color = AppColors.orange);
  }

  @override
  bool shouldRepaint(_RipplePulsePainter old) => old.progress != progress;
}
