import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/app_switch.dart';
import '../../../core/widgets/section_label.dart';
import '../../../data/models/enums/experience_filter.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/teacher_filter.dart';
import 'widgets/fee_range_slider.dart';

/// 13 Filter sheet (Teachers): subject, teacher gender, language, monthly
/// fee, experience and "Teaches children", with a live result count.
class TeacherFilterSheet extends StatefulWidget {
  const TeacherFilterSheet({
    required this.initial,
    required this.count,
    super.key,
  });

  final TeacherFilter initial;
  final int Function(TeacherFilter filter) count;

  /// Opens the sheet; returns the applied filter, or null when dismissed.
  static Future<TeacherFilter?> show(
    BuildContext context, {
    required TeacherFilter initial,
    required int Function(TeacherFilter filter) count,
  }) => AppBottomSheet.show<TeacherFilter>(
    context,
    builder: (_) => TeacherFilterSheet(initial: initial, count: count),
  );

  /// Subjects offered as filter chips (artboard order).
  static const List<Subject> subjects = <Subject>[
    Subject.nooraniQaida,
    Subject.nazra,
    Subject.tajweed,
    Subject.hifz,
    Subject.tafsir,
    Subject.arabic,
  ];

  static const List<TeachingLanguage> languages = <TeachingLanguage>[
    TeachingLanguage.urdu,
    TeachingLanguage.english,
    TeachingLanguage.arabic,
    TeachingLanguage.punjabi,
  ];

  @override
  State<TeacherFilterSheet> createState() => _TeacherFilterSheetState();
}

class _TeacherFilterSheetState extends State<TeacherFilterSheet> {
  late TeacherFilter _draft = widget.initial;

  void _set(TeacherFilter next) => setState(() => _draft = next);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final count = widget.count(_draft);
    Widget section(String title, Widget child, {String? trailing}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: SectionLabel(title)),
            if (trailing != null)
              Text(
                trailing,
                style: AppTextStyles.helperStrong.copyWith(
                  color: colors.gold700,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.gap10),
        child,
      ],
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.filtersTitle,
                    style: AppTextStyles.titleLg.copyWith(color: colors.ink),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _set(_draft.reset()),
                style: TextButton.styleFrom(
                  foregroundColor: colors.brand700,
                  textStyle: AppTextStyles.label,
                ),
                child: Text(l10n.resetAction),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  section(
                    l10n.subjectFilterLabel,
                    Wrap(
                      spacing: AppSpacing.space2,
                      runSpacing: AppSpacing.space2,
                      children: <Widget>[
                        for (final s in TeacherFilterSheet.subjects)
                          AppChip(
                            label: s.label(l10n),
                            selected: _draft.subjects.contains(s),
                            onTap: () => _set(
                              _draft.copyWith(
                                subjects: _draft.subjects.contains(s)
                                    ? ({..._draft.subjects}..remove(s))
                                    : {..._draft.subjects, s},
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap18),
                  section(
                    l10n.teacherGenderLabel,
                    AppSegmentedControl<Gender?>(
                      values: const <Gender?>[null, Gender.male, Gender.female],
                      selected: _draft.gender,
                      label: (g) => g == null ? l10n.genderAny : g.label(l10n),
                      onChanged: (g) => _set(_draft.copyWith(gender: () => g)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap18),
                  section(
                    l10n.languageFilterLabel,
                    Wrap(
                      spacing: AppSpacing.space2,
                      runSpacing: AppSpacing.space2,
                      children: <Widget>[
                        for (final language in TeacherFilterSheet.languages)
                          AppChip(
                            label: language.label(l10n),
                            selected: _draft.languages.contains(language),
                            onTap: () => _set(
                              _draft.copyWith(
                                languages: _draft.languages.contains(language)
                                    ? ({..._draft.languages}..remove(language))
                                    : {..._draft.languages, language},
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap18),
                  section(
                    l10n.monthlyFeeLabel,
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.gap2),
                      child: FeeRangeSlider(
                        min: TeacherFilter.feeFloor,
                        max: TeacherFilter.feeCeiling,
                        start: _draft.feeMin,
                        end: _draft.feeMax,
                        semanticLabel: l10n.monthlyFeeLabel,
                        describe: l10n.feeRange,
                        onChanged: (start, end) =>
                            _set(_draft.copyWith(feeMin: start, feeMax: end)),
                      ),
                    ),
                    trailing: l10n.feeRange(_draft.feeMin, _draft.feeMax),
                  ),
                  const SizedBox(height: AppSpacing.gap18),
                  section(
                    l10n.experienceFilterLabel,
                    Wrap(
                      spacing: AppSpacing.space2,
                      runSpacing: AppSpacing.space2,
                      children: <Widget>[
                        for (final e in ExperienceFilter.values)
                          AppChip(
                            label: e.label(l10n),
                            selected: _draft.experience == e,
                            onTap: () => _set(_draft.copyWith(experience: e)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap18),
                  MergeSemantics(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            l10n.teachesChildrenLabel,
                            style: AppTextStyles.nameMd.copyWith(
                              color: colors.ink,
                            ),
                          ),
                        ),
                        AppSwitch(
                          value: _draft.teachesChildren,
                          semanticLabel: l10n.teachesChildrenLabel,
                          onChanged: (v) =>
                              _set(_draft.copyWith(teachesChildren: v)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.line)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space3),
              child: AppButton(
                label: l10n.showTeachersAction(count),
                onPressed: () => Navigator.of(context).pop(_draft),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
