import 'dart:async';
import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/providers/registration_provider.dart';
import 'package:master/databases/database.dart';
import 'package:provider/provider.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_button.dart';
import 'package:master/widgets/common/connect_text_field.dart';
import '../../profile/profile_screen.dart';

class CodeAppwrite extends StatefulWidget {
  const CodeAppwrite({super.key});
  @override
  State<CodeAppwrite> createState() => _CodeAppwriteState();
}

class _CodeAppwriteState extends State<CodeAppwrite> {
  // ── preserved ─────────────────────────────────────────────────────────────
  Authenticate auth = Authenticate();
  bool isLoading = false;
  bool showResendButton = false;
  String code = '';
  TextEditingController controllerCode = TextEditingController();

  // ── countdown timer (replaces 8s Future.delayed with full countdown) ──────
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    showResendButton = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() { _secondsLeft = 0; showResendButton = true; });
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdownLabel {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _maskPhone(String phone) {
    if (phone.length < 6) return phone;
    final head = phone.substring(0, phone.length > 8 ? 8 : phone.length - 2);
    final tail = phone.substring(phone.length - 2);
    return '$head *** **$tail';
  }

  @override
  Widget build(BuildContext context) {
    final phone = Provider.of<RegistrationProvider>(context, listen: false)
            .registrationModel
            .phoneNumber ??
        '';
    final maskedPhone = phone.isNotEmpty ? _maskPhone(phone) : 'your number';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Back button ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left_rounded,
                              size: 20, color: AppColors.textMid),
                          Text('Back',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMid,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Shield icon in circle
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.purpleTint,
                          ),
                          child: Icon(
                            Icons.verified_user_outlined,
                            size: 44,
                            color: AppColors.purple,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Heading
                        Text('Check your SMS',
                            style: AppTypography.headingLarge
                                .copyWith(fontSize: 22)),
                        const SizedBox(height: 10),
                        Text(
                          "We've sent a 6-digit verification code to",
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          maskedPhone,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // OTP boxes — preserved: onCompleted sets code
                        ConnectOtpField(
                          length: 6,
                          onChanged: (val) => code = val,
                          onCompleted: (val) => code = val,
                        ),
                        const SizedBox(height: 18),

                        // Resend row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Resend code in ',
                                style: AppTypography.caption
                                    .copyWith(fontSize: 12)),
                            if (!showResendButton)
                              Text(
                                _countdownLabel,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 12,
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: showResendButton
                                  ? () async {
                                      setState(() => isLoading = true);
                                      await Authenticate.resendOtp(context);
                                      if (mounted) {
                                        setState(() => isLoading = false);
                                        _startTimer();
                                      }
                                    }
                                  : null,
                              child: Text(
                                'Resend',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: showResendButton
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Verify button — preserved: Authenticate.submitCode
                        ConnectButton.purple(
                          label: 'Verify  \u2192',
                          isLoading: isLoading,
                          onTap: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  await Authenticate.submitCode(context, code);
                                  Future.delayed(
                                      const Duration(seconds: 3), () {
                                    if (mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  });
                                },
                        ),
                        const SizedBox(height: 24),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Stack(
                            children: [
                              Container(
                                height: 5,
                                color: AppColors.surfaceAlt,
                              ),
                              FractionallySizedBox(
                                widthFactor: 0.66,
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.purple,
                                        AppColors.orange,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Step 2 of 3  \u2022  66% complete',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay — preserved
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
