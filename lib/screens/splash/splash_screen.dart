import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:master/classes/church_init.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/constants/constants.dart';
import 'package:master/databases/database.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen
// Visual: Connect App v2 design (navy bg, purple glow, wordmark, dots)
// Logic:  unchanged — same token check, ChurchInit, navigation routes
// ─────────────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── kept from original ────────────────────────────────────────────────────
  late ChurchInit churchStart;
  SqlDatabase sql = SqlDatabase();

  // ── new: fade-in animation (replaces FlutterSplashScreen.fadeIn visual) ──
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    debugPrint("On Init");

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward().then((_) => debugPrint("On Fade In End"));

    _navigate();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── preserved: ChurchInit call ────────────────────────────────────────────
  Future<void> _initChurch() async {
    await ChurchInit.init(context);
  }

  // ── preserved: exact navigation logic from asyncNavigationCallback ────────
  Future<void> _navigate() async {
    final uri = Uri.base;
    if (uri.path.contains('/joinChurch')) {
      // deep link handling — do NOT run splash logic
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 5));

      final token = await SqlDatabase.getToken();

      if (token != "" && context.mounted) {
        await _initChurch();

        Navigator.of(context).pushNamedAndRemoveUntil(
          RoutePaths.church,
          (Route<dynamic> route) => false,
        );
      } else if (context.mounted) {
        Navigator.pushNamed(context, RoutePaths.crossRoad);
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.pushNamed(context, RoutePaths.crossRoad);
      }
    }

    debugPrint("On End");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: FadeTransition(
        opacity: _fade,
        child: const _SplashContent(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Visual content — stateless, pure UI
// ─────────────────────────────────────────────────────────────────────────────
class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // ── Purple radial glow behind the icon ────────────────────────────
        Positioned(
          top: size.height * 0.27,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purple.withOpacity(0.38),
                    AppColors.purple.withOpacity(0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── Centre column: icon + wordmark + tagline ──────────────────────
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon tile
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleCardGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.45),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(child: _ConnectIcon()),
              ),

              const SizedBox(height: 26),

              // "Connect." wordmark
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Connect',
                      style: AppTypography.wordmark,
                    ),
                    TextSpan(
                      text: '.',
                      style: AppTypography.wordmark
                          .copyWith(color: AppColors.purple),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Tagline
              Text(
                'Where community happens',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.whiteDim,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        // ── Bottom: loading dots + version ────────────────────────────────
        Positioned(
          bottom: 52,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dot indicators — first is active pill
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _Dot(),
                  const SizedBox(width: 6),
                  _Dot(),
                ],
              ),

              const SizedBox(height: 16),

              // Version label
              Text(
                'v2.4.1 · Connect App',
                style: AppTypography.caption.copyWith(
                  color: AppColors.whiteDim,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Inactive dot ─────────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.whiteDim,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ─── App icon painter (WiFi-style connectivity arcs + dot) ────────────────────
class _ConnectIcon extends StatelessWidget {
  const _ConnectIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(38, 38),
      painter: _ConnectIconPainter(),
    );
  }
}

class _ConnectIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    // Anchor point for arcs — sits slightly below center
    final anchorY = size.height * 0.64;

    // ── Centre dot ────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, anchorY),
      2.6,
      Paint()..color = Colors.white,
    );

    // ── Inner arc (above dot) ─────────────────────────────────────────────
    // In Flutter canvas y↓: startAngle=π (left), sweepAngle=-π goes
    // counter-clockwise through the TOP half to the right.
    final ir = size.width * 0.22;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, anchorY), width: ir * 2, height: ir * 2),
      pi,   // start at left
      -pi,  // sweep counter-clockwise through top → right
      false,
      strokePaint,
    );

    // ── Outer arc (above dot) ─────────────────────────────────────────────
    final or_ = size.width * 0.42;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, anchorY), width: or_ * 2, height: or_ * 2),
      pi,
      -pi,
      false,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
