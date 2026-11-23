import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/back_header.dart';
import '../../../l10n/app_localizations.dart';

/// The three policy pages (artboards 21c / 21d / 21e).
enum PolicyPage { content, privacy, terms }

/// 21c Content policy / 21d Privacy policy / 21e Terms of use. The texts
/// were written by the design tool and need owner / legal review before
/// launch.
class PolicyScreen extends StatelessWidget {
  const PolicyScreen({required this.page, super.key});

  final PolicyPage page;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    Widget heading(String text) => Semantics(
      header: true,
      child: Text(
        text,
        style: AppTextStyles.cardTitle.copyWith(color: colors.ink),
      ),
    );
    Widget paragraph(String text) => Text(
      text,
      style: AppTextStyles.body.copyWith(height: 21 / 14, color: colors.ink),
    );
    Widget bullet(String text, {required bool allowed}) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.gap6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AppIcon(
              allowed ? AppIcon.check : AppIcon.close,
              size: 18,
              strokeWidth: 2.2,
              color: allowed ? colors.brand700 : colors.danger,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
    List<Widget> section(String title, List<Widget> body) => <Widget>[
      const SizedBox(height: AppSpacing.gap18),
      heading(title),
      const SizedBox(height: AppSpacing.gap6),
      ...body,
    ];

    final (String title, List<Widget> sections) = switch (page) {
      PolicyPage.content => (
        l10n.contentPolicyTitle,
        <Widget>[
          ...section(l10n.contentAimTitle, [paragraph(l10n.contentAimBody)]),
          ...section(l10n.contentShareTitle, [
            bullet(l10n.contentShare1, allowed: true),
            bullet(l10n.contentShare2, allowed: true),
            bullet(l10n.contentShare3, allowed: true),
          ]),
          ...section(l10n.contentNotAllowedTitle, [
            bullet(l10n.contentNotAllowed1, allowed: false),
            bullet(l10n.contentNotAllowed2, allowed: false),
            bullet(l10n.contentNotAllowed3, allowed: false),
            bullet(l10n.contentNotAllowed4, allowed: false),
          ]),
          ...section(l10n.contentReportingTitle, [
            paragraph(l10n.contentReportingBody),
          ]),
        ],
      ),
      PolicyPage.privacy => (
        l10n.privacyPolicyTitle,
        <Widget>[
          ...section(l10n.privacyCollectTitle, [
            paragraph(l10n.privacyCollectBody),
          ]),
          ...section(l10n.privacyUseTitle, [paragraph(l10n.privacyUseBody)]),
          ...section(l10n.privacySeeTitle, [paragraph(l10n.privacySeeBody)]),
          ...section(l10n.privacyChoicesTitle, [
            paragraph(l10n.privacyChoicesBody),
          ]),
        ],
      ),
      PolicyPage.terms => (
        l10n.termsTitle,
        <Widget>[
          ...section(l10n.termsJoinTitle, [paragraph(l10n.termsJoinBody)]),
          ...section(l10n.termsAccountTitle, [
            paragraph(l10n.termsAccountBody),
          ]),
          ...section(l10n.termsClassesTitle, [
            paragraph(l10n.termsClassesBody),
          ]),
          ...section(l10n.termsContentTitle, [
            paragraph(l10n.termsContentBody),
          ]),
          ...section(l10n.termsEndingTitle, [paragraph(l10n.termsEndingBody)]),
        ],
      ),
    };
    return Scaffold(
      backgroundColor: colors.surface100,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            BackHeader(title: title),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.space5,
                  AppSpacing.space1,
                  AppSpacing.space5,
                  AppSpacing.space6,
                ),
                children: <Widget>[
                  Text(
                    l10n.policyLastUpdated,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w400,
                      color: colors.inkMuted,
                    ),
                  ),
                  ...sections,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
