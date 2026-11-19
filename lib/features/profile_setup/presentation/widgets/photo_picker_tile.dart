import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../data/models/profile.dart';

/// 96 px dashed brand circle with a camera, beside a title and hint. Once
/// a photo is attached it shows the user's avatar with a check badge.
/// (Mock phase: no camera or gallery access.)
class PhotoPickerTile extends StatelessWidget {
  const PhotoPickerTile({
    required this.profile,
    required this.hasPhoto,
    required this.title,
    required this.message,
    required this.semanticLabel,
    required this.onTap,
    super.key,
  });

  final Profile profile;
  final bool hasPhoto;
  final String title;
  final String message;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: <Widget>[
        Semantics(
          button: true,
          label: semanticLabel,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: onTap,
            child: hasPhoto
                ? Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      AppAvatar(profile: profile, size: 96),
                      PositionedDirectional(
                        end: 2,
                        bottom: 2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors.brand600,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface100,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AppIcon(
                            AppIcon.check,
                            size: 16,
                            strokeWidth: 3,
                            color: colors.onBrand,
                          ),
                        ),
                      ),
                    ],
                  )
                : CustomPaint(
                    foregroundPainter: _DashedCirclePainter(colors.brand600),
                    child: Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.brand100,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(
                        AppIcon.camera,
                        size: 30,
                        color: colors.brand700,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: AppTextStyles.nameMd.copyWith(color: colors.ink),
              ),
              const SizedBox(height: AppSpacing.gap6),
              Text(
                message,
                style: AppTextStyles.helper.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 2 px dashed circle border.
class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final radius = size.width / 2 - 1;
    final center = size.center(Offset.zero);
    const dash = 6.0;
    const gap = 4.0;
    final circumference = 2 * math.pi * radius;
    final count = (circumference / (dash + gap)).floor();
    final step = 2 * math.pi / count;
    final sweep = step * dash / (dash + gap);
    for (var i = 0; i < count; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * step,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
