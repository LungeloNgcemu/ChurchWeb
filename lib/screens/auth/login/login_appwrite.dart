import 'package:flutter/material.dart';
import 'package:master/databases/database.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginAppwrite extends StatefulWidget {
  const LoginAppwrite({super.key});

  @override
  State<LoginAppwrite> createState() => _LoginAppwriteState();
}

class _LoginAppwriteState extends State<LoginAppwrite> {
  // ── preserved ─────────────────────────────────────────────────────────────
  final _controllerA = TextEditingController();
  final _controllerB = TextEditingController();
  String email = '';
  String password = '';

  @override
  void initState() {
    signOut();
    super.initState();
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    super.dispose();
  }

  // ── preserved: sign out ───────────────────────────────────────────────────
  void signOut() async {
    // AppWriteDataBase connect = AppWriteDataBase();
    // await connect.account.deleteSessions();
    print("Session Refreshed");
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          // Top dark navy hero
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              gradient: AppColors.purpleHeaderGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleCardGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hub_outlined,
                          size: 20, color: AppColors.white),
                    ),
                    const SizedBox(height: 32),
                    Text('Sign In',
                        style: AppTypography.headingLarge.copyWith(
                          color: AppColors.white,
                          fontSize: 32,
                        )),
                    const SizedBox(height: 8),
                    Text('Welcome back to Connect',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.whiteDim,
                        )),
                  ],
                ),
              ),
            ),
          ),

          // White card slides up
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.38,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EMAIL', style: AppTypography.fieldLabel),
                    const SizedBox(height: 7),
                    _LoginField(
                      controller: _controllerA,
                      hint: 'you@example.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => email = v,
                    ),
                    const SizedBox(height: 16),
                    Text('PASSWORD', style: AppTypography.fieldLabel),
                    const SizedBox(height: 7),
                    _LoginField(
                      controller: _controllerB,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      onChanged: (v) => password = v,
                    ),
                    const SizedBox(height: 28),
                    // ── preserved: login button with try/catch ──────────
                    ConnectButton.primary(
                      label: 'Sign In  →',
                      isLoading: _isLoading,
                      onTap: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              try {
                                // AppWriteDataBase connect = AppWriteDataBase();
                                // final session = await connect.account
                                //     .createEmailSession(
                                //       email: email, password: password);
                                // if (session != null) {
                                //   Navigator.pushNamed(context, '/salon');
                                // }
                              } catch (e) {
                                Alert(
                                  context: context,
                                  type: AlertType.error,
                                  title: "Wrong Login Details",
                                  desc:
                                      "Please type in the right detail or contact the Developer.",
                                  buttons: [
                                    DialogButton(
                                      child: const Text("Retry",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18)),
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      width: 120,
                                    )
                                  ],
                                ).show();
                              }
                              setState(() => _isLoading = false);
                              _controllerA.clear();
                              _controllerB.clear();
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  const _LoginField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1917),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
