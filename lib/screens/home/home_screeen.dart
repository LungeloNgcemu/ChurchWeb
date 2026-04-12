import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/church_init.dart';
import 'package:master/classes/home_class.dart';
import 'package:master/services/utils/invitation_service.dart';
import 'package:master/util/alerts.dart';
import 'package:provider/provider.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import 'widgets/about_us.dart';
import '../../classes/on_create_class.dart';
import '../../providers/url_provider.dart';
import 'create_minister.dart';
import 'package:master/screens/home/widgets/map.dart' as location;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // ── preserved ─────────────────────────────────────────────────────────────
  HomeClass homeClass = HomeClass();
  CreateClass create = CreateClass();
  ChurchInit visbibity = ChurchInit();
  Authenticate auth = Authenticate();
  bool isLoading = false;
  String selectedOption = 'About Us';

  @override
  void initState() {
    _initChurch();
    super.initState();
  }

  Future<void> _initChurch() async {
    setState(() => isLoading = true);
    await ChurchInit.init(context);
    homeClass.ministerInit(setState, context);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  @override
  bool get wantKeepAlive => true;

  // ── quick-action helpers ──────────────────────────────────────────────────
  static final _quickActions = [
    (_QaData('\u{1F4DD}', 'Post', AppColors.purpleTint, AppColors.purple, '/createPost')),
    (_QaData('\u{1F4C5}', 'Events', AppColors.orangeTint, AppColors.orange, '/createEvent')),
    (_QaData('\u{1F50D}', 'Members', AppColors.blueAccentTint, AppColors.blueAccent, '/members')),
    (_QaData('\u2B50', 'Requests', Color(0xFFF0FDF4), Color(0xFF059669), '/createRequest')),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.purple)),
      );
    }

    final churchName =
        Provider.of<christProvider>(context, listen: false).myMap['Project']
                ?['ChurchName'] ??
            'Sunrise Community';
    final address =
        Provider.of<christProvider>(context, listen: false).myMap['Project']
                ?['Address'] ??
            '';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Navy topbar ───────────────────────────────────────────────
          _TopBar(
            orgName: churchName,
            onShareTap: () async =>
                await InvitationService.shareInvitation(context),
          ),

          // ── Scrollable content ────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                // Greeting card (purple gradient)
                _GreetingCard(churchName: churchName, address: address),
                const SizedBox(height: 12),

                // Quick actions
                Row(children: [
                  for (final qa in _quickActions) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, qa.route),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusCard),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 1))
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: qa.bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(qa.emoji,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(height: 8),
                              Text(qa.label,
                                  style: AppTypography.labelTiny
                                      .copyWith(color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (qa != _quickActions.last) const SizedBox(width: 10),
                  ],
                ]),
                const SizedBox(height: 14),

                // ── Our Team (ministers) ──────────────────────────────────
                _SectionHeader(
                  title: 'Our Team',
                  actionLabel: ChurchInit.visibilityToggle(context)
                      ? 'Add'
                      : null,
                  onAction: ChurchInit.visibilityToggle(context)
                      ? () => create.sheeting(context, CreateMinister())
                      : null,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: StreamBuilder(
                    stream: homeClass.minister,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active &&
                          snapshot.hasData) {
                        final specs = snapshot.data as List;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: specs.length,
                          itemBuilder: (context, i) => GestureDetector(
                            onDoubleTap: () => alertDelete(
                                context, 'Delete Team Member?', () async {
                              homeClass.delete(context, 'Minister',
                                  specs[i]['id'], specs[i]['Image']);
                              homeClass.ministerInit(setState, context);
                            }),
                            child: _MemberTile(
                              name: specs[i]['Name'] ?? '',
                              role: specs[i]['Work'] ?? '',
                              imageUrl: specs[i]['Image'],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // ── Gallery / About / Map tabs ────────────────────────────
                _ChipRow(
                  options: const ['About Us', 'Gallery', 'Map'],
                  selected: selectedOption,
                  onSelect: (v) => setState(() => selectedOption = v),
                ),
                const SizedBox(height: 12),

                if (selectedOption == 'About Us') const AboutUs(),
                if (selectedOption == 'Gallery') ...[
                  if (ChurchInit.visibilityToggle(context))
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            homeClass.galleryInsert(context, setState),
                        icon: Icon(Icons.upload_rounded,
                            size: 16, color: AppColors.purple),
                        label: Text('Upload Images',
                            style: AppTypography.link),
                      ),
                    ),
                  homeClass.buildGallery(context),
                ],
                if (selectedOption == 'Map') location.Map(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Topbar ────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String orgName;
  final VoidCallback onShareTap;
  const _TopBar({required this.orgName, required this.onShareTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topBarHeight + MediaQuery.of(context).padding.top,
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(
          18, MediaQuery.of(context).padding.top, 18, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Org logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.purpleCardGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.hub_outlined,
                size: 16, color: AppColors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(orgName,
                style: AppTypography.screenTitle.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          // Notification
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.navyIconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_outlined,
                  size: 18, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 8),
          // Share / Invite
          GestureDetector(
            onTap: onShareTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.navyIconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.share_outlined,
                  size: 16, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Greeting hero card ────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final String churchName;
  final String address;
  const _GreetingCard({required this.churchName, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleCardGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusHeroCard),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning \u{1F44B}',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.whiteDim, fontSize: 12)),
              const SizedBox(height: 4),
              Text(churchName,
                  style: AppTypography.headingLarge
                      .copyWith(color: AppColors.white, fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(address,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.whiteDim)),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatCol(value: '248', label: 'Members'),
                  const SizedBox(width: 20),
                  _StatCol(value: '12', label: 'Events'),
                  const SizedBox(width: 20),
                  _StatCol(value: '5', label: 'New'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String value;
  final String label;
  const _StatCol({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: AppTypography.statValue.copyWith(
                color: AppColors.white, fontSize: 18)),
        Text(label,
            style: AppTypography.caption.copyWith(color: AppColors.whiteDim)),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader(
      {required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTypography.headingSmall),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: AppTypography.link.copyWith(fontSize: 12)),
          ),
      ],
    );
  }
}

// ── Team member tile ──────────────────────────────────────────────────────────
class _MemberTile extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;
  const _MemberTile(
      {required this.name, required this.role, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ConnectAvatar(
              name: name, imageUrl: imageUrl, size: AvatarSize.md),
          const SizedBox(height: 6),
          Text(name.split(' ').first,
              style: AppTypography.caption
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(role,
              style: AppTypography.labelTiny
                  .copyWith(color: AppColors.textMuted, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Chip row (About/Gallery/Map) ──────────────────────────────────────────────
class _ChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _ChipRow(
      {required this.options,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((o) {
        final sel = selected == o;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(o),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.navy : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                border: Border.all(
                    color: sel ? AppColors.navy : AppColors.surfaceAlt,
                    width: 2),
              ),
              child: Text(o,
                  style: AppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? AppColors.white : AppColors.textMid)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Quick-action data record ──────────────────────────────────────────────────
class _QaData {
  final String emoji;
  final String label;
  final Color bgColor;
  final Color color;
  final String route;
  const _QaData(this.emoji, this.label, this.bgColor, this.color, this.route);
}
