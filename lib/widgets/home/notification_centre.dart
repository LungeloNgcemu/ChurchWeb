import 'package:flutter/material.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/screens/home/church_screen.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';

class NotificationCentre extends StatefulWidget {
  final String uniqueChurchId;

  const NotificationCentre({super.key, required this.uniqueChurchId});

  @override
  State<NotificationCentre> createState() => _NotificationCentreState();
}

class _NotificationCentreState extends State<NotificationCentre> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final rows = await supabase
          .from('Notifications')
          .select()
          .eq('UniqueChurchId', widget.uniqueChurchId)
          .order('created_at', ascending: false)
          .limit(50);
      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(rows as List);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _timeAgo(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  void _onTap(Map<String, dynamic> n) {
    // Remove from local list immediately for instant UI feedback.
    setState(() => _notifications.remove(n));

    // Delete from Supabase in the background so it never comes back.
    final id = n['id'];
    if (id != null) {
      supabase.from('Notifications').delete().eq('id', id).then((_) {}).catchError((_) {});
    }

    Navigator.of(context).pop();
    final type = (n['Type'] as String?) ?? '';
    if (type == 'post') {
      ChurchScreen.switchTab?.call(1);
    } else if (type == 'event') {
      ChurchScreen.switchTab?.call(0);
    }
  }

  Widget _typeIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'event':
        icon = Icons.event_rounded;
        color = AppColors.orange;
        break;
      case 'post':
        icon = Icons.article_rounded;
        color = AppColors.purple;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.purple;
    }
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusBottomSheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Text('Notifications',
                    style: AppTypography.headingMedium
                        .copyWith(fontSize: 18, color: AppColors.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.surfaceAlt),

          // ── List ─────────────────────────────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _notifications.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_rounded,
                                size: 40,
                                color: AppColors.textMuted.withOpacity(0.4)),
                            const SizedBox(height: 10),
                            Text('No notifications yet',
                                style: AppTypography.bodyText.copyWith(
                                    color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, indent: 72, color: AppColors.surfaceAlt),
                        itemBuilder: (context, i) {
                          final n = _notifications[i];
                          final type = (n['Type'] as String?) ?? '';
                          final title = (n['Title'] as String?) ?? '';
                          final body = (n['Body'] as String?) ?? '';
                          final time = _timeAgo(n['created_at']);

                          return InkWell(
                            onTap: () => _onTap(n),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _typeIcon(type),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(title,
                                                style: AppTypography.bodyMedium
                                                    .copyWith(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 13,
                                                        color: AppColors.textPrimary)),
                                          ),
                                          Text(time,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                      fontSize: 11,
                                                      color: AppColors.textMuted)),
                                        ]),
                                        if (body.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(body,
                                              style: AppTypography.bodyText.copyWith(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.chevron_right_rounded,
                                      size: 18, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          SizedBox(height: bottomPad + 12),
        ],
      ),
    );
  }
}
