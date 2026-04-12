import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/Model/existing_user_model.dart';
import 'package:master/classes/restrictions.dart';
import 'package:master/classes/sql_database.dart';
import 'package:master/componants/multi_church_select.dart';
import 'package:master/constants/constants.dart';
import 'package:master/databases/database.dart';
import 'package:master/providers/registration_provider.dart';
import 'package:master/services/api/general_data_service.dart';
import 'package:master/util/alerts.dart';
import 'package:provider/provider.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_button.dart';
import 'package:master/widgets/common/connect_app_icon.dart';
import '../../../classes/authentication/authenticate.dart';

class RegisterMember extends StatefulWidget {
  const RegisterMember({super.key});
  @override
  State<RegisterMember> createState() => _RegisterMemberState();
}

class _RegisterMemberState extends State<RegisterMember> {
  Authenticate auth = Authenticate();
  Restrictions restrict = Restrictions();
  List<ChurchItemModel> names_of_churches = [];
  SqlDatabase sql = SqlDatabase();
  String number = '';
  bool isLoading = false;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerNumber = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerCode = TextEditingController();
  final TextEditingController churchController = TextEditingController();

  @override
  void initState() {
    churchListInit(context);
    auth.role = "Member";
    super.initState();
  }

  Future<void> churchListInit(BuildContext context) async {
    setState(() => isLoading = true);
    final List<ChurchItemModel> list = await GeneralDataService.getChurches();
    setState(() => names_of_churches = list);
    print(names_of_churches);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  Future<void> _handleSendCode() async {
    if (number != '') {
      List<ExistingUser>? users =
          await Authenticate.getUserFromPhoneNumber(number);
      if (users != null) {
        if (users.isEmpty) {
          alertReturn(context, 'Your Number is not linked to any church');
          setState(() => isLoading = false);
          return;
        }
        if (users.length > 1) {
          final selectedUser =
              await showChurchSelectDialog(context, users, (user) {
            Navigator.pop(context, user);
          });
          if (selectedUser?.role == Role.admin) {
            bool? ok = await showAdminDialog(context, TextEditingController(),
                selectedUser!.uniqueChurchId!);
            if (ok == null) return;
            if (!ok) {
              alertReturn(context, "Wrong Password");
              return;
            }
          }
          if (selectedUser != null) {
            Provider.of<RegistrationProvider>(context, listen: false)
                .registrationModel
                .uniqueChurchId = selectedUser.uniqueChurchId;
            Provider.of<RegistrationProvider>(context, listen: false)
                .registrationModel
                .role = selectedUser.role;
            ChurchItemModel? item = await GeneralDataService
                .getChurchItemModelByUniqueId(selectedUser.uniqueChurchId!);
            if (item != null) {
              await SqlDatabase.insertChurcItem(churchItem: item);
            } else {
              alertReturn(context, 'Church Not Found');
            }
            setState(() => isLoading = true);
            await Authenticate.authenticate(context);
            setState(() => isLoading = false);
          }
        } else {
          setState(() => isLoading = true);
          Provider.of<RegistrationProvider>(context, listen: false)
              .registrationModel
              .uniqueChurchId = users.first.uniqueChurchId;
          Provider.of<RegistrationProvider>(context, listen: false)
              .registrationModel
              .role = users.first.role;
          if (users.first.role == Role.admin) {
            bool? ok = await showAdminDialog(context, TextEditingController(),
                users.first.uniqueChurchId!);
            if (ok == null) return;
            if (!ok) {
              alertReturn(context, "Wrong Password");
              return;
            }
          }
          ChurchItemModel? item = await GeneralDataService
              .getChurchItemModelByUniqueId(users.first.uniqueChurchId!);
          if (item != null) {
            await SqlDatabase.insertChurcItem(churchItem: item);
          } else {
            alertReturn(context, 'Church Not Found');
          }
          await Authenticate.authenticate(context);
          setState(() => isLoading = false);
        }
      } else {
        alertReturn(context, 'User Not Found');
      }
    } else {
      alertReturn(context, 'Please add a phone number');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          Column(
            children: [
              // Top dark hero
              SizedBox(
                height: size.height * 0.38,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              AppColors.purple.withOpacity(0.24),
                              Colors.transparent,
                            ]),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const ConnectAppIcon(size: 64),
                          const SizedBox(height: 18),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'Welcome Back',
                                style: AppTypography.wordmark
                                    .copyWith(fontSize: 28),
                              ),
                              TextSpan(
                                text: '.',
                                style: AppTypography.wordmark.copyWith(
                                    fontSize: 28, color: AppColors.purple),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to your community',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.whiteDim,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom white card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusBottomSheet)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter your number',
                            style: AppTypography.headingLarge),
                        const SizedBox(height: 6),
                        Text(
                          "We'll send a one-time code to verify your identity",
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: 22),
                        Text('PHONE NUMBER', style: AppTypography.fieldLabel),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInput),
                            border: Border.all(
                                color: AppColors.surfaceAlt, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          child: IntlPhoneField(
                            initialCountryCode: 'ZA',
                            onChanged: (phone) {
                              Provider.of<RegistrationProvider>(context,
                                      listen: false)
                                  .registrationModel
                                  .phoneNumber = phone.completeNumber;
                              number = phone.completeNumber;
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
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 6),
                                child: Icon(Icons.phone_outlined,
                                    size: 16, color: AppColors.textMuted),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 28, minHeight: 0),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.purpleTint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 16, color: AppColors.purple),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'A 6-digit code will be sent to this number via SMS',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.purple,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        ConnectButton.purple(
                          label: 'Send Code  \u2192',
                          onTap: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  await _handleSendCode();
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                },
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                              child: Divider(color: AppColors.surfaceAlt)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('or continue with',
                                style: AppTypography.caption
                                    .copyWith(color: AppColors.textMuted)),
                          ),
                          Expanded(
                              child: Divider(color: AppColors.surfaceAlt)),
                        ]),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(
                            child: _SocialButton(
                              label: 'Google',
                              icon: const Text('G',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: Color(0xFF4285F4))),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              label: 'Facebook',
                              icon: const Icon(Icons.facebook_rounded,
                                  color: Color(0xFF1877F2), size: 20),
                              onTap: () {},
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  const _SocialButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          border: Border.all(color: AppColors.surfaceAlt, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label,
                style: AppTypography.cardTitle.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
