import 'package:flutter/material.dart';
import 'package:master/Model/existing_user_model.dart';
import 'package:master/componants/extrabutton.dart';
import 'package:master/screens/auth/register/register_leader.dart';
import 'package:master/services/api/auth_service.dart';
import 'package:master/util/alerts.dart';

Future<ExistingUser?> showChurchSelectDialog(
  BuildContext context,
  List<ExistingUser> users,
  Function(ExistingUser) onSelected,
) {
  return showDialog<ExistingUser>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Church',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (_, i) {
                final user = users[i];
                return ListTile(
                  title: Text(user.churchName ?? 'Unknown church'),
                  onTap: () => onSelected(user),
                );
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Future<bool?> showAdminDialog(
  BuildContext context,
  TextEditingController controllerCode,
  String uniqueChurchId,
) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      bool hasError = false;
      
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputAppwrite(
                      keyboard: TextInputType.number,
                      message: 'Enter Password',
                      controller: controllerCode,
                      label: 'Password',
                      text: 'Password',
                      hasError: hasError,
                      errorMessage: 'Password is required',
                    ),
                    const SizedBox(height: 20),
                    ExtraButton(
                      skip: () async {
                        if (controllerCode.text.isEmpty) {
                          setState(() => hasError = true);
                          return;
                        }
                        final isValid = await AuthService.checkPassword(
                            controllerCode.text, uniqueChurchId);
                        if (context.mounted) {
                          Navigator.pop(context, isValid);
                        }
                      },
                      writing2: const Text('Confirm',
                          style: TextStyle(color: Colors.white)),
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
