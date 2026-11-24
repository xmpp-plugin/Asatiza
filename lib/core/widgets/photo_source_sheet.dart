import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../services/image_source_kind.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';
import 'app_icon.dart';
import 'settings_tile.dart';

/// "Profile photo" sheet with Take a photo / Choose from gallery
/// (PHASE_005, decision 1). Used by profile setup and Edit profile.
class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key});

  /// The chosen source, or null when the sheet was dismissed.
  static Future<ImageSourceKind?> show(BuildContext context) =>
      AppBottomSheet.show<ImageSourceKind>(
        context,
        builder: (_) => const PhotoSourceSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.photoSourceTitle,
          style: AppTextStyles.titleLg.copyWith(color: colors.ink),
        ),
        const SizedBox(height: AppSpacing.space2),
        SettingsTile(
          icon: AppIcon.camera,
          label: l10n.photoSourceCamera,
          chevron: false,
          onTap: () => Navigator.of(context).pop(ImageSourceKind.camera),
        ),
        SettingsTile(
          icon: AppIcon.image,
          label: l10n.photoSourceGallery,
          chevron: false,
          onTap: () => Navigator.of(context).pop(ImageSourceKind.gallery),
        ),
      ],
    );
  }
}
