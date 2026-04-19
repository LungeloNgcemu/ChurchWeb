import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/util/alerts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart' as p;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../../classes/media_class.dart';
import '../../providers/url_provider.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_button.dart';
import 'package:master/theme/theme_manager.dart';
import 'package:master/widgets/common/connect_loader.dart';

// create_page and poster are linked
class MediaPoster extends StatefulWidget {
  MediaPoster({
    super.key,
  });

  /// Show the Add Media sheet with transparent bg so the gap above the rounded
  /// header shows as transparent instead of white.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: MediaPoster(),
      ),
    );
  }

  @override
  State<MediaPoster> createState() => _MediaPosterState();
}

class _MediaPosterState extends State<MediaPoster> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  MediaClass medaiClass = MediaClass();
  Authenticate auth = Authenticate();

  // Category selection — matches the v2 mockup chips
  String _selectedCategory = 'Series';
  final List<String> _categories = ['Talk', 'Series', 'Event Recap', 'Short', 'Devotion'];

  Future<void> _handlePost(String selectedOption) async {
    setState(() => medaiClass.isLoading = true);

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final url = urlController.text.trim();

    if (title.isEmpty || url.isEmpty) {
      alertSuccess(context, "Please fill in the title and URL");
      setState(() => medaiClass.isLoading = false);
      return;
    }

    await medaiClass.superbaseMedia(
        title, description, _selectedCategory, url, context);

    setState(() => medaiClass.isLoading = false);
    titleController.clear();
    descriptionController.clear();
    urlController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    String selectedOption =
        Provider.of<SelectedOptionProvider>(context).selectedOption;

    return Stack(
      children: [
        _buildSheet(selectedOption, theme),
        if (medaiClass.isLoading)
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

  Widget _buildSheet(String selectedOption, ThemeManager theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusBottomSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dark navy topbar strip ─────────────────────────────────────────
          Builder(builder: (context) {
            final contrastColor =
                ThemeData.estimateBrightnessForColor(theme.colors.primary) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black;
            return Container(
              height: 58,
              padding: AppSpacing.topBarPadding,
              decoration: BoxDecoration(
                color: theme.colors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusBottomSheet),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.chevron_left, color: contrastColor, size: 22),
                  const SizedBox(width: 4),
                  Text('Add Media',
                      style: AppTypography.screenTitle
                          .copyWith(color: contrastColor)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: contrastColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: contrastColor, size: 14),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Scrollable form area ───────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lgPlus, AppSpacing.lg,
                  AppSpacing.lgPlus, AppSpacing.xl4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Source toggle (YouTube Link selected) ─────────────────
                  Text('SOURCE', style: AppTypography.fieldLabel),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusChipSm),
                    ),
                    child: Row(
                      children: [
                        _SourceTab(label: 'YouTube Link', isSelected: true),
                        _SourceTab(label: 'Upload File', isSelected: false),
                        _SourceTab(label: 'Live Stream', isSelected: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── YouTube URL field ──────────────────────────────────────
                  Text('VIDEO URL', style: AppTypography.fieldLabel),
                  const SizedBox(height: AppSpacing.sm),
                  _buildUrlField(),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Title field ────────────────────────────────────────────
                  Text('TITLE', style: AppTypography.fieldLabel),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(
                    controller: titleController,
                    hint: 'Enter title',
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Description field (optional) ───────────────────────────
                  Text('DESCRIPTION', style: AppTypography.fieldLabel),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(
                    controller: descriptionController,
                    hint: 'Optional description...',
                    minLines: 3,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Category chips ─────────────────────────────────────────
                  Text('CATEGORY', style: AppTypography.fieldLabel),
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
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colors.primary
                                : AppColors.white,
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
                                  ? AppColors.white
                                  : AppColors.textMid,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl2),
                ],
              ),
            ),
          ),

          // ── Fixed bottom CTA ───────────────────────────────────────────────
          Container(
            padding: AppSpacing.ctaStripPadding,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                  top: BorderSide(color: AppColors.surfaceAlt, width: 1)),
            ),
            child: ConnectButton.purple(
              label: 'Publish →',
              isLoading: medaiClass.isLoading,
              onTap: medaiClass.isLoading
                  ? null
                  : () => _handlePost(selectedOption),
            ),
          ),
        ],
      ),
    );
  }

  // ── URL input field with play icon ─────────────────────────────────────────
  Widget _buildUrlField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(color: AppColors.purple, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: 13),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.purpleBadge,
              borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
            ),
            child: Icon(Icons.play_arrow_rounded,
                size: 18, color: AppColors.purple),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: urlController,
              keyboardType: TextInputType.url,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'youtube.com/watch?v=...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Clear button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: urlController,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => urlController.clear(),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close,
                      size: 12, color: AppColors.textMuted),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Standard text field ────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int minLines = 1,
  }) {
    return _FocusAwareField(
      controller: controller,
      hint: hint,
      minLines: minLines,
    );
  }
}

// ── Focus-aware field that shows active border on focus ──────────────────────
class _FocusAwareField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;

  const _FocusAwareField({
    required this.controller,
    required this.hint,
    this.minLines = 1,
  });

  @override
  State<_FocusAwareField> createState() => _FocusAwareFieldState();
}

class _FocusAwareFieldState extends State<_FocusAwareField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: _focused ? const Color(0xFFFDFCFF) : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(
          color: _focused ? AppColors.purple : AppColors.surfaceAlt,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: 13),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        maxLines: null,
        minLines: widget.minLines,
        keyboardType: TextInputType.multiline,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ── Source toggle tab ─────────────────────────────────────────────────────────
class _SourceTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _SourceTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Legacy widgets kept for any external references ───────────────────────────

class ImageFrame extends StatefulWidget {
  ImageFrame({this.image, Key? key}) : super(key: key);

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
    if (image is p.XFile) {
      return Image.file(File(image.path),
          fit: BoxFit.cover, width: double.infinity, height: 250.0);
    } else if (image is File) {
      return Image.file(image,
          fit: BoxFit.cover, width: double.infinity, height: 250.0);
    } else {
      return Image.network("https://picsum.photos/seed/picsum/200/300");
    }
  }
}
