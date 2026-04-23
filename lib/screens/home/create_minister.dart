import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/widgets/common/connect_button.dart';
import '../../classes/minister_class.dart';
import 'package:master/widgets/common/connect_loader.dart';

class CreateMinister extends StatefulWidget {
  const CreateMinister({super.key});
  @override
  State<CreateMinister> createState() => _CreateMinisterState();
}

class _CreateMinisterState extends State<CreateMinister> {
  // ── preserved ─────────────────────────────────────────────────────────────
  String? specialistId;
  bool isLoading = false;
  TextEditingController workController = TextEditingController();   // Position / Title
  TextEditingController nameController = TextEditingController();   // Full Name
  TextEditingController bioController = TextEditingController();    // Short Bio (new)
  MinisterClass ministerClass = MinisterClass();

  // ── new v2 state ──────────────────────────────────────────────────────────
  int _selectedPermission = 0; // 0=Leader,1=Coordinator,2=Moderator,3=Media

  static const _permissions = ['Leader', 'Coordinator', 'Moderator', 'Media'];

  @override
  void dispose() {
    workController.dispose();
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  // ── preserved: upload image to Supabase ────────────────────────────────────
  Future<void> _pickImage() async {
    await ministerClass.uploadImageToSuperbase(context, setState);
  }

  // ── preserved: save minister to Supabase ──────────────────────────────────
  Future<void> _saveProfile() async {
    setState(() => isLoading = true);
    try {
      await ministerClass.uploadMinister(
        nameController.text,
        workController.text,
        ministerClass.image,
        context,
      );
    } finally {
      workController.clear();
      nameController.clear();
      bioController.clear();
      Navigator.of(context).pop(); // preserved: close modal/sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(nameController.text);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Purple gradient header ──────────────────────────────────
              Container(
                height: 210,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleHeaderGradient,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Topbar: back | title | skip
                      SizedBox(
                        height: 68,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Back
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  color: AppColors.whiteDim,
                                  size: 22,
                                ),
                              ),
                              // Title
                              const Expanded(
                                child: Text(
                                  'Your Profile',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              // Skip
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Skip',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.whiteDim,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Scrollable body ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Full Name ────────────────────────────────────────
                      Text('FULL NAME', style: AppTypography.fieldLabel),
                      const SizedBox(height: 7),
                      _ProfileField(
                        controller: nameController,
                        hint: 'John Dlamini',
                        active: true,
                        onChanged: (_) => setState(() {}), // refresh initials
                      ),
                      const SizedBox(height: 14),

                      // ── Position / Title (workController) ────────────────
                      Text('POSITION / TITLE', style: AppTypography.fieldLabel),
                      const SizedBox(height: 7),
                      _ProfileField(
                        controller: workController,
                        hint: 'e.g. Community Leader, Coordinator...',
                      ),
                      const SizedBox(height: 14),

                      // ── Permissions chips ────────────────────────────────
                      Text('PERMISSIONS', style: AppTypography.fieldLabel),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _permissions.asMap().entries.map((e) {
                          final i = e.key;
                          final label = e.value;
                          final sel = _selectedPermission == i;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPermission = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.navy
                                    : AppColors.white,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusPill),
                                border: Border.all(
                                  color: sel
                                      ? AppColors.navy
                                      : AppColors.surfaceAlt,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x09000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                label,
                                style: AppTypography.chipLabel.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? AppColors.white
                                      : AppColors.textMid,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // ── Short Bio ────────────────────────────────────────
                      Text('SHORT BIO', style: AppTypography.fieldLabel),
                      const SizedBox(height: 7),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusInput),
                          border: Border.all(
                              color: AppColors.surfaceAlt, width: 2),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 4,
                                offset: Offset(0, 1)),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: TextField(
                          controller: bioController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Share a little about yourself with the community — your role, passion, or what you bring to the team...',
                            hintStyle: AppTypography.fieldPlaceholder
                                .copyWith(height: 1.6),
                          ),
                          style: AppTypography.bodyMedium
                              .copyWith(height: 1.6, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Profile picture upload (preserved) ───────────────
                      Text('PROFILE PHOTO', style: AppTypography.fieldLabel),
                      const SizedBox(height: 7),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusInput),
                            border: Border.all(
                                color: AppColors.surfaceAlt, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1)),
                            ],
                          ),
                          child: ministerClass.xImage != null
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusInput - 2),
                                  child: Image.memory(
                                    ministerClass.xImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 80,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.purpleTint,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 20,
                                          color: AppColors.purple),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Upload Photo',
                                            style: AppTypography.cardTitle),
                                        Text('Tap to choose from library',
                                            style: AppTypography.caption),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Save button ──────────────────────────────────────
                      ConnectButton.primary(
                        label: 'Save Profile  \u2192',
                        isLoading: isLoading,
                        onTap: isLoading ? null : _saveProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Avatar — overlaps header / body boundary ─────────────────────
          Positioned(
            top: 210 - 44, // half of 88px avatar
            left: 0,
            right: 0,
            child: Center(child: _AvatarUpload(
              initials: initials,
              image: ministerClass.xImage,
              onTap: _pickImage,
            )),
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'JD';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Avatar upload circle ──────────────────────────────────────────────────────
class _AvatarUpload extends StatelessWidget {
  final String initials;
  final dynamic image; // Uint8List?
  final VoidCallback onTap;

  const _AvatarUpload({
    required this.initials,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient ring
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.purpleCardGradient,
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navy,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: ClipOval(
                child: image != null
                    ? Image.memory(image, fit: BoxFit.cover)
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.navy,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: AppTypography.buttonPrimary.copyWith(
                              fontSize: 26, letterSpacing: 0, height: 1),
                        ),
                      ),
              ),
            ),
          ),
          // Camera FAB
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 13, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable profile input field ──────────────────────────────────────────────
class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool active;
  final Function(String)? onChanged;

  const _ProfileField({
    required this.controller,
    required this.hint,
    this.active = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(
          color: active ? AppColors.purple : AppColors.surfaceAlt,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTypography.fieldPlaceholder,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: AppTypography.fieldValue,
      ),
    );
  }
}
