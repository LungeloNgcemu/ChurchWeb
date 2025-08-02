import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class OtpAuth {
  Future<void> superbaseOtpLogin(SupabaseClient supabase, String number) async {
    try {
      await supabase.auth.signInWithOtp(
        channel: OtpChannel. sms,
        phone: number,
      );
    } catch (error) {
      print('Error creating code for number :$error');
    }
  }

  Future<User?> superbaseVerifyOtpLogin(
      SupabaseClient supabase, String number, String code) async {
    User? user;
    try {
      AuthResponse res = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: code,
        phone: number,
      );

      user = res.user;
    } catch (error) {
      print('User auth error');
    }

    return user;
  }

  void superbaseResendOtpLogin(SupabaseClient supabase) async {
    final ResendResponse res = await supabase.auth.resend(
      type: OtpType.signup,
      email: 'email@example.com',
    );
  }

  void superbaseSignOut(SupabaseClient supabase) async {
    await supabase.auth.signOut();
  }
}
