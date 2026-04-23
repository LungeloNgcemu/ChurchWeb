import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:master/theme/app_colors.dart';

/// Shows a branded in-app notification toast that slides in from the top.
/// Auto-dismisses after [duration]. Pass [onTap] to handle a tap action.
void showConnectToast({
  required BuildContext context,
  required String title,
  required String body,
  String type = 'post', // 'chat' | 'post' | 'request'
  Duration duration = const Duration(seconds: 4),
  VoidCallback? onTap,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _ConnectToast(
      title: title,
      body: body,
      type: type,
      duration: duration,
      onTap: onTap,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

// ─────────────────────────────────────────────────────────────────────────────

class _ConnectToast extends StatefulWidget {
  const _ConnectToast({
    required this.title,
    required this.body,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.onTap,
  });

  final String title;
  final String body;
  final String type;
  final Duration duration;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  @override
  State<_ConnectToast> createState() => _ConnectToastState();
}

class _ConnectToastState extends State<_ConnectToast>
    with TickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final AnimationController _progressCtrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Slide + fade in
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);

    // Progress bar drains over [duration]
    _progressCtrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideCtrl.forward();
    _progressCtrl.forward().then((_) {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() async {
    if (!mounted) return;
    await _slideCtrl.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  // Per-type accent colour and icon
  Color get _accent {
    switch (widget.type) {
      case 'chat':    return AppColors.orange;
      case 'request': return const Color(0xFF22C55E);
      default:        return AppColors.purple;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case 'chat':    return Icons.chat_bubble_rounded;
      case 'request': return Icons.volunteer_activism_rounded;
      default:        return Icons.campaign_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;

    return Positioned(
      top: topPad + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: () {
              widget.onTap?.call();
              _dismiss();
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Gradient left-border accent ──────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left accent bar
                          Container(
                            width: 4,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _accent,
                                  _accent.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),

                          // ── Icon bubble ──────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 14, 0, 14),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _accent,
                                    _accent.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _icon,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ── Text ─────────────────────────────────────────
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.body,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.55),
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Dismiss button ───────────────────────────────
                          GestureDetector(
                            onTap: _dismiss,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 10, 10, 0),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Progress drain bar ───────────────────────────────
                      AnimatedBuilder(
                        animation: _progressCtrl,
                        builder: (_, __) => LinearProgressIndicator(
                          value: 1.0 - _progressCtrl.value,
                          minHeight: 2.5,
                          backgroundColor: Colors.white.withOpacity(0.06),
                          valueColor: AlwaysStoppedAnimation<Color>(_accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
