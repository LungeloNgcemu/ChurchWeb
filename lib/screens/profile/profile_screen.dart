import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/Model/user_details_model.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/databases/database.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/services/api/user_service.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../../classes/church_init.dart';
import '../../providers/url_provider.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import 'package:master/widgets/common/org_logo.dart';
import 'package:master/widgets/common/theme_switcher.dart';
import 'package:master/widgets/common/font_switcher.dart';
import 'package:master/widgets/common/loading_switcher.dart';
import 'package:master/widgets/common/connect_loader.dart';
import 'package:master/widgets/common/connect_button.dart';
import 'package:master/widgets/common/connect_text_field.dart';
import 'package:master/widgets/common/org_switcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── preserved ─────────────────────────────────────────────────────────────
  AppWriteDataBase connect = AppWriteDataBase();
  ChurchInit churchStart = ChurchInit();
  PushNotifications push = PushNotifications();

  bool isLoading = false;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPhone = TextEditingController();
  String image = '';
  String _role = '';
  Map<String, dynamic> currentUser = {};
  String docId = '';
  String number = '';
  bool notificationMessage = false;
  bool notificationPost = false;

  @override
  void initState() {
    xgetUser();
    getNotificationValue();
    super.initState();
  }

  // ── preserved: load user ───────────────────────────────────────────────────
  void xgetUser() async {
    setState(() => isLoading = true);
    try {
      TokenUser? user = await TokenService.tokenUser();
      if (user == null) throw Exception('User not authenticated');
      setState(() {
        number = user.phoneNumber ?? '';
        _role  = user.role ?? '';
      });
      if (number.isEmpty) throw Exception('User phone number not found');
      UserDetails? userDetails =
          await UserService.getUserData(user.phoneNumber!, user.uniqueChurchId!);
      if (userDetails == null) throw Exception('User details not found');
      currentUser = {
        'UserName': userDetails.userName,
        'ProfileImage': userDetails.profileImage,
      };
      setState(() {
        controllerName.text = currentUser['UserName'] ?? '';
        image = currentUser['ProfileImage'] ?? '';
        isLoading = false;
      });
    } catch (error) {
      setState(() => isLoading = false);
      print(error);
    }
  }

  // ── preserved: update profile ──────────────────────────────────────────────
  Future<void> update() async {
    setState(() => isLoading = true);
    try {
      await supabase.from('Users').update({
        'UserName': controllerName.text,
        if (image.isNotEmpty) 'ProfileImage': image,
      }).eq('PhoneNumber', number);
      alertSuccess(context, 'Profile updated successfully');
    } catch (e) {
      log('Update error: $e');
      alertReturn(context, 'Failed to update profile');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ── preserved: notification toggle ────────────────────────────────────────
  Future<void> getNotificationValue() async {
    String? name = await PushNotifications.getCurrentTopic();
    setState(() {
      notificationMessage = name != null;
      notificationPost = name != null;
    });
  }

  Future<bool> updateNotification(bool value) async {
    try {
      if (value) {
        await PushNotifications.subscribeToChurchTopic('church');
      } else {
        await PushNotifications.unsubscribeFromChurchTopic('church');
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── preserved: image upload ────────────────────────────────────────────────
  final ImagePickerCustom _picker = ImagePickerCustom();
  Uint8List? _image;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImageToByte();
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> _uploadImageToSuperbase() async {
    setState(() => isLoading = true);
    try {
      await _pickImage();
      if (_image != null) {
        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['Bucket'] ??
                '')
            .updateBinary(fileName, _image!,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));
        final publicUrl = supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['Bucket'] ??
                '')
            .getPublicUrl(fileName);
        setState(() { image = publicUrl; isLoading = false; });
        log('Image Achieved');
      } else {
        setState(() => isLoading = false);
        log('No image selected');
      }
    } catch (e) {
      log('Error uploading image to Supabase: $e');
      setState(() => isLoading = false);
    }
  }

  // ── Org logo upload (Admin only) ─────────────────────────────────────────
  Future<void> _uploadOrgLogo() async {
    setState(() => isLoading = true);
    try {
      final imageBytes = await _picker.pickImageToByte();
      if (imageBytes == null) { setState(() => isLoading = false); return; }

      final provider = Provider.of<christProvider>(context, listen: false);
      final bucket  = provider.myMap['Project']?['Bucket'] ?? '';
      final orgName = provider.myMap['Project']?['ChurchName'] ?? '';

      await supabase.storage.from(bucket).uploadBinary(
        'org_logo',
        imageBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      final publicUrl = supabase.storage.from(bucket).getPublicUrl('org_logo');

      await supabase
          .from('Church')
          .update({'Logo': publicUrl})
          .eq('ChurchName', orgName);

      provider.myMap['Project']?['LogoAddress'] = publicUrl;
      provider.updatemyMap(newValue: provider.myMap);

      if (mounted) {
        alertSuccess(context, 'Organisation logo updated');
        setState(() => isLoading = false);
      }
    } catch (e) {
      log('Org logo upload error: $e');
      if (mounted) {
        alertReturn(context, 'Failed to update organisation logo');
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: const Center(child: ConnectLoader()),
      );
    }

    final userName   = currentUser['UserName'] ?? 'Thabo Mokoena';
    final role       = _role.isNotEmpty ? _role : 'Member';
    final orgProvider = Provider.of<christProvider>(context, listen: false);
    final orgName    = orgProvider.myMap['Project']?['ChurchName'] ?? '';
    final orgLogoUrl = orgProvider.myMap['Project']?['LogoAddress'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Purple gradient hero ──────────────────────────────────────
          _ProfileHero(
            userName: userName,
            role: role,
            imageUrl: image.isNotEmpty ? image : null,
            onEditTap: () => _showEditSheet(context),
            onImageTap: _uploadImageToSuperbase,
          ),

          // ── Stats strip ──────────────────────────────────────────────
          Container(
            color: AppColors.white,
            child: Column(children: [
              Row(children: [
                _StatCell(value: '48', label: 'Posts'),
                _StatCell(value: '248', label: 'Members'),
                _StatCell(value: '12', label: 'Events'),
              ]),
              Divider(height: 1, color: AppColors.surfaceAlt),
            ]),
          ),

          // ── Settings list ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ACCOUNT', style: AppTypography.labelTiny),
                  const SizedBox(height: 8),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.person_outline_rounded,
                      iconColor: AppColors.purple,
                      iconBg: AppColors.purpleTint,
                      label: 'Display Name',
                      value: controllerName.text.isNotEmpty
                          ? controllerName.text
                          : '',
                      onTap: () => _showEditSheet(context),
                    ),
                    _SettingsRow(
                      icon: Icons.phone_outlined,
                      iconColor: const Color(0xFF059669),
                      iconBg: const Color(0xFFF0FDF4),
                      label: 'Phone Number',
                      value: number.length > 6
                          ? '${number.substring(0, 6)} \u2022\u2022\u2022\u2022'
                          : number,
                      onTap: () {},
                    ),
                    _SettingsRow(
                      icon: Icons.image_outlined,
                      iconColor: AppColors.orange,
                      iconBg: AppColors.orangeTint,
                      label: 'Profile Image',
                      value: 'Change \u2192',
                      onTap: _uploadImageToSuperbase,
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Text('ORGANISATIONS', style: AppTypography.labelTiny),
                  const SizedBox(height: 8),
                  _SettingsGroup(rows: [
                    // Admin-only: org logo upload
                    if (_role == 'Admin')
                      _OrgLogoRow(
                        orgName: orgName,
                        logoUrl: orgLogoUrl.isEmpty ? null : orgLogoUrl,
                        onTap: _uploadOrgLogo,
                      ),
                    _SettingsRow(
                      icon: Icons.swap_horiz_rounded,
                      iconColor: AppColors.purple,
                      iconBg: AppColors.purpleTint,
                      label: 'My Organisations',
                      value: 'Switch',
                      onTap: () => showOrgSwitcher(context),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Text('APPEARANCE', style: AppTypography.labelTiny),
                  const SizedBox(height: 8),
                  _SettingsGroup(rows: [
                    const ThemeSwitcherTile(),
                    const FontSwitcherTile(),
                    const LoadingSwitcherTile(),
                  ]),
                  const SizedBox(height: 14),
                  Text('NOTIFICATIONS', style: AppTypography.labelTiny),
                  const SizedBox(height: 8),
                  _SettingsGroup(rows: [
                    _ToggleRow(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.purple,
                      iconBg: AppColors.purpleTint,
                      label: 'Chat Notifications',
                      value: notificationMessage,
                      onChanged: (v) async {
                        final ok = await updateNotification(v);
                        if (ok) setState(() => notificationMessage = v);
                      },
                    ),
                    _ToggleRow(
                      icon: Icons.campaign_outlined,
                      iconColor: AppColors.textMuted,
                      iconBg: AppColors.surfaceAlt,
                      label: 'Post Notifications',
                      value: notificationPost,
                      onChanged: (v) async {
                        final ok = await updateNotification(v);
                        if (ok) setState(() => notificationPost = v);
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  // Sign out button
                  GestureDetector(
                    onTap: () => alertLogout(context, 'Logout?'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusCard),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.2)),
                      ),
                      alignment: Alignment.center,
                      child: Text('Sign Out',
                          style: AppTypography.buttonPrimary
                              .copyWith(color: AppColors.error, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.xl4)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Edit Display Name', style: AppTypography.headingSmall),
            const SizedBox(height: 16),
            ConnectTextField(
              label: 'Display Name',
              placeholder: 'Your name',
              controller: controllerName,
              autofocus: true,
              leadingIcon: Icon(Icons.person_outline_rounded,
                  color: AppColors.purple, size: 16),
            ),
            const SizedBox(height: 20),
            ConnectButton.purple(
              label: 'Save Changes',
              onTap: () {
                Navigator.pop(ctx);
                update();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile hero ─────────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final String userName;
  final String role;
  final String? imageUrl;
  final VoidCallback onEditTap;
  final VoidCallback onImageTap;
  const _ProfileHero(
      {required this.userName,
      required this.role,
      this.imageUrl,
      required this.onEditTap,
      required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, Color(0xFF312E81)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          SizedBox(
            height: 68,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Profile', style: AppTypography.screenTitle),
                  const Spacer(),
                  GestureDetector(
                    onTap: onEditTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.navyIconBg,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text('\u2712 Edit',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onImageTap,
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.purple.withOpacity(0.6),
                            width: 3),
                      ),
                      child: ConnectAvatar(
                          name: userName,
                          imageUrl: imageUrl,
                          role: 'leader',
                          size: AvatarSize.lg),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 12, color: AppColors.white),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(userName,
                          style: AppTypography.headingLarge.copyWith(
                              color: AppColors.white, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.purple.withOpacity(0.4)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded,
                              size: 10, color: Color(0xFFC4B5FD)),
                          const SizedBox(width: 4),
                          Text(role,
                              style: AppTypography.badge
                                  .copyWith(color: const Color(0xFFC4B5FD))),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
                right: BorderSide(color: AppColors.surfaceAlt, width: 1)),
          ),
          child: Column(children: [
            Text(value,
                style: AppTypography.statValue.copyWith(fontSize: 18)),
            const SizedBox(height: 3),
            Text(label,
                style: AppTypography.caption
                    .copyWith(fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> rows;
  const _SettingsGroup({required this.rows});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 4,
                offset: Offset(0, 1))
          ],
        ),
        child: Column(
          children: List.generate(rows.length, (i) => Column(children: [
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 1, indent: 60, color: AppColors.surface),
          ])),
        ),
      );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value;
  final VoidCallback? onTap;
  const _SettingsRow(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.label,
      required this.value,
      this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: AppTypography.fieldValue
                        .copyWith(fontWeight: FontWeight.w600))),
            if (value.isNotEmpty)
              Text(value,
                  style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.purple, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.surfaceAlt),
          ]),
        ),
      );
}

// ─── Org logo row (Admin-only) ────────────────────────────────────────────────
class _OrgLogoRow extends StatelessWidget {
  final String orgName;
  final String? logoUrl;
  final VoidCallback? onTap;
  const _OrgLogoRow({required this.orgName, this.logoUrl, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            OrgLogo(name: orgName, logoUrl: logoUrl, size: 36, radius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Organisation Logo',
                  style: AppTypography.fieldValue
                      .copyWith(fontWeight: FontWeight.w600)),
            ),
            Text('Change \u2192',
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.purple, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.surfaceAlt),
          ]),
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: AppTypography.fieldValue
                      .copyWith(fontWeight: FontWeight.w600))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.purple,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.surfaceAlt,
          ),
        ]),
      );
}
