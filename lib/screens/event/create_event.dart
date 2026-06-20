import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:master/widgets/common/connect_loader.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController    = TextEditingController();
  final _picker = ImagePickerCustom();

  DateTime?   _selectedDate;
  TimeOfDay?  _selectedTime;
  Uint8List?  _image;
  bool        _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ── Pickers ─────────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.purple,
            onPrimary: AppColors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.purple,
            onPrimary: AppColors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickImage() async {
    final bytes = await _picker.pickImageToByte();
    if (bytes != null) setState(() => _image = bytes);
  }

  // ── Submit ──────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final title       = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      alertSuccess(context, 'Please enter a title');
      return;
    }
    if (_selectedDate == null) {
      alertSuccess(context, 'Please select a date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider   = Provider.of<christProvider>(context, listen: false);
      final churchName = provider.myMap['Project']?['ChurchName'] ?? '';
      final bucket     = provider.myMap['Project']?['Bucket'] ?? 'churchStorage';

      String? imageUrl;
      if (_image != null) {
        final fileName = 'EVENT_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from(bucket).uploadBinary(
          fileName, _image!,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        imageUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      }

      // ISO date for EventDate column
      final isoDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // Legacy Day string for backward compat with old rows
      const monthNames = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
      final legacyDay = '${_selectedDate!.year} '
          '${monthNames[_selectedDate!.month - 1]} ${_selectedDate!.day}';

      // Format time before any await to avoid BuildContext-across-async-gap lint
      final startTime = _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : '';

      await supabase.from('Events').insert({
        'Title':       title,
        'Description': description,
        'EventDate':   isoDate,
        'Day':         legacyDay,
        'ChurchName':  churchName,
        'Location':    _locationController.text.trim(),
        'StartTime':   startTime,
        'Category':    'Event',
        if (imageUrl != null) 'Image': imageUrl,
      });

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        alertSuccess(context, 'Failed to create event. Please try again.');
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Column(
          children: [
            // Topbar
            Container(
              color: AppColors.navy,
              padding: EdgeInsets.fromLTRB(18, top > 0 ? top : 14, 18, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.navyIconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Create Event',
                      style: AppTypography.screenTitle.copyWith(fontSize: 18)),
                ],
              ),
            ),

            // Form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Date ────────────────────────────────────────────
                    _FieldLabel('DATE'),
                    const SizedBox(height: 6),
                    _TapField(
                      onTap: _pickDate,
                      icon: Icons.calendar_month_rounded,
                      hasValue: _selectedDate != null,
                      label: _selectedDate != null
                          ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                          : 'Select event date',
                    ),
                    const SizedBox(height: 16),

                    // ── Title ───────────────────────────────────────────
                    _FieldLabel('TITLE'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _titleController,
                      hint: 'Event title',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 16),

                    // ── Description ─────────────────────────────────────
                    _FieldLabel('DESCRIPTION'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _descriptionController,
                      hint: 'Describe the event...',
                      icon: Icons.notes_rounded,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // ── Location ─────────────────────────────────────────
                    _FieldLabel('LOCATION  (OPTIONAL)'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _locationController,
                      hint: 'Venue or address',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    // ── Start time ──────────────────────────────────────
                    _FieldLabel('START TIME  (OPTIONAL)'),
                    const SizedBox(height: 6),
                    _TapField(
                      onTap: _pickTime,
                      icon: Icons.access_time_rounded,
                      hasValue: _selectedTime != null,
                      label: _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select start time',
                      trailing: _selectedTime != null
                          ? GestureDetector(
                              onTap: () => setState(() => _selectedTime = null),
                              child: Icon(Icons.close_rounded,
                                  size: 16, color: AppColors.textMuted),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Cover image ─────────────────────────────────────
                    _FieldLabel('COVER IMAGE  (OPTIONAL)'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.surfaceAlt, width: 2),
                        ),
                        child: _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Image.memory(
                                      _image!,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _image = null),
                                        child: Container(
                                          width: 28, height: 28,
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close_rounded,
                                              size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 86,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          size: 24, color: AppColors.textMuted),
                                      const SizedBox(height: 4),
                                      Text('Add cover image',
                                          style: AppTypography.caption),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Fixed bottom CTA
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.surfaceAlt, width: 1),
              ),
            ),
            child: GestureDetector(
              onTap: _isLoading ? null : _submit,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Create Event',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x80000000),
              child: Center(child: ConnectLoader()),
            ),
          ),
      ],
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.fieldLabel);
}

class _TapField extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool hasValue;
  final String label;
  final Widget? trailing;

  const _TapField({
    required this.onTap,
    required this.icon,
    required this.hasValue,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue ? AppColors.purple : AppColors.surfaceAlt,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: hasValue ? AppColors.purple : AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: hasValue ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTypography.fieldValue,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.fieldPlaceholder,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 18, color: AppColors.textMuted),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        fillColor: AppColors.surface,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.surfaceAlt, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.surfaceAlt, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.purple, width: 2),
        ),
      ),
    );
  }
}
