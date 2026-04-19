import 'package:flutter/material.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/connect_theme_data.dart';
import 'package:master/theme/theme_manager.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import 'package:master/widgets/common/connect_loader.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry points — call these from HomeScreen quick action taps
// ─────────────────────────────────────────────────────────────────────────────

void showPostsModal(BuildContext context) {
  final churchName =
      Provider.of<christProvider>(context, listen: false)
          .myMap['Project']?['ChurchName'] ??
      'Sunrise Community';
  _openSheet(context, _PostsSheet(churchName: churchName));
}

void showEventsModal(BuildContext context) {
  _openSheet(context, const _ComingSoonSheet(
    icon: Icons.calendar_month_rounded,
    badge: 'Events',
    title: 'Events are on the way',
    subtitle: 'Stay tuned — upcoming gatherings will appear here.',
    useAccent: false,
  ));
}

void showMembersModal(BuildContext context) {
  _openSheet(context, const _MembersSheet());
}

void showRequestsModal(BuildContext context) {
  _openSheet(context, const _ComingSoonSheet(
    icon: Icons.star_rounded,
    badge: 'Requests',
    title: 'Requests coming soon',
    subtitle: 'Submit and track community requests right here.',
    useAccent: true,
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helper — opens a transparent, scrollable bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

void _openSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => child,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared shell — drag handle + rounded top
// ─────────────────────────────────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  final Widget child;
  final double maxHeightFactor;
  const _SheetShell({required this.child, this.maxHeightFactor = 0.72});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeManager>().colors;
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(maxHeight: screenH * maxHeightFactor),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.backgroundAlt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared modal header row
// ─────────────────────────────────────────────────────────────────────────────

class _ModalHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _ModalHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeManager>().colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        children: [
          Text(title, style: AppTypography.headingSmall),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.link.copyWith(
                  color: colors.primary,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. POSTS modal
// ─────────────────────────────────────────────────────────────────────────────

class _PostsSheet extends StatelessWidget {
  final String churchName;
  const _PostsSheet({required this.churchName});

  String _timeAgo(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeManager>().colors;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ModalHeader(
            title: 'Recent Posts',
            actionLabel: 'See all',
            onAction: () {
              Navigator.pop(context);
              // Switch to Posts tab (index 1 in the PageView)
              Navigator.pushNamed(context, '/posts');
            },
          ),
          const Divider(height: 1),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('Posts')
                .stream(primaryKey: ['id'])
                .eq('Church', churchName)
                .order('id', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: ConnectLoader()),
                );
              }
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return _EmptyState(
                  icon: Icons.article_outlined,
                  message: 'No posts yet',
                  color: colors.primary,
                );
              }
              final visible = posts.take(3).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: visible.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 70,
                  color: colors.backgroundAlt,
                ),
                itemBuilder: (context, i) {
                  final post = visible[i];
                  final name = (post['UserName'] as String?) ?? 'Member';
                  final description =
                      (post['Description'] as String?) ?? '';
                  final imageUrl = post['ImageUrl'] as String?;
                  final createdAt = post['created_at'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        ConnectAvatar(
                          name: name,
                          size: AvatarSize.sm,
                        ),
                        const SizedBox(width: 12),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name,
                                      style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: colors.textPrimary)),
                                  const Spacer(),
                                  Text(_timeAgo(createdAt),
                                      style: AppTypography.caption.copyWith(
                                          color: colors.textMuted,
                                          fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyText.copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // Thumbnail
                        if (imageUrl != null && imageUrl.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. MEMBERS modal
// ─────────────────────────────────────────────────────────────────────────────

class _MembersSheet extends StatelessWidget {
  const _MembersSheet();

  Color _roleColor(String? role, ConnectThemeData colors) {
    switch (role?.toLowerCase()) {
      case 'leader':
      case 'admin':
        return colors.primary;
      case 'coordinator':
      case 'coord':
        return colors.accent;
      case 'media':
        return ConnectThemeData.blueAccent;
      default:
        return colors.textMuted;
    }
  }

  Color _roleBg(String? role, ConnectThemeData colors) {
    switch (role?.toLowerCase()) {
      case 'leader':
      case 'admin':
        return colors.primaryTint;
      case 'coordinator':
      case 'coord':
        return colors.accentTint;
      case 'media':
        return ConnectThemeData.blueAccentTint;
      default:
        return colors.backgroundAlt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeManager>().colors;
    return _SheetShell(
      child: FutureBuilder(
        future: TokenService.tokenUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: ConnectLoader()),
            );
          }
          final uniqueChurchId = snapshot.data?.uniqueChurchId ?? '';
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModalHeader(
                title: 'Members',
                actionLabel: 'View all',
                onAction: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/members');
                },
              ),
              const Divider(height: 1),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('Users')
                    .stream(primaryKey: ['id'])
                    .eq('uniqueChurchId', uniqueChurchId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: ConnectLoader()),
                    );
                  }
                  final members = snapshot.data ?? [];
                  if (members.isEmpty) {
                    return _EmptyState(
                      icon: Icons.people_outline_rounded,
                      message: 'No members yet',
                      color: colors.primary,
                    );
                  }
                  final visible = members.take(5).toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 72,
                      color: colors.backgroundAlt,
                    ),
                    itemBuilder: (context, i) {
                      final member = visible[i];
                      final name =
                          (member['UserName'] as String?) ?? 'Member';
                      final phone =
                          (member['PhoneNumber'] as String?) ?? '';
                      final role = member['Role'] as String?;
                      final imageUrl = member['ProfileImage'] as String?;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        child: Row(
                          children: [
                            ConnectAvatar(
                              name: name,
                              imageUrl: imageUrl,
                              size: AvatarSize.md,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: AppTypography.bodyMedium
                                          .copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: colors.textPrimary)),
                                  if (phone.isNotEmpty)
                                    Text(phone,
                                        style: AppTypography.caption
                                            .copyWith(
                                                color: colors.textMuted,
                                                fontSize: 11)),
                                ],
                              ),
                            ),
                            if (role != null && role.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _roleBg(role, colors),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  role,
                                  style: AppTypography.labelTiny.copyWith(
                                    color: _roleColor(role, colors),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3 & 4. COMING SOON sheet (shared by Events + Requests)
// ─────────────────────────────────────────────────────────────────────────────

class _ComingSoonSheet extends StatelessWidget {
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;

  /// false → use theme.primary (purple), true → use theme.accent (orange)
  final bool useAccent;

  const _ComingSoonSheet({
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.useAccent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeManager>().colors;
    final color = useAccent ? colors.accent : colors.primary;
    final tint = useAccent ? colors.accentTint : colors.primaryTint;

    return _SheetShell(
      maxHeightFactor: 0.42,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 8, 24, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Icon circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            // Badge pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                badge,
                style: AppTypography.labelTiny.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: AppTypography.headingSmall.copyWith(
                color: colors.textPrimary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            // Subtitle
            Text(
              subtitle,
              style: AppTypography.bodyText.copyWith(
                color: colors.textMuted,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Notify button — gradient CTA matching design system
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 17),
                decoration: BoxDecoration(
                  gradient: useAccent
                      ? colors.accentGradient
                      : colors.primaryCardGradient,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Notify me when ready',
                  style: AppTypography.buttonPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _EmptyState(
      {required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color.withOpacity(0.4)),
            const SizedBox(height: 10),
            Text(message,
                style: AppTypography.bodyText.copyWith(
                    color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
