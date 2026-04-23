import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../classes/church_init.dart';
import '../../classes/prayer_class.dart';
import '../../classes/push_notification/notification.dart';
import '../../componants/global_booking.dart';
import '../../providers/url_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../../classes/message_class.dart';
import 'package:master/widgets/common/connect_loader.dart';

// create_prayer.dart — v2 design system modal bottom sheet
class CreatePrayer extends StatefulWidget {
  const CreatePrayer({super.key});

  @override
  State<CreatePrayer> createState() => _CreatePrayerState();
}

class _CreatePrayerState extends State<CreatePrayer> {
  bool isLoading = false;

  Map<String, dynamic> currentUser = {};

  MessageClass userClass = MessageClass();

  Prayer prayerClass = Prayer();

  void user() async {
    currentUser = await userClass.getCurrentUser(context);
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });

    user();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  TextEditingController prayerController = TextEditingController();

  Future<void> superbaseProduct(
      prayer, userName, userId, phoneNumber, image) async {
    final formattedDate = prayerClass.convertDate();

    await supabase.from('Prayers').insert({
      'Name': userName,
      'UserId': userId,
      'PhoneNumber': phoneNumber,
      'Prayer': prayer.toString(),
      'Date': formattedDate,
      'Status': 'Praying',
      'Image': image,
      'Church': Provider.of<christProvider>(context, listen: false)
              .myMap['Project']?['ChurchName'] ??
          '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Main sheet content ───────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.xl2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),

              // ── Title strip ───────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lgPlus,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.zero,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Submit Request',
                        style: AppTypography.screenTitle,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: AppSpacing.topBarIconSize,
                        height: AppSpacing.topBarIconSize,
                        decoration: BoxDecoration(
                          color: AppColors.navyIconBg,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusIcon),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form body ─────────────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lgPlus,
                    AppSpacing.xl,
                    AppSpacing.lgPlus,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Field label ─────────────────────────────────────
                      Text(
                        'YOUR REQUEST',
                        style: AppTypography.fieldLabel,
                      ),
                      AppSpacing.vSm,

                      // ── Multiline text area ─────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusInput),
                          border: Border.all(
                            color: AppColors.surfaceAlt,
                            width: 2,
                          ),
                        ),
                        child: TextField(
                          controller: prayerController,
                          minLines: 6,
                          maxLines: 10,
                          keyboardType: TextInputType.multiline,
                          style: AppTypography.fieldValue,
                          decoration: InputDecoration(
                            hintText: "Share what's on your heart...",
                            hintStyle: AppTypography.fieldPlaceholder,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusInput),
                              borderSide: BorderSide(
                                color: AppColors.purple,
                                width: 2,
                              ),
                            ),
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),

                      AppSpacing.vXl2,

                      // ── Submit button ───────────────────────────────────
                      GestureDetector(
                        onTap: () async {
                          final prayer = prayerController.text.trim();
                          if (prayer.isEmpty) return;

                          setState(() => isLoading = true);

                          final orgId =
                              Provider.of<christProvider>(context, listen: false)
                                      .myMap['Project']?['ProjectId']?.toString() ??
                                  '';

                          await superbaseProduct(
                            prayer,
                            currentUser['UserName'],
                            currentUser['UserId'],
                            currentUser['PhoneNumber'],
                            Provider.of<CurrentUserImageProvider>(
                              context,
                              listen: false,
                            ).currentUserImage,
                          );

                          // Notify all community members about the new request
                          await PushNotifications.sendMessageToTopic(
                            topic: orgId,
                            title: 'New Request',
                            body: '${currentUser['UserName'] ?? 'Someone'} submitted a request: $prayer',
                          );

                          setState(() => isLoading = false);
                          prayerController.clear();
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          decoration: BoxDecoration(
                            gradient: AppColors.orangeGradient,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusPill),
                            boxShadow: AppSpacing.orangeButtonShadow,
                          ),
                          child: Center(
                            child: Text(
                              'Submit Request',
                              style: AppTypography.buttonPrimary,
                            ),
                          ),
                        ),
                      ),

                      // Bottom safe-area breathing room
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom +
                            AppSpacing.md,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Loading overlay ──────────────────────────────────────────────────
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.xl2),
                ),
              ),
              child: Center(
                child: ConnectLoader(),
              ),
            ),
          ),
      ],
    );
  }
}
