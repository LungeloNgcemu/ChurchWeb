import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import '../../cards/user_card.dart';

class UsersBody extends StatefulWidget {
  const UsersBody({super.key});

  @override
  State<UsersBody> createState() => _UsersBodyState();
}

class _UsersBodyState extends State<UsersBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  static const List<String> _filters = ['All', 'Leaders', 'Members', 'New'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar (dark, matches topbar) ─────────────────────────
            _SearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),

            // ── Filter chips ──────────────────────────────────────────────
            _FilterChips(
              filters: _filters,
              selected: _selectedFilter,
              onSelected: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),

            // ── Member list ───────────────────────────────────────────────
            const Expanded(
              child: _MemberList(),
            ),
          ],
        ),
      ),

      // ── Invite FAB ────────────────────────────────────────────────────
      floatingActionButton: _InviteFab(),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteFaint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.whiteFaint, width: 1.5),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTypography.onDark(AppTypography.bodyMedium),
          cursorColor: AppColors.purple,
          decoration: InputDecoration(
            hintText: 'Search members...',
            hintStyle: AppTypography.caption.copyWith(
              color: AppColors.whiteDim,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.whiteDim,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Row(
        children: filters.map((filter) {
          final isActive = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.purple : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(
                    color: isActive
                        ? AppColors.purple
                        : AppColors.whiteFaint,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  filter,
                  style: AppTypography.chipLabel.copyWith(
                    color: isActive
                        ? AppColors.white
                        : AppColors.whiteDim,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Member List ──────────────────────────────────────────────────────────────
/// Placeholder list — wire to Supabase stream / fetch in a future update.
/// Preserves the original UserCard import so existing integration points remain.
class _MemberList extends StatelessWidget {
  const _MemberList();

  @override
  Widget build(BuildContext context) {
    // Static demo data matching the v2 mockup.
    // Replace with a StreamBuilder / FutureBuilder wired to your Supabase
    // members query once the data layer is connected.
    final List<_MemberData> sections = [
      _MemberData(
        sectionLabel: '12 Leaders',
        members: [
          _Member(
              name: 'John Dlamini',
              phone: '+27 82 345 6789',
              role: 'Leader',
              roleColor: AppColors.purple,
              roleBg: AppColors.purpleBadge),
          _Member(
              name: 'Sarah Peters',
              phone: '+27 71 892 0341',
              role: 'Coord.',
              roleColor: AppColors.orange,
              roleBg: AppColors.orangeTint),
          _Member(
              name: 'Mike Khumalo',
              phone: '+27 83 567 1204',
              role: 'Media',
              roleColor: AppColors.blueAccent,
              roleBg: AppColors.blueAccentTint),
        ],
      ),
      _MemberData(
        sectionLabel: '236 Members',
        members: [
          _Member(
              name: 'Amy Louw',
              phone: '+27 79 234 5601',
              role: 'Member',
              roleColor: AppColors.textMid,
              roleBg: AppColors.surfaceAlt),
          _Member(
              name: 'Thabo Radebe',
              phone: '+27 82 109 7654',
              role: 'Member',
              roleColor: AppColors.textMid,
              roleBg: AppColors.surfaceAlt),
          _Member(
              name: 'Nomsa Mthembu',
              phone: '+27 73 445 8812',
              role: 'New',
              roleColor: AppColors.orange,
              roleBg: AppColors.orangeTint),
        ],
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: sections.fold<int>(
        0,
        (sum, s) => sum + 1 + s.members.length,
      ),
      itemBuilder: (context, index) {
        // Flatten sections + headers into a single index space
        int cursor = 0;
        for (final section in sections) {
          if (index == cursor) {
            return _SectionHeader(label: section.sectionLabel);
          }
          cursor++;
          for (final member in section.members) {
            if (index == cursor) {
              return _MemberRow(member: member);
            }
            cursor++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 9, 20, 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceAlt, width: 1),
          bottom: BorderSide(color: AppColors.surfaceAlt, width: 1),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.sectionDivider.copyWith(
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─── Member Row ───────────────────────────────────────────────────────────────
class _MemberRow extends StatelessWidget {
  final _Member member;
  const _MemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Navigate to member detail — wire up as needed
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.surface, width: 1),
          ),
        ),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────────────
            ConnectAvatar(
              name: member.name,
              role: _roleKey(member.role),
              size: AvatarSize.md,
            ),
            const SizedBox(width: 13),

            // ── Name + phone ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    member.name,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.phone,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── Role badge ────────────────────────────────────────────
            _RoleBadge(
              label: member.role,
              color: member.roleColor,
              bg: member.roleBg,
            ),

            const SizedBox(width: 10),

            // ── Chevron ───────────────────────────────────────────────
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }

  /// Maps display role string to AppColors avatar gradient key.
  String _roleKey(String role) {
    switch (role.toLowerCase()) {
      case 'leader':
        return 'leader';
      case 'coord.':
      case 'coordinator':
        return 'coordinator';
      case 'media':
        return 'media';
      case 'new':
        return 'new';
      default:
        return 'member';
    }
  }
}

// ─── Role Badge ───────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _RoleBadge({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Invite FAB ───────────────────────────────────────────────────────────────
class _InviteFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Trigger invite flow — wire up as needed
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFabExt),
          boxShadow: AppSpacing.orangeButtonShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: AppColors.white, size: 18),
            const SizedBox(width: 8),
            Text('Invite', style: AppTypography.buttonPrimary.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─── Data models (local, static) ──────────────────────────────────────────────
class _Member {
  final String name;
  final String phone;
  final String role;
  final Color roleColor;
  final Color roleBg;

  const _Member({
    required this.name,
    required this.phone,
    required this.role,
    required this.roleColor,
    required this.roleBg,
  });
}

class _MemberData {
  final String sectionLabel;
  final List<_Member> members;

  const _MemberData({required this.sectionLabel, required this.members});
}
