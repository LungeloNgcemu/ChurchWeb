import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';

/// Connect App — Bottom Navigation Bar
/// Source of truth: CLAUDE.md § 4.7 Bottom Navigation — 5 Tabs
///
/// Usage:
///   ConnectBottomNav(
///     currentIndex: _tabIndex,
///     onTap: (i) => setState(() => _tabIndex = i),
///     isDark: false,        // light variant (default)
///     chatBadgeCount: 3,    // optional unread count on Chat tab
///   )
///
/// Tabs (fixed order): Home | Posts | Media | Chat | Profile

enum ConnectNavTab { home, posts, media, chat, profile }

class ConnectBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// true → dark navy bg (used on Media, Video Player screens)
  /// false → white bg (all other screens)
  final bool isDark;

  /// Unread count shown as badge on Chat tab (0 = hidden)
  final int chatBadgeCount;

  const ConnectBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isDark = false,
    this.chatBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.navy : AppColors.white;
    final borderColor = isDark
        ? AppColors.whiteFaint
        : AppColors.surfaceAlt;
    final inactiveColor =
        isDark ? AppColors.whiteDim.withOpacity(0.3) : AppColors.textMuted;

    return Container(
      height: AppSpacing.bottomNavHeight,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final isActive = currentIndex == i;
              return _NavItem(
                index: i,
                isActive: isActive,
                isDark: isDark,
                inactiveColor: inactiveColor,
                badgeCount: i == ConnectNavTab.chat.index ? chatBadgeCount : 0,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Individual Nav Item ──────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isDark;
  final Color inactiveColor;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.isActive,
    required this.isDark,
    required this.inactiveColor,
    required this.badgeCount,
    required this.onTap,
  });

  static const _labels = ['Home', 'Posts', 'Media', 'Chat', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                isActive
                    ? _ActivePill(index: index)
                    : _InactiveIcon(index: index, color: inactiveColor),
                if (badgeCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: _NotifBadge(count: badgeCount, isDark: isDark),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _labels[index],
              style: AppTypography.labelTiny.copyWith(
                color: isActive ? AppColors.purple : inactiveColor,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Active tab pill ──────────────────────────────────────────────────────────
class _ActivePill extends StatelessWidget {
  final int index;
  const _ActivePill({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.navPillW,
      height: AppSpacing.navPillH,
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChipSm),
      ),
      alignment: Alignment.center,
      child: _navIcon(index, AppColors.white),
    );
  }
}

// ─── Inactive icon ────────────────────────────────────────────────────────────
class _InactiveIcon extends StatelessWidget {
  final int index;
  final Color color;
  const _InactiveIcon({required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.navPillW,
      height: AppSpacing.navPillH,
      child: Center(child: _navIcon(index, color)),
    );
  }
}

// ─── Notification badge ───────────────────────────────────────────────────────
class _NotifBadge extends StatelessWidget {
  final int count;
  final bool isDark;
  const _NotifBadge({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.orange,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.navy : AppColors.white,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          height: 1,
        ),
      ),
    );
  }
}

// ─── SVG-free icon builders ───────────────────────────────────────────────────
Widget _navIcon(int index, Color color) {
  const strokeWidth = 1.6;
  switch (index) {
    case 0: // Home
      return CustomPaint(
        size: const Size(20, 20),
        painter: _HomePainter(color: color, strokeWidth: strokeWidth),
      );
    case 1: // Posts
      return CustomPaint(
        size: const Size(20, 20),
        painter: _PostsPainter(color: color, strokeWidth: strokeWidth),
      );
    case 2: // Media
      return CustomPaint(
        size: const Size(20, 20),
        painter: _MediaPainter(color: color, strokeWidth: strokeWidth),
      );
    case 3: // Chat
      return CustomPaint(
        size: const Size(20, 20),
        painter: _ChatPainter(color: color, strokeWidth: strokeWidth),
      );
    default: // Profile
      return CustomPaint(
        size: const Size(20, 20),
        painter: _ProfilePainter(color: color, strokeWidth: strokeWidth),
      );
  }
}

// ─── Custom painters ──────────────────────────────────────────────────────────
class _HomePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _HomePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.37)
      ..lineTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.37)
      ..lineTo(size.width * 0.9, size.height * 0.9)
      ..lineTo(size.width * 0.7, size.height * 0.9)
      ..lineTo(size.width * 0.7, size.height * 0.65)
      ..lineTo(size.width * 0.3, size.height * 0.65)
      ..lineTo(size.width * 0.3, size.height * 0.9)
      ..lineTo(size.width * 0.1, size.height * 0.9)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _PostsPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _PostsPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.25),
        Offset(size.width * 0.9, size.height * 0.25), paint);
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.5),
        Offset(size.width * 0.9, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.75),
        Offset(size.width * 0.55, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _MediaPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _MediaPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.15,
          size.width * 0.8, size.height * 0.55),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, paint);
    // Play triangle
    final tri = Path()
      ..moveTo(size.width * 0.4, size.height * 0.35)
      ..lineTo(size.width * 0.72, size.height * 0.425)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..close();
    canvas.drawPath(tri, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _ChatPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _ChatPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.2)
      ..arcToPoint(Offset(size.width * 0.9, size.height * 0.65),
          radius: const Radius.circular(2), clockwise: true)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(size.width * 0.4, size.height * 0.82)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..lineTo(size.width * 0.1, size.height * 0.65)
      ..arcToPoint(Offset(size.width * 0.1, size.height * 0.2),
          radius: const Radius.circular(2), clockwise: true)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _ProfilePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _ProfilePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.35),
        size.width * 0.175, paint);
    final arc = Path()
      ..moveTo(size.width * 0.15, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.6,
          size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.6,
          size.width * 0.85, size.height * 0.85);
    canvas.drawPath(arc, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
