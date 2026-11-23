import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// Two-thumb fee slider from the filter sheet (artboard 13): 4 px track,
/// brand active range and 24 px white thumbs with a 2 px brand ring.
/// Values snap to [step].
class FeeRangeSlider extends StatefulWidget {
  const FeeRangeSlider({
    required this.min,
    required this.max,
    required this.start,
    required this.end,
    required this.onChanged,
    required this.semanticLabel,
    required this.describe,
    super.key,
    this.step = 5,
  });

  final int min;
  final int max;
  final int start;
  final int end;
  final int step;
  final void Function(int start, int end) onChanged;
  final String semanticLabel;

  /// Spoken value for a range, e.g. "$10 – $100".
  final String Function(int start, int end) describe;

  @override
  State<FeeRangeSlider> createState() => _FeeRangeSliderState();
}

class _FeeRangeSliderState extends State<FeeRangeSlider> {
  static const double _thumb = 24;
  bool _draggingStart = true;

  int _valueAt(double dx, double width) {
    final usable = width - _thumb;
    final fraction = ((dx - _thumb / 2) / usable).clamp(0.0, 1.0);
    final raw = widget.min + fraction * (widget.max - widget.min);
    return ((raw / widget.step).round() * widget.step).clamp(
      widget.min,
      widget.max,
    );
  }

  double _xOf(int value, double width) =>
      (value - widget.min) / (widget.max - widget.min) * (width - _thumb);

  void _update(double dx, double width) {
    final value = _valueAt(dx, width);
    if (_draggingStart) {
      widget.onChanged(value.clamp(widget.min, widget.end), widget.end);
    } else {
      widget.onChanged(widget.start, value.clamp(widget.start, widget.max));
    }
  }

  int _endAfter(int delta) =>
      (widget.end + delta).clamp(widget.start, widget.max);

  void _adjust(int delta) => widget.onChanged(widget.start, _endAfter(delta));

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Semantics(
      label: widget.semanticLabel,
      value: widget.describe(widget.start, widget.end),
      increasedValue: widget.describe(widget.start, _endAfter(widget.step)),
      decreasedValue: widget.describe(widget.start, _endAfter(-widget.step)),
      onIncrease: () => _adjust(widget.step),
      onDecrease: () => _adjust(-widget.step),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final startX = _xOf(widget.start, width);
          final endX = _xOf(widget.end, width);
          Widget thumb(double x) => Positioned(
            left: x,
            top: 0,
            child: Container(
              width: _thumb,
              height: _thumb,
              decoration: BoxDecoration(
                color: colors.surface000,
                shape: BoxShape.circle,
                border: Border.all(color: colors.brand600, width: 2),
              ),
            ),
          );
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (d) {
              final x = d.localPosition.dx;
              _draggingStart =
                  (x - startX - _thumb / 2).abs() <=
                  (x - endX - _thumb / 2).abs();
              _update(x, width);
            },
            onHorizontalDragUpdate: (d) => _update(d.localPosition.dx, width),
            onTapDown: (d) {
              final x = d.localPosition.dx;
              _draggingStart =
                  (x - startX - _thumb / 2).abs() <=
                  (x - endX - _thumb / 2).abs();
              _update(x, width);
            },
            child: SizedBox(
              height: _thumb,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 10,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.surface200,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  Positioned(
                    left: startX + _thumb / 2,
                    top: 10,
                    child: Container(
                      width: endX - startX,
                      height: 4,
                      color: colors.brand600,
                    ),
                  ),
                  thumb(startX),
                  thumb(endX),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
