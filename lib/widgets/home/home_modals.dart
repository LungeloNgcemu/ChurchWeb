import 'package:flutter/material.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/connect_theme_data.dart';
import 'package:master/theme/theme_manager.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import 'package:master/widgets/common/connect_loader.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry points — called from HomeScreen quick-action taps
// ─────────────────────────────────────────────────────────────────────────────

void showPostsModal(BuildContext context) {
  final churchName =
      Provider.of<christProvider>(context, listen: false)
              .myMap['Project']?['ChurchName'] ??
          'Sunrise Community';
  _openSheet(context, _PostsSheet(churchName: churchName));
}

void showEventsModal(BuildContext context) {
  _openSheet(
    context,
    const _ComingSoonSheet(
      icon: Icons.calendar_month_rounded,
      badge: 'Events',
      title: 'Events are on the way',
      subtitle: 'Stay tuned — upcoming gatherings will appear here.',
      useAccent: false,
    ),
  );
}

void showMembersModal(BuildContext context) {
  _openSheet(context, const _MembersSheet());
}

void showRequestsModal(BuildContext context) {
  _openSheet(
    context,
    const _ComingSoonSheet(
      icon: Icons.star_rounded,
      badge: 'Requests',
      title: 'Requests coming soon',
      subtitle: 'Submit and track community requests right here.',
      useAccent: true,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal helper
// Modal routes get a fresh context that cannot find inherited providers, so we
// inject ThemeManager explicitly via ChangeNotifierProvider.value.
// ─────────────────────────────────────────────────────────────────────────────

void _openSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,  // sheet scaffold is transparent
    isScrollControlled: true,
    builder: (_) => ChangeNotifierProvider<ThemeManager>.value(
      value: ThemeManager.instance,
      child: child,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared shell — rounded top + drag handle, fully themed
// ─────────────────────────────────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  final Widget child;
  final double maxHeightFactor;
  const _SheetShell({required this.child, this.maxHeightFactor = 0.72});

  @override
  Widget build(BuildContext context) {
    // Line A: inject themeManager via Provider.of at top of builder
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final colors = themeManager.colors;

    final screenH = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(maxHeight: screenH * maxHeightFactor),
      decoration: BoxDecoration(
        // Line B: background → themeManager.colors.background (no Colors.white)
        color: colors.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
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
                  // Line C: handle → themeManager.colors.backgroundAlt (no grey)
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
    // Line D: inject themeManager via Provider.of at top of builder
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final colors = themeManager.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            // Line E: title text → themeManager.colors.textPrimary
            style: AppTypography.headingSmall
                .copyWith(color: colors.textPrimary),
          ),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                // Line F: "See all"/"View all" → themeManager.colors.primary
                style: AppTypography.link
                    .copyWith(color: colors.primary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. POSTS modal builder
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
    // Line G: inject themeManager via Provider.of at top of posts builder
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final colors = themeManager.colors;

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
              Navigator.pushNamed(context, '/posts');
            },
          ),
          // Line H: divider → themeManager.colors.backgroundAlt
          Divider(height: 1, color: colors.backgroundAlt),
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
                  colors: colors,
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
                  // Line I: post-row divider → themeManager.colors.backgroundAlt
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
                        ConnectAvatar(name: name, size: AvatarSize.sm),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: AppTypography.bodyMedium
                                        .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      // Line J: name → themeManager.colors.textPrimary
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _timeAgo(createdAt),
                                    style: AppTypography.caption.copyWith(
                                      // Line K: timestamp → themeManager.colors.textMuted
                                      color: colors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyText.copyWith(
                                  // Line L: description → themeManager.colors.textSecondary
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
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
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. MEMBERS modal builder
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
    // Line M: inject themeManager via Provider.of at top of members builder
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final colors = themeManager.colors;

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
              // Line N: divider → themeManager.colors.backgroundAlt
              Divider(height: 1, color: colors.backgroundAlt),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('User')
                    .stream(primaryKey: ['UserId'])
                    .eq('UniqueChurchId', uniqueChurchId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
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
                      colors: colors,
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
                      // Line O: member-row divider → themeManager.colors.backgroundAlt
                      color: colors.backgroundAlt,
                    ),
                    itemBuilder: (context, i) {
                      final member = visible[i];
                      final name =
                          (member['UserName'] as String?) ?? 'Member';
                      final phone =
                          (member['PhoneNumber'] as String?) ?? '';
                      final role = member['Role'] as String?;
                      final imageUrl =
                          member['ProfileImage'] as String?;

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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTypography.bodyMedium
                                        .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      // Line P: member name → themeManager.colors.textPrimary
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  if (phone.isNotEmpty)
                                    Text(
                                      phone,
                                      style: AppTypography.caption
                                          .copyWith(
                                        // Line Q: phone → themeManager.colors.textMuted
                                        color: colors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Role badge — colored but readable on any theme bg
                            if (role != null && role.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  // Line R: role badge bg uses role-specific tint (theme-aware)
                                  color: _roleBg(role, colors),
                                  borderRadius:
                                      BorderRadius.circular(50),
                                ),
                                child: Text(
                                  role,
                                  style: AppTypography.labelTiny
                                      .copyWith(
                                    // Line S: role badge text uses role-specific color (theme-aware)
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
              SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 12),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3 & 4. COMING SOON modal builder  (Events + Requests)
// ─────────────────────────────────────────────────────────────────────────────

class _ComingSoonSheet extends StatelessWidget {
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;

  /// false → theme primary (purple/blue), true → theme accent (orange/lime)
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
    // Line T: inject themeManager via Provider.of at top of coming-soon builder
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final colors = themeManager.colors;

    // Line U: pick primary or accent from theme — no hardcoded orange/purple
    final color = useAccent ? colors.accent : colors.primary;

    return _SheetShell(
      maxHeightFactor: 0.46,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24, 8, 24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            // Icon circle — gradient bg
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: colors.primaryCardGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),

            // Badge pill
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: colors.primaryCardGradient,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                badge,
                style: AppTypography.labelTiny.copyWith(
                  color: Colors.white,
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
                // Line Y: title → themeManager.colors.textPrimary
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
                // Line Z: subtitle → themeManager.colors.textMuted
                color: colors.textMuted,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // CTA button — gradient from theme, no hardcoded colour
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 17),
                decoration: BoxDecoration(
                  // Line AA: button bg → themeManager gradient (accent or primary)
                  gradient:colors.primaryCardGradient ,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Notify me when ready',
                  // white text on coloured button — intentional, not hardcoded bg
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
  final ConnectThemeData colors;
  const _EmptyState(
      {required this.icon, required this.message, required this.colors});

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
            Icon(icon,
                size: 40,
                // Line BB: empty icon → themeManager.colors.primary faded
                color: colors.primary.withOpacity(0.35)),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTypography.bodyText.copyWith(
                // Line CC: empty message → themeManager.colors.textMuted
                color: colors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
