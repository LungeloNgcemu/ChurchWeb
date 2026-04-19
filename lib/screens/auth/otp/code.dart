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
import 'package:master/widgets/common/connect_loader.dart';

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

  // ── countdown timer ────────────────────────────────────────────────────────
  int _secondsLeft = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 20;
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

                        // ── Resend / call row ────────────────────────────
                        if (!showResendButton) ...[
                          // Countdown still running
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Resend code in ',
                                  style: AppTypography.caption
                                      .copyWith(fontSize: 12)),
                              Text(
                                _countdownLabel,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 12,
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Timer expired — show both options
                          Column(
                            children: [
                              // Resend SMS
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Didn't get it? ",
                                      style: AppTypography.caption
                                          .copyWith(fontSize: 12)),
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() => isLoading = true);
                                      await Authenticate.resendOtp(context);
                                      if (mounted) {
                                        setState(() => isLoading = false);
                                        _startTimer();
                                      }
                                    },
                                    child: Text(
                                      'Resend SMS',
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.purple,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Get a call button
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () async {
                                        setState(() => isLoading = true);
                                        final error =
                                            await Authenticate.requestVoiceOtp(
                                                context);
                                        if (mounted) {
                                          setState(() => isLoading = false);
                                          if (error == null) {
                                            _startTimer();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    '📞 Calling you now with your code…'),
                                                backgroundColor: AppColors.navy,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                margin:
                                                    const EdgeInsets.all(16),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(error),
                                                backgroundColor:
                                                    AppColors.error,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                margin:
                                                    const EdgeInsets.all(16),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 13),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.purple, width: 1.5),
                                    borderRadius: BorderRadius.circular(50),
                                    color: AppColors.purpleTint,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.phone_outlined,
                                          size: 18, color: AppColors.purple),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Get a call instead',
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                  child: ConnectLoader(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
