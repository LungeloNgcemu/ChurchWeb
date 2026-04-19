import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../classes/church_init.dart';
import '../../models/model.dart';
import '../../providers/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/comment_model.dart';
import '../../util/functions_for_cloud.dart';
import '../../componants/global_booking.dart';
import 'package:path/path.dart' as path;
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_button.dart';
import 'package:master/theme/theme_manager.dart';
import 'package:master/widgets/common/connect_loader.dart';

// create_page and poster are linked
String postKey = '';

class Poster extends StatefulWidget {
  Poster({
    super.key,
  });

  @override
  State<Poster> createState() => _PosterState();
}

class _PosterState extends State<Poster> {
  bool isLoading = false;
  final ImagePickerCustom _picker = ImagePickerCustom();
  ChurchInit churchStart = ChurchInit();
  Authenticate auth = Authenticate();

  Uint8List? _image;
  String? npostKey;
  String? postImageUrl;
  String? imageUrl;

  // Post category selection
  String _selectedCategory = 'Announcement';
  final List<String> _categories = ['All', 'Announcement', 'Event', 'Update', 'Request'];

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImageToByte();
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      imageUrl = null;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _uploadImageToSuperbase(image) async {
    try {
      if (image != null) {
        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String pathv = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .uploadBinary(fileName, image,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false));

        final publicUrl = await supabase.storage
            .from(Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'])
            .getPublicUrl(fileName);

        setState(() {
          imageUrl = publicUrl;
        });
      }
    } catch (e) {
      log("Error uploading image to Supabase: $e");
    }
  }

  void superbasePost(String Des, String img) async {
    await supabase.from('Posts').insert({
      'Description': Des,
      'ImageUrl': img,
      'Church': Provider.of<christProvider>(context, listen: false)
          .myMap['Project']?['ChurchName']
    });
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> _handlePost() async {
    setState(() => isLoading = true);

    final description = descriptionController.text;

    try {
      if (description.isEmpty) {
        alertSuccess(context, "Please fill in a description");
        Future.delayed(const Duration(seconds: 1), () {
          setState(() => isLoading = false);
        });
        return;
      }

      if (_image != null) {
        await _uploadImageToSuperbase(_image);
      }

      superbasePost(description, imageUrl ?? '');

      PushNotifications.sendMessageToTopic(
          topic: Provider.of<christProvider>(context, listen: false)
              .myMap['Project']?['ChurchName'],
          title: 'Post',
          body: description);

      Future.delayed(const Duration(seconds: 1), () {
        setState(() => isLoading = false);
      });

      titleController.clear();
      descriptionController.clear();
      Navigator.of(context).pop();
    } catch (error) {
      alertSuccess(context, "Something went wrong");
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => isLoading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    return Stack(
      children: [
        _buildSheet(theme),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusBottomSheet)),
              ),
              child: Center(
                child: SizedBox(
                  height: 36,
                  width: 36,
                  child: ConnectLoader(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSheet(ThemeManager theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusBottomSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────────────
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Top bar: Cancel | New Post | Post button ──────────────────────
          Container(
            // height: 52,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lgPlus),
            decoration: BoxDecoration(
              color: theme.colors.card,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceAlt, width: 1),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMid,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'New Post',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: isLoading ? null : _handlePost,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Post',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable compose area ───────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Author row ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lgPlus, AppSpacing.mdPlus,
                        AppSpacing.lgPlus, AppSpacing.mdPlus),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'TM',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Provider.of<ClientNameProvider>(context,
                                          listen: false)
                                      .clientName
                                      .isNotEmpty
                                  ? Provider.of<ClientNameProvider>(context,
                                          listen: false)
                                      .clientName
                                  : 'Thabo Mokoena',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.purpleTint,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusPill),
                                border: Border.all(
                                    color: theme.colors.primary,
                                    width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.language,
                                      size: 11, color: theme.colors.primary),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Community',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(
                      color: AppColors.surface, height: 1, thickness: 1),

                  // ── Text input ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lgPlus,
                        vertical: AppSpacing.mdPlus),
                    child: TextField(
                      controller: descriptionController,
                      maxLines: null,
                      minLines: 4,
                      keyboardType: TextInputType.multiline,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.65,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // ── Attached image preview ────────────────────────────────
                  if (_image != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lgPlus, 0,
                          AppSpacing.lgPlus, AppSpacing.md),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusCard),
                            child: SizedBox(
                              height: 148,
                              width: double.infinity,
                              child: Image.memory(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Remove button
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                          // Label
                          Positioned(
                            bottom: 10,
                            left: 14,
                            child: Text(
                              '1 photo attached',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Toolbar ───────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lgPlus, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                            color: AppColors.surfaceAlt, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Image picker tool
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _image != null
                                  ? AppColors.purpleTint
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusIcon),
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              size: 18,
                              color: _image != null
                                  ? AppColors.purple
                                  : AppColors.textMid,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.tag,
                            size: 18,
                            color: AppColors.textMid,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.short_text,
                            size: 18,
                            color: AppColors.textMid,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                            width: 1, height: 20, color: AppColors.surfaceAlt),
                        const Spacer(),
                        // Char count
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: descriptionController,
                          builder: (_, value, __) => Text(
                            '${value.text.length} / 500',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Category chips ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lgPlus, AppSpacing.md,
                        AppSpacing.lgPlus, AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CATEGORY',
                          style: AppTypography.fieldLabel
                              .copyWith(color: theme.colors.primary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colors.primary
                                      : theme.colors.card,
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colors.primary
                                        : AppColors.surfaceAlt,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMid,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Bottom safe area padding
                  SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 0
                          : MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),

          // ── Fixed bottom Post CTA ─────────────────────────────────────────
          Container(
            padding: AppSpacing.ctaStripPadding,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.surfaceAlt, width: 1),
              ),
            ),
            child: ConnectButton.purple(
              label: 'Post →',
              isLoading: isLoading,
              onTap: isLoading ? null : _handlePost,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legacy helper widgets kept for backward compatibility ─────────────────────

class ImageFrame extends StatefulWidget {
  const ImageFrame({this.image, Key? key}) : super(key: key);

  final dynamic image;

  @override
  _ImageFrameState createState() => _ImageFrameState();
}

class _ImageFrameState extends State<ImageFrame> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: 145.0,
        width: 145.0,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: _buildImage(widget.image),
      ),
    );
  }

  Widget _buildImage(dynamic image) {
    if (image == null) return Container();
    if (image is Uint8List) {
      return Image.memory(image, fit: BoxFit.cover,
          width: double.infinity, height: 250.0);
    }
    return const SizedBox();
  }
}
