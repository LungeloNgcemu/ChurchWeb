import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:master/Model/churchItemModel.dart';
import 'package:master/classes/restrictions.dart';
import 'package:master/classes/sql_database.dart';
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
import '../../../classes/authentication/authenticate.dart';
import 'widgets/drop_search.dart';

class RegisterLeader extends StatefulWidget {
  const RegisterLeader({super.key});
  @override
  State<RegisterLeader> createState() => _RegisterLeaderState();
}

class _RegisterLeaderState extends State<RegisterLeader> {
  // ── preserved ─────────────────────────────────────────────────────────────
  Authenticate auth = Authenticate();
  List<ChurchItemModel> names_of_churches = [];
  Restrictions restrict = Restrictions();
  SqlDatabase sql = SqlDatabase();

  String userName = '';
  String number = '';
  bool isLoading = false;

  TextEditingController controllerName = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController churchController = TextEditingController();

  final List<String> items = ['Male', 'Female'];

  // ── new state for v2 UI ────────────────────────────────────────────────────
  int _selectedRole = 0; // 0=Leader,1=Coordinator,2=Moderator
  int _selectedGender = 0; // 0=Male,1=Female,2=Other

  static const _roles = [
    ('Leader', 'Full access — manage members, posts & events'),
    ('Coordinator', 'Organise events and moderate content'),
    ('Moderator', 'Review and approve member posts'),
  ];
  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    churchListInit(context);
    auth.role = 'Admin';
    super.initState();
  }

  Future<void> churchListInit(BuildContext context) async {
    setState(() => isLoading = true);
    final list = await GeneralDataService.getChurches();
    setState(() => names_of_churches = list);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  // ── preserved: exact logic from original ExtraButton callback ──────────────
  Future<void> _handleJoin() async {
    final regData = Provider.of<RegistrationProvider>(context, listen: false)
        .registrationModel;
    final selectedChurch =
        Provider.of<SelectedChurchProvider>(context, listen: false)
            .selectedChurch;

    if (regData.uniqueChurchId != '' && regData.uniqueChurchId != null) {
      setState(() => isLoading = true);
      SqlDatabase.insertChurcItem(churchItem: selectedChurch);
      if (number.isNotEmpty) {
        final canAdd = await Restrictions.restrictionAlgorithm(
            number: number, selectedChurch: selectedChurch);
        if (canAdd) {
          await Authenticate.authenticate(context);
          Future.delayed(const Duration(seconds: 1), () {
            controllerName.clear();
            codeController.clear();
          });
        } else {
          alertReturn(context,
              'The community plan is currently full, please contact the owner to increase the plan');
        }
      } else {
        alertReturn(context, 'Please add a phone number');
      }
      Future.delayed(const Duration(seconds: 2),
          () => setState(() => isLoading = false));
    } else {
      alertReturn(context, 'Please select a community');
    }
    Future.delayed(
        const Duration(seconds: 5), () => setState(() => isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Dark header ──────────────────────────────────────────────
              Container(
                color: AppColors.navy,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back row
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chevron_left_rounded,
                                  size: 18,
                                  color: AppColors.whiteDim),
                              Text('Back',
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.whiteDim,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Leader Access" badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        AppColors.purple.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 10, color: Color(0xFFC4B5FD)),
                                  const SizedBox(width: 5),
                                  Text('Leader Access',
                                      style: AppTypography.badge.copyWith(
                                          color: const Color(0xFFC4B5FD))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Set Up Your Role',
                                style: AppTypography.screenTitle
                                    .copyWith(fontSize: 24)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Name field ────────────────────────────────────────
                      Text('FULL NAME', style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      _FieldBox(
                        icon: Icons.person_outline_rounded,
                        child: TextField(
                          controller: controllerName,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Your name',
                            hintStyle: AppTypography.fieldPlaceholder,
                          ),
                          style: AppTypography.fieldValue,
                          onChanged: (v) {
                            Provider.of<RegistrationProvider>(context,
                                    listen: false)
                                .registrationModel
                                .userName = v;
                            userName = v;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Role chips ────────────────────────────────────────
                      Text('YOUR ROLE', style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(_roles.length, (i) {
                          final (title, sub) = _roles[i];
                          final sel = _selectedRole == i;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedRole = i);
                              Provider.of<RegistrationProvider>(context,
                                      listen: false)
                                  .registrationModel
                                  .role = Role.admin;
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.purpleTint
                                    : AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: sel
                                      ? AppColors.purple
                                      : AppColors.surfaceAlt,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: sel
                                          ? AppColors.purple
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: sel
                                            ? AppColors.purple
                                            : AppColors.surfaceAlt,
                                        width: 2,
                                      ),
                                    ),
                                    child: sel
                                        ? const Icon(Icons.check_rounded,
                                            size: 10,
                                            color: AppColors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: AppTypography.cardTitle
                                              .copyWith(
                                                  color: sel
                                                      ? AppColors.purple
                                                      : AppColors
                                                          .textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(sub,
                                            style: AppTypography.caption
                                                .copyWith(
                                                    color: AppColors
                                                        .textMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // ── Gender ────────────────────────────────────────────
                      Text('GENDER', style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(_genders.length, (i) {
                          final sel = _selectedGender == i;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedGender = i),
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: i < _genders.length - 1 ? 8 : 0),
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
                                  _genders[i],
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
                        }),
                      ),
                      const SizedBox(height: 16),

                      // ── Phone number ──────────────────────────────────────
                      Text('PHONE NUMBER', style: AppTypography.fieldLabel),
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
                          ),
                          style: AppTypography.fieldValue,
                          dropdownTextStyle: AppTypography.fieldValue,
                          flagsButtonPadding: const EdgeInsets.only(right: 8),
                          dropdownIconPosition: IconPosition.trailing,
                          showDropdownIcon: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Community search (preserved from original) ────────
                      Text('SELECT COMMUNITY', style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      auth.dropSearch(
                          context, names_of_churches, setState, churchController),
                      const SizedBox(height: 16),

                      // ── Org access code ───────────────────────────────────
                      Text('ORGANISATION ACCESS CODE',
                          style: AppTypography.fieldLabel),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusInput),
                          border: Border.all(
                              color: const Color(0xFFFED7AA), width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.lock_outline_rounded,
                                  size: 16, color: AppColors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: codeController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter access code',
                                  hintStyle: AppTypography.fieldPlaceholder,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: AppTypography.fieldValue.copyWith(
                                    letterSpacing: 2),
                                onChanged: (v) {
                                  Provider.of<RegistrationProvider>(context,
                                          listen: false)
                                      .registrationModel
                                      .password = v;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── CTA button ────────────────────────────────────────
                      ConnectButton.orange(
                        label: 'Join as Leader  \u2192',
                        isLoading: isLoading,
                        onTap: isLoading ? null : _handleJoin,
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

// ── Shared field container ─────────────────────────────────────────────────
class _FieldBox extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _FieldBox({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(color: AppColors.surfaceAlt, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}
