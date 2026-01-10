import 'package:flutter/material.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/classes/church_init.dart';
import 'package:master/componants/share_dialog.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/services/api/auth_service.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/util/alerts.dart';
import 'package:provider/provider.dart';

class InvitationService {
  /// Generates an invitation token for the specified role
  ///
  /// [isAdmin] - Whether to generate an admin or member token
  /// Returns a map containing the token and success status
  static Future<Map<String, dynamic>> generateInvitation(BuildContext context,
      {required bool isAdmin}) async {
    try {
      // Get the selected church ID

      TokenUser? user = await TokenService.tokenUser();

      if (user?.uniqueChurchId == null) {
        return {
          'success': false,
          'error': 'No church',
        };
      }

      // Generate the invitation token
      final result = await AuthService.generateInvitationToken(
        uniqueChurchId: user!.uniqueChurchId!,
        role: isAdmin ? 'ADMIN' : 'MEMBER',
      );

      if (result == null || result['success'] != true) {
        return {
          'success': false,
          'error': result?['error'] ?? 'Failed to generate invitation',
        };
      }

      // Return the generated token
      return {
        'success': true,
        'token': result['token'],
        'invitationUrl':
            'http://localhost:54306/joinChurch?token=${result['token']}',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: $e',
      };
    }
  }

  /// Gets the share text for the invitation
  static String getShareText(String role, String churchName) {
    return 'Join $churchName on our app as a $role! '
        'Click the link to get started: ';
  }

  static Future<void> shareInvitation(BuildContext context) async {
    try {
      // Get the current admin status
      final isAdmin = ChurchInit.visibilityToggle(context);

      final result = await InvitationService.generateInvitation(
        context,
        isAdmin: isAdmin,
      );

      if (result['success'] == true) {
        final shareUrl = result['invitationUrl'];
        if (context.mounted) {
          showShareDialog(context, isAdmin: isAdmin, shareUrl: shareUrl);
        }
      } else {
        final error = result['error'] ?? 'Failed to generate invitation';
        if (context.mounted) {
          alertReturn(context, "Error: $error");
        }
      }
    } catch (e) {
      if (context.mounted) {
        alertReturn(context, "An error occurred: $e");
      }
    }
  }
}
