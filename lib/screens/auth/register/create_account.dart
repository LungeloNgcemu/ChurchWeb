import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/util/alerts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_button.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});
  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  // ── preserved ─────────────────────────────────────────────────────────────
  final supabase = Supabase.instance.client;
  Authenticate auth = Authenticate();

  final controller1 = TextEditingController(); // Full Name
  final controller2 = TextEditingController(); // Org Name
  final controller3 = TextEditingController(); // Vision / About
  final controller4 = TextEditingController(); // Mission
  final controller6 = TextEditingController(); // Email
  final controller7 = TextEditingController(); // Address
  final controller8 = TextEditingController(); // Passcode

  String name = '';
  String churchName = '';
  String vision = '';
  String mission = '';
  String phoneNumber = '';
  String email = '';
  String address = '';
  String password = '';
  String number = '';

  bool churchExist = false;
  bool numberExist = false;
  bool isLoading = false;

  // ── new state ──────────────────────────────────────────────────────────────
  int _selectedType = 0; // org type chip index

  static const _types = [
    ('\u{1F3DB}', 'Community', 'Neighbourhood & social'),
    ('\u{1F3E2}', 'Corporate', 'Workplace groups'),
    ('\u{1F393}', 'Education', 'Schools & colleges'),
    ('\u2764\uFE0F', 'Non-Profit', 'Charity & causes'),
  ];

  void clearEditor() {
    for (final c in [
      controller1,
      controller2,
      controller3,
      controller4,
      controller6,
      controller7,
      controller8,
    ]) {
      c.clear();
    }
  }

  // ── preserved: Supabase validation helpers ─────────────────────────────────
  Future<void> searchChurchName(churchName) async {
    try {
      final church = await supabase
          .from('Church')
          .select('ChurchName')
          .eq('ChurchName', churchName)
          .single();
      if (!church.isEmpty) setState(() => churchExist = true);
    } catch (_) {
      print('Church doesnt exist error');
    }
  }

  Future<void> searchChurcNumber(numberIn) async {
    try {
      final n = await supabase
          .from('Church')
          .select('PhoneNumber')
          .eq('PhoneNumber', numberIn)
          .single();
      if (!n.isEmpty) setState(() => numberExist = true);
    } catch (_) {
      print('Church doesnt exist error');
    }
  }

  // ── preserved: registerOrganisation flow ──────────────────────────────────
  void _registerChurch() async {
    final result = await Authenticate.registerOrginisationAndUser(
        name, email, phoneNumber, churchName, address, vision, mission,
        password);
    if (result) {
      const message =
          'Organisation successfully registered. You will be redirected to the sign-in screen.';
      await alertSuccess(context, message);
      clearEditor();
      Navigator.pushNamed(context, '/RegisterMember');
    } else {
      const message = 'Something went wrong with registration. Please try again.';
      await alertReturn(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Dark header with step indicator ─────────────────────────
              Container(
                color: AppColors.navy,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('STEP 1 OF 3',
                                style: AppTypography.caption.copyWith(
                                    color: AppColors.whiteDim,
                                    letterSpacing: 0.5)),
                            Row(
                              children: List.generate(3, (i) {
                                return Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  width: i == 0 ? 32 : 24,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: i == 0
                                        ? AppColors.purple
                                        : AppColors.purple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Your Organisation',
                            style: AppTypography.screenTitle
                                .copyWith(fontSize: 22)),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Scrollable form body ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Full Name ─────────────────────────────────────────
                      Text('YOUR NAME', style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      _Field(
                        controller: controller1,
                        icon: Icons.person_outline_rounded,
                        hint: 'Full name',
                        onChanged: (v) => name = v,
                      ),
                      const SizedBox(height: 14),

                      // ── Organisation Name ─────────────────────────────────
                      Text('ORGANISATION NAME',
                          style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      _Field(
                        controller: controller2,
                        icon: Icons.business_outlined,
                        hint: 'e.g. Sunrise Community',
                        onChanged: (v) => churchName = v,
                        active: true,
                      ),
                      const SizedBox(height: 14),

                      // ── Organisation Type ─────────────────────────────────
                      Text('ORGANISATION TYPE',
                          style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.2,
                        children: List.generate(_types.length, (i) {
                          final (emoji, title, sub) = _types[i];
                          final sel = _selectedType == i;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = i),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.purpleTint
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: sel
                                      ? AppColors.purple
                                      : AppColors.surfaceAlt,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(emoji,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          title,
                                          style: AppTypography.cardTitle
                                              .copyWith(
                                            fontSize: 12,
                                            color: sel
                                                ? AppColors.purple
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(sub,
                                            style:
                                                AppTypography.caption.copyWith(
                                              fontSize: 10,
                                              color: AppColors.textMuted,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),

                      // ── About / Description ───────────────────────────────
                      Text('ABOUT YOUR ORGANISATION',
                          style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusInput),
                          border: Border.all(
                              color: AppColors.surfaceAlt, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: TextField(
                          controller: controller3,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Tell people what your organisation is about and what members can expect...',
                            hintStyle: AppTypography.fieldPlaceholder
                                .copyWith(height: 1.6),
                          ),
                          style: AppTypography.fieldValue.copyWith(height: 1.6),
                          onChanged: (v) => vision = v,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Mission ───────────────────────────────────────────
                      Text('MISSION STATEMENT',
                          style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      _Field(
                        controller: controller4,
                        icon: Icons.flag_outlined,
                        hint: 'Our mission is to...',
                        onChanged: (v) => mission = v,
                      ),
                      const SizedBox(height: 14),

                      // ── Phone ─────────────────────────────────────────────
                      Text('CONTACT NUMBER', style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
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
                          onChanged: (phone) {
                            number = phone.completeNumber;
                            phoneNumber = phone.completeNumber;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 4),
                            counterText: '',
                            hintText: '82 345 6789',
                            hintStyle: AppTypography.fieldPlaceholder,
                          ),
                          style: AppTypography.fieldValue,
                          dropdownTextStyle: AppTypography.fieldValue,
                          flagsButtonPadding: const EdgeInsets.only(right: 8),
                          dropdownIconPosition: IconPosition.trailing,
                          showDropdownIcon: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Email ─────────────────────────────────────────────
                      Text('CONTACT EMAIL', style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      _Field(
                        controller: controller6,
                        icon: Icons.email_outlined,
                        hint: 'hello@yourorg.com',
                        keyboard: TextInputType.emailAddress,
                        onChanged: (v) => email = v,
                      ),
                      const SizedBox(height: 14),

                      // ── Address ───────────────────────────────────────────
                      Text('ADDRESS', style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      _Field(
                        controller: controller7,
                        icon: Icons.location_on_outlined,
                        hint: 'Organisation address',
                        onChanged: (v) => address = v,
                      ),
                      const SizedBox(height: 14),

                      // ── Passcode ──────────────────────────────────────────
                      Text('ORGANISATION PASSCODE',
                          style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      _Field(
                        controller: controller8,
                        icon: Icons.lock_outline_rounded,
                        hint: 'Leaders use this to join',
                        obscure: true,
                        onChanged: (v) => password = v,
                      ),
                      const SizedBox(height: 28),

                      // ── CTA ───────────────────────────────────────────────
                      ConnectButton.primary(
                        label: 'Continue  \u2192',
                        isLoading: isLoading,
                        onTap: isLoading
                            ? null
                            : () {
                                setState(() {
                                  name = controller1.text;
                                  churchName = controller2.text;
                                  vision = controller3.text;
                                  mission = controller4.text;
                                  phoneNumber = number;
                                  email = controller6.text;
                                  address = controller7.text;
                                  password = controller8.text;
                                });

                                if (name.isNotEmpty &&
                                    churchName.isNotEmpty &&
                                    vision.isNotEmpty &&
                                    mission.isNotEmpty &&
                                    phoneNumber.isNotEmpty &&
                                    email.isNotEmpty &&
                                    address.isNotEmpty &&
                                    password.isNotEmpty) {
                                  setState(() => isLoading = true);
                                  _registerChurch();
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    setState(() {
                                      churchExist = false;
                                      numberExist = false;
                                      isLoading = false;
                                    });
                                  });
                                } else {
                                  alertReturn(
                                      context, 'Please fill in all fields.');
                                }
                              },
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Step 1 of 3 \u00B7 Organisation Details',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay — preserved
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.45),
                child: const Center(
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

// ── Reusable styled form field ─────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final Function(String)? onChanged;
  final TextInputType keyboard;
  final bool obscure;
  final bool active;

  const _Field({
    required this.controller,
    required this.icon,
    required this.hint,
    this.onChanged,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFDFCFF) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(
          color: active ? AppColors.purple : AppColors.surfaceAlt,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.purpleTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              obscureText: obscure,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTypography.fieldPlaceholder,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
              style: AppTypography.fieldValue,
            ),
          ),
        ],
      ),
    );
  }
}
