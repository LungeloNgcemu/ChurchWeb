// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/Model/church_token_model.dart';
import 'package:master/Model/existing_user_model.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/snack_bar.dart';
import 'package:master/componants/multi_church_select.dart';
import 'package:master/constants/constants.dart';
import 'package:master/screens/auth/register/register_member.dart';
import 'package:master/services/api/general_data_service.dart';
import 'package:master/services/api/user_service.dart';
import 'package:master/util/alerts.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_button.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});
  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  // ── preserved ─────────────────────────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  String church = '';
  String? image;
  bool isLoading = false;
  bool isExpired = false;
  bool nameError = false;
  bool emailError = false;
  String? errorMessage;
  Authenticate auth = Authenticate();
  SnackBarNotice snack = SnackBarNotice();
  ChurchTokenData? churchTokenData;

  // ── new v2 state ──────────────────────────────────────────────────────────
  int _selectedGenderIndex = 0; // 0=Male,1=Female,2=Other
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _loadChurchData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── preserved: open external host after join ───────────────────────────────
  Future<void> openExternalHost() async {
    String baseUrlLaunch = BaseUrl.baseUrlLaunch!;
    html.window.location.href = baseUrlLaunch.toString();
  }

  // ── preserved: load church data from invite URL ────────────────────────────
  Future<void> _loadChurchData() async {
    try {
      final url = html.window.location.href;
      _currentUrl = url;
      print('Current URL: $url');
      if (url.isNotEmpty) {
        churchTokenData = await Authenticate.getChurchDataFromUrl(url);
        if (churchTokenData != null) {
          if (churchTokenData!.isExpired) {
            setState(() {
              isExpired = true;
              errorMessage =
                  'Sorry, this link has expired. Please request a new one.';
              isLoading = false;
            });
          } else {
            setState(() {
              church = churchTokenData!.churchName;
              image = churchTokenData!.imageUrl;
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage =
                'Invalid invitation link. Please ask for a new invitation link.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'No invitation link provided.';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading church data: $e');
      setState(() {
        errorMessage =
            'An error occurred while processing the invitation. Please try again later.';
        isLoading = false;
      });
    }
  }

  // ── preserved: join button logic ───────────────────────────────────────────
  Future<void> _handleJoin() async {
    setState(() => isLoading = true);

    if (_nameController.text.isEmpty) {
      setState(() { nameError = true; isLoading = false; });
      return;
    }

    if (_numberController.text.isEmpty) {
      alertReturn(context, 'Please enter a phone number');
      setState(() => isLoading = false);
      return;
    }

    if (!nameError) {
      ChurchItemModel? churchItemModel =
          await GeneralDataService.getChurchItemModelByUniqueId(
              churchTokenData!.uniqueChurchId!);

      if (churchItemModel?.limitReached == true) {
        setState(() => isLoading = false);
        alertReturn(context,
            'Community limit reached, please ask the leader to increase the plan limit');
        return;
      }

      ExistingUser? existingUser = await UserService.userExist(
          _numberController.text, churchTokenData!.uniqueChurchId!);

      if (existingUser != null) {
        setState(() => isLoading = false);
        alertReturn(context, 'User already exists');
        return;
      }

      if (churchTokenData!.isLeader) {
        bool? isPasswordValid = await showAdminDialog(
            context, _passwordController, churchTokenData!.uniqueChurchId!);
        if (!isPasswordValid!) {
          alertReturn(context, 'Wrong password');
          return;
        }
        await Authenticate.registerUser(
          name: _nameController.text,
          phone: _numberController.text,
          uniqueChurchId: churchTokenData!.uniqueChurchId!,
          role: churchTokenData!.role!,
        );
        snack.snack(context, 'User Registered Successfully');
        Future.delayed(const Duration(seconds: 2), () async {
          await openExternalHost();
          if (mounted) setState(() => isLoading = false);
        });
      } else {
        setState(() => isLoading = true);
        await Authenticate.registerUser(
          name: _nameController.text,
          phone: _numberController.text,
          uniqueChurchId: churchTokenData!.uniqueChurchId!,
          role: churchTokenData!.role!,
        );
        snack.snack(context, 'User Registered Successfully');
        Future.delayed(const Duration(seconds: 2), () async {
          await openExternalHost();
          if (mounted) setState(() => isLoading = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Loading state ─────────────────────────────────────────────────────
    if (isLoading && churchTokenData == null) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(
          child: CircularProgressIndicator(
              color: AppColors.purple, strokeWidth: 3),
        ),
      );
    }

    // ── Error / Expired state (v2 styled) ──────────────────────────────────
    if (errorMessage != null || isExpired) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isExpired
                        ? AppColors.orangeTint
                        : AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpired
                        ? Icons.timer_off_outlined
                        : Icons.link_off_rounded,
                    size: 38,
                    color: isExpired ? AppColors.orange : AppColors.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isExpired ? 'Link Expired' : 'Invalid Link',
                  style: AppTypography.headingLarge
                      .copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage ?? 'An unknown error occurred',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.whiteDim),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ConnectButton.ghost(
                  label: 'Sign In Instead',
                  onTap: () => Navigator.pushNamed(context, '/RegisterMember'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Main invite screen ─────────────────────────────────────────────────
    final size = MediaQuery.of(context).size;
    final shortUrl = _currentUrl.isNotEmpty
        ? _currentUrl
            .replaceFirst(RegExp(r'^https?://'), '')
            .replaceFirst('www.', '')
        : 'connect.app/join/${church.toLowerCase().replaceAll(' ', '-')}';

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Dark hero ───────────────────────────────────────────────
              SizedBox(
                height: size.height * 0.37,
                child: Stack(
                  children: [
                    // Radial glow
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              AppColors.purple.withOpacity(0.22),
                              Colors.transparent,
                            ]),
                          ),
                        ),
                      ),
                    ),
                    // Org logo + name + invited-by
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Org logo
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: AppColors.purpleCardGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purple.withOpacity(0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.hub_outlined,
                            size: 38,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Org name
                        Text(
                          church.isNotEmpty ? church : 'Your Community',
                          style: AppTypography.screenTitle
                              .copyWith(fontSize: 22, letterSpacing: -0.6),
                        ),
                        const SizedBox(height: 8),
                        // Invited-by row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.avatarNewMember,
                              ),
                              alignment: Alignment.center,
                              child: Text('JD',
                                  style: AppTypography.caption.copyWith(
                                      color: AppColors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              "Invited to join",
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.whiteDim),
                            ),
                          ],
                        ),
                        const SizedBox(height: 34),
                      ],
                    ),
                  ],
                ),
              ),

              // ── White card ───────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusBottomSheet)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 68, 22, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Complete your profile',
                            style: AppTypography.headingLarge
                                .copyWith(fontSize: 19, letterSpacing: -0.4)),
                        const SizedBox(height: 5),
                        Text(
                          'Fill in your details to join ${church.isNotEmpty ? church : 'the community'}',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 20),

                        // Full Name
                        Text('FULL NAME', style: AppTypography.fieldLabel),
                        const SizedBox(height: 7),
                        _InviteField(
                          controller: _nameController,
                          icon: Icons.person_outline_rounded,
                          hint: 'Your full name',
                          active: true,
                          hasError: nameError,
                          onChanged: (_) {
                            if (nameError) setState(() => nameError = false);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Phone Number
                        Text('PHONE NUMBER', style: AppTypography.fieldLabel),
                        const SizedBox(height: 7),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusInput),
                            border: Border.all(
                                color: AppColors.surfaceAlt, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          child: IntlPhoneField(
                            initialCountryCode: 'ZA',
                            onChanged: (phone) =>
                                _numberController.text = phone.completeNumber,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 4),
                              counterText: '',
                              hintText: '+27 8X XXX XXXX',
                              hintStyle: AppTypography.fieldPlaceholder,
                            ),
                            style: AppTypography.fieldValue,
                            dropdownTextStyle: AppTypography.fieldValue,
                            flagsButtonPadding:
                                const EdgeInsets.only(right: 8),
                            dropdownIconPosition: IconPosition.trailing,
                            showDropdownIcon: true,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Gender
                        Text('GENDER', style: AppTypography.fieldLabel),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            'Male', 'Female', 'Other',
                          ].asMap().entries.map((e) {
                            final i = e.key;
                            final label = e.value;
                            final sel = _selectedGenderIndex == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedGenderIndex = i),
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: i < 2 ? 10 : 0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? AppColors.navy
                                        : AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(50),
                                    border: Border.all(
                                      color: sel
                                          ? AppColors.navy
                                          : AppColors.surfaceAlt,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: sel
                                          ? AppColors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Terms
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                height: 1.6),
                            children: [
                              const TextSpan(
                                  text: 'By joining you agree to the '),
                              TextSpan(
                                text: 'Community Guidelines',
                                style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    color: AppColors.purple,
                                    fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    color: AppColors.purple,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Join button
                        ConnectButton.primary(
                          label: 'Join Community  \u2192',
                          isLoading: isLoading,
                          onTap: isLoading ? null : _handleJoin,
                        ),
                        const SizedBox(height: 12),

                        // Already a member
                        Center(
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/RegisterMember'),
                            child: RichText(
                              text: TextSpan(
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textMuted, fontSize: 13),
                                children: [
                                  const TextSpan(text: 'Already a member? '),
                                  TextSpan(
                                    text: 'Sign in',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontSize: 13,
                                      color: AppColors.purple,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Invite link chip — overlaps hero/card boundary ───────────────
          Positioned(
            top: size.height * 0.37 - 26,
            left: 28,
            right: 28,
            child: _LinkChip(url: shortUrl),
          ),

          // Loading overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.purple, strokeWidth: 3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Invite link chip ──────────────────────────────────────────────────────────
class _LinkChip extends StatelessWidget {
  final String url;
  const _LinkChip({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.25),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.link_rounded,
                size: 14, color: AppColors.whiteDim),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                  color: AppColors.whiteDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: url)),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.purpleTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Copy',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Styled input field ────────────────────────────────────────────────────────
class _InviteField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool active;
  final bool hasError;
  final Function(String)? onChanged;

  const _InviteField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.active = false,
    this.hasError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFDFCFF) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(
          color: hasError
              ? AppColors.error
              : active
                  ? AppColors.purple
                  : AppColors.surfaceAlt,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.purpleBadge,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppColors.purple),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTypography.fieldPlaceholder,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: AppTypography.fieldValue,
            ),
          ),
        ],
      ),
    );
  }
}
