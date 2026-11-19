import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'verified_badge.dart';

/// Initials avatar on a token tint (the design shows no photos). The tint
/// is picked from the profile id so a person keeps the same colour
/// everywhere. Optionally shows the verified badge on the bottom-end edge.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.profile,
    super.key,
    this.size = 44,
    this.showVerified = false,
  });

  final Profile profile;

  /// 36 (comments), 40 (top bar / composer), 44 (posts), 52 (lists).
  final double size;
  final bool showVerified;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final tints = <(Color, Color)>[
      (colors.brand100, colors.brand700),
      (colors.gold100, colors.gold700),
      (colors.brand100, colors.brand700),
      (colors.surface200, colors.ink),
    ];
    final (background, foreground) =
        tints[profile.id.codeUnits.fold(0, (a, b) => a + b) % tints.length];
    final fontSize = (size * 0.36).roundToDouble();

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        profile.initials,
        style: AppTextStyles.label.copyWith(
          fontSize: fontSize,
          height: 1,
          color: foreground,
        ),
      ),
    );

    return Semantics(
      label: profile.fullName,
      image: true,
      excludeSemantics: true,
      child: !showVerified || !profile.isVerified
          ? circle
          : Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                circle,
                PositionedDirectional(
                  end: -2,
                  bottom: -2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface000, width: 2),
                    ),
                    child: const VerifiedBadge(size: 18),
                  ),
                ),
              ],
            ),
    );
  }
}
