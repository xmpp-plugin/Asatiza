import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Six 48×58 digit boxes (10 px radius). One hidden text field takes the
/// input, so paste and SMS/email autofill work; the next empty box gets the
/// 2 px brand border.
class OtpInput extends StatefulWidget {
  const OtpInput({
    required this.onChanged,
    super.key,
    this.length = 6,
    this.autofocus = true,
  });

  final ValueChanged<String> onChanged;
  final int length;
  final bool autofocus;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    _controller.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final text = _controller.text;
    return Semantics(
      label: AppLocalizations.of(context).codeFieldLabel,
      textField: true,
      child: GestureDetector(
        onTap: _focus.requestFocus,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: <Widget>[
            // Invisible field that receives the digits.
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 58,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  autofillHints: const <String>[AutofillHints.oneTimeCode],
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  onChanged: widget.onChanged,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (var i = 0; i < widget.length; i++)
                    _box(
                      colors,
                      digit: i < text.length ? text[i] : '',
                      active:
                          _focus.hasFocus &&
                          i == text.length.clamp(0, widget.length - 1),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(AppColors colors, {required String digit, required bool active}) {
    return Container(
      width: 48,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface000,
        borderRadius: BorderRadius.circular(AppRadius.otpBox),
        border: Border.all(
          color: active ? colors.brand600 : colors.line,
          width: active ? 2 : 1,
        ),
      ),
      child: Text(
        digit,
        style: AppTextStyles.otpDigit.copyWith(color: colors.ink),
      ),
    );
  }
}
