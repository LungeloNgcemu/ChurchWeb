import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';

/// Connect App — Text Input Component
/// Source of truth: CLAUDE.md § 4.5 Input Field & § 8 Form Field pattern
///
/// Standard usage:
///   ConnectTextField(
///     label: 'FULL NAME',
///     placeholder: 'Enter your name...',
///     controller: _nameController,
///     leadingIcon: Icon(Icons.person_outline),
///   )
///
/// Also exported:
///   ConnectOtpField — 6 individual OTP boxes

class ConnectTextField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final bool autofocus;
  final FocusNode? focusNode;

  const ConnectTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.leadingIcon,
    this.trailingIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.errorText,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<ConnectTextField> createState() => _ConnectTextFieldState();
}

class _ConnectTextFieldState extends State<ConnectTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.purple
            : AppColors.surfaceAlt;
    final fillColor = _isFocused && !hasError
        ? const Color(0xFFFDFCFF) // very faint purple tint
        : AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Label ─────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: AppTypography.fieldLabel,
          ),
          AppSpacing.vSm,
        ],
        // ─── Input box ─────────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            crossAxisAlignment: widget.maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              // Leading icon
              if (widget.leadingIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _isFocused
                          ? AppColors.purpleTint
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? AppColors.purple
                            : AppColors.textMuted,
                        size: 16,
                      ),
                      child: widget.leadingIcon!,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ] else
                const SizedBox(width: 16),
              // Text input
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  readOnly: widget.readOnly,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  style: AppTypography.fieldValue,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: AppTypography.fieldPlaceholder,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: widget.maxLines > 1 ? 14 : 14,
                    ),
                  ),
                ),
              ),
              // Trailing icon
              if (widget.trailingIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconTheme(
                    data: const IconThemeData(
                        color: AppColors.textMuted, size: 16),
                    child: widget.trailingIcon!,
                  ),
                ),
              ] else
                const SizedBox(width: 16),
            ],
          ),
        ),
        // ─── Error text ────────────────────────────────────────────────────
        if (hasError) ...[
          AppSpacing.vXs,
          Text(
            widget.errorText!,
            style: AppTypography.caption
                .copyWith(color: AppColors.error, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

// ─── OTP Input Row ────────────────────────────────────────────────────────────
/// Row of 6 individual OTP digit boxes.
/// Usage:
///   ConnectOtpField(
///     length: 6,
///     onCompleted: (code) => _verify(code),
///   )
class ConnectOtpField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const ConnectOtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<ConnectOtpField> createState() => _ConnectOtpFieldState();
}

class _ConnectOtpFieldState extends State<ConnectOtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < widget.length - 1 ? 10 : 0),
          child: _OtpBox(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            onChanged: (v) => _onDigitChanged(i, v),
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: filled
            ? AppColors.purpleTint
            : (_isFocused ? AppColors.white : AppColors.surface),
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(
          color: filled || _isFocused
              ? AppColors.purple
              : AppColors.surfaceAlt,
          width: _isFocused ? 2.5 : 2,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: widget.onChanged,
        style: AppTypography.otpDigit,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
