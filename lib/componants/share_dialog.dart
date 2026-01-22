import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/services/api/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showShareDialog(BuildContext context,
    {required bool isAdmin, String? shareUrlA, String? shareUrlB}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      bool copyDone = false;
      bool isAdminLink = false; // Track which link is being copied

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Share Invite',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Member Link Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                        child: Text('Member Access',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: Text(copyDone && !isAdminLink
                            ? 'Link copied'
                            : 'Copy member link'),
                        onTap: () async {
                          // Replace with your actual member share link
                          String memberLink = shareUrlB!;
                          await Clipboard.setData(
                              ClipboardData(text: memberLink));
                          setState(() {
                            copyDone = true;
                            isAdminLink = false;
                          });
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Share member link via...'),
                        onTap: () async {
                          final uri = Uri.parse(shareUrlB!);
                          final params = ShareParams(uri: uri);
                          await SharePlus.instance.share(params).then((_) {
                            if (context.mounted) Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  ),

                  // Admin Link Section (only shown if user is admin)
                  if (isAdmin) ...[
                    const Divider(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16),
                          child: Text('Admin Access',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings),
                          title: Text(copyDone && isAdminLink
                              ? 'Link copied'
                              : 'Copy admin link'),
                          onTap: () async {
                            // Replace with your actual admin share link
                            await Clipboard.setData(
                                ClipboardData(text: shareUrlA!));
                            setState(() {
                              copyDone = true;
                              isAdminLink = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ],

                  const Divider(),

                  // Share options for admin link (only shown to admins)
                  if (isAdmin)
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Share admin link via...'),
                      onTap: () async {
                        final uri = Uri.parse(shareUrlA!);
                        final params = ShareParams(uri: uri);
                        await SharePlus.instance.share(params).then((_) {
                          if (context.mounted) Navigator.pop(context);
                        });
                      },
                    ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
