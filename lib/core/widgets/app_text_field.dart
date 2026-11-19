import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

/// The design's 48 px input: label above, white field with a 1 px line
/// border that becomes a 2 px brand border while focused, optional leading
/// icon, password eye toggle and helper text. With [onTap] and [readOnly]
/// it acts as a picker field with a chevron.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.leadingIcon,
    this.helper,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.trailingIcon,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? leadingIcon;
  final String? helper;
  final String? errorText;

  /// Password field: hides the text and shows the eye toggle.
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? trailingIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focus = FocusNode();
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final focused = _focus.hasFocus;
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? colors.danger
        : focused
        ? colors.brand600
        : colors.line;
    final borderWidth = focused || hasError ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.label,
          style: AppTextStyles.label.copyWith(color: colors.ink),
        ),
        const SizedBox(height: AppSpacing.gap6),
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 48,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.space4 - (borderWidth - 1),
            ),
            decoration: BoxDecoration(
              color: colors.surface000,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Row(
              children: <Widget>[
                if (widget.leadingIcon != null) ...<Widget>[
                  AppIcon(
                    widget.leadingIcon!,
                    size: 20,
                    color: colors.inkMuted,
                  ),
                  const SizedBox(width: AppSpacing.space2),
                ],
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    initialValue: widget.controller == null
                        ? widget.initialValue
                        : null,
                    focusNode: _focus,
                    onChanged: widget.onChanged,
                    onFieldSubmitted: widget.onSubmitted,
                    obscureText: _hidden,
                    readOnly: widget.readOnly,
                    onTap: widget.onTap,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    autofillHints: widget.autofillHints,
                    maxLength: widget.maxLength,
                    cursorColor: colors.brand600,
                    style: AppTextStyles.bodyLg.copyWith(color: colors.ink),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      counterText: '',
                      semanticCounterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.obscure)
                  Semantics(
                    button: true,
                    label: _hidden
                        ? AppLocalizations.of(context).showPasswordAction
                        : AppLocalizations.of(context).hidePasswordAction,
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () => setState(() => _hidden = !_hidden),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: AppSpacing.space2,
                        ),
                        child: AppIcon(
                          AppIcon.eye,
                          size: 20,
                          color: colors.inkMuted,
                        ),
                      ),
                    ),
                  ),
                if (widget.trailingIcon != null)
                  AppIcon(
                    widget.trailingIcon!,
                    size: 20,
                    color: colors.inkMuted,
                  ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null || widget.helper != null) ...<Widget>[
          const SizedBox(height: AppSpacing.gap6),
          Text(
            widget.errorText ?? widget.helper!,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w400,
              color: hasError ? colors.danger : colors.inkMuted,
            ),
          ),
        ],
      ],
    );
  }
}
