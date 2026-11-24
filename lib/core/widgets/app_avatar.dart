import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'verified_badge.dart';

/// Round avatar: the profile photo when there is one (PHASE_005), else the
/// initials on a token tint picked from the profile id so a person keeps
/// the same colour everywhere. The initials also show while the photo
/// loads and when it fails. Optionally shows the verified badge on the
/// bottom-end edge.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.profile,
    super.key,
    this.size = 44,
    this.showVerified = false,
    this.showPhoto = true,
    this.preview,
  });

  final Profile profile;

  /// 36 (comments), 40 (top bar / composer), 44 (posts), 52 (lists).
  final double size;
  final bool showVerified;

  /// False hides the photo (student photos in discover lists, plan
  /// section 16).
  final bool showPhoto;

  /// A just-picked photo not saved yet; shown instead of the stored one.
  final Uint8List? preview;

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

    final initials = Container(
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
    final circle = _photo(initials) ?? initials;

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

  /// The photo clipped to a circle over [initials], or null when none.
  Widget? _photo(Widget initials) {
    if (!showPhoto) {
      return null;
    }
    final bytes = preview;
    final url = profile.photoUrl;
    final Widget image;
    if (bytes != null) {
      image = Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => initials,
      );
    } else if (url != null && url.isNotEmpty) {
      image = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        frameBuilder: (_, child, frame, loaded) =>
            loaded || frame != null ? child : initials,
        errorBuilder: (_, _, _) => initials,
      );
    } else {
      return null;
    }
    return ClipOval(
      child: SizedBox(width: size, height: size, child: image),
    );
  }
}
