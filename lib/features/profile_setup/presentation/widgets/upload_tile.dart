import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';

/// Dashed brand row: upload icon, label and a hint on the end side
/// ("Upload certificates · JPG or PDF"). (Mock phase: attaches a sample file.)
class UploadTile extends StatelessWidget {
  const UploadTile({
    required this.label,
    required this.hint,
    required this.onTap,
    super.key,
  });

  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Semantics(
      button: true,
      child: CustomPaint(
        foregroundPainter: _DashedRectPainter(colors.brand600),
        child: Material(
          color: colors.surface000,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.gap14,
                vertical: AppSpacing.space3,
              ),
              child: Row(
                children: <Widget>[
                  AppIcon(AppIcon.upload, size: 20, color: colors.brand700),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.label.copyWith(
                        color: colors.brand700,
                      ),
                    ),
                  ),
                  Text(
                    hint,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w400,
                      color: colors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1 px dashed rounded-rectangle border.
class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadius.md),
    ).deflate(0.5);
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
