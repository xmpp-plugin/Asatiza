import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_option_tile.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/section_label.dart';
import '../../../data/models/enums/discover_sort.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/student_filter.dart';

/// 13b Student filter sheet: subject wanted, student gender, language,
/// country, level, learner age group and sort, with a live result count.
class StudentFilterSheet extends StatefulWidget {
  const StudentFilterSheet({
    required this.initial,
    required this.countries,
    required this.count,
    super.key,
  });

  final StudentFilter initial;

  /// Countries offered in the country picker.
  final List<String> countries;
  final int Function(StudentFilter filter) count;

  /// Opens the sheet; returns the applied filter, or null when dismissed.
  static Future<StudentFilter?> show(
    BuildContext context, {
    required StudentFilter initial,
    required List<String> countries,
    required int Function(StudentFilter filter) count,
  }) => AppBottomSheet.show<StudentFilter>(
    context,
    builder: (_) => StudentFilterSheet(
      initial: initial,
      countries: countries,
      count: count,
    ),
  );

  static const List<Subject> subjects = <Subject>[
    Subject.nooraniQaida,
    Subject.nazra,
    Subject.tajweed,
    Subject.hifz,
    Subject.arabic,
  ];

  static const List<TeachingLanguage> languages = <TeachingLanguage>[
    TeachingLanguage.urdu,
    TeachingLanguage.english,
    TeachingLanguage.arabic,
    TeachingLanguage.punjabi,
  ];

  @override
  State<StudentFilterSheet> createState() => _StudentFilterSheetState();
}

class _StudentFilterSheetState extends State<StudentFilterSheet> {
  late StudentFilter _draft = widget.initial;

  void _set(StudentFilter next) => setState(() => _draft = next);

  Set<T> _toggle<T>(Set<T> set, T value) =>
      set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  Future<void> _pickCountry(AppLocalizations l10n) async {
    final picked = await AppBottomSheet.show<String>(
      context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final option in <String>['', ...widget.countries]) ...<Widget>[
              AppOptionTile(
                title: option.isEmpty ? l10n.anyCountry : option,
                subtitle: '',
                selected: (_draft.country ?? '') == option,
                onTap: () => Navigator.of(context).pop(option),
              ),
              const SizedBox(height: AppSpacing.space2),
            ],
          ],
        ),
      ),
    );
    if (picked != null) {
      _set(_draft.copyWith(country: () => picked.isEmpty ? null : picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final count = widget.count(_draft);
    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionLabel(title),
        const SizedBox(height: AppSpacing.space2),
        child,
      ],
    );
    Widget chips<T>(
      Iterable<T> values,
      Set<T> selected,
      String Function(T) label,
      void Function(T) onTap,
    ) => Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: <Widget>[
        for (final v in values)
          AppChip(
            label: label(v),
            selected: selected.contains(v),
            onTap: () => onTap(v),
          ),
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
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.gap10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  section(
                    l10n.subjectWantedLabel,
                    chips<Subject>(
                      StudentFilterSheet.subjects,
                      _draft.subjects,
                      (s) => s.label(l10n),
                      (s) => _set(
                        _draft.copyWith(subjects: _toggle(_draft.subjects, s)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap14),
                  section(
                    l10n.studentGenderLabel,
                    AppSegmentedControl<Gender?>(
                      values: const <Gender?>[null, Gender.male, Gender.female],
                      selected: _draft.gender,
                      label: (g) => g == null ? l10n.genderAny : g.label(l10n),
                      onChanged: (g) => _set(_draft.copyWith(gender: () => g)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap14),
                  section(
                    l10n.languageFilterLabel,
                    chips<TeachingLanguage>(
                      StudentFilterSheet.languages,
                      _draft.languages,
                      (l) => l.label(l10n),
                      (l) => _set(
                        _draft.copyWith(
                          languages: _toggle(_draft.languages, l),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap14),
                  Text(
                    l10n.countryTimeZoneLabel,
                    style: AppTextStyles.label.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: AppSpacing.gap6),
                  Material(
                    color: colors.surface000,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      side: BorderSide(color: colors.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _pickCountry(l10n),
                      child: SizedBox(
                        height: 48,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.space4,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _draft.country ?? l10n.anyCountry,
                                  style: AppTextStyles.bodyLg.copyWith(
                                    color: colors.ink,
                                  ),
                                ),
                              ),
                              AppIcon(
                                AppIcon.chevronDown,
                                size: 20,
                                color: colors.inkMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap14),
                  section(
                    l10n.levelFilterLabel,
                    chips<LearnerLevel>(
                      LearnerLevel.values,
                      _draft.levels,
                      (v) => v.label(l10n),
                      (v) => _set(
                        _draft.copyWith(levels: _toggle(_draft.levels, v)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap14),
                  section(
                    l10n.learnerAgeGroupLabel,
                    chips<LearnerAgeGroup>(
                      LearnerAgeGroup.values,
                      _draft.ageGroups,
                      (v) => v.label(l10n),
                      (v) => _set(
                        _draft.copyWith(
                          ageGroups: _toggle(_draft.ageGroups, v),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap14),
                  section(
                    l10n.sortByLabel,
                    AppSegmentedControl<DiscoverSort>(
                      values: const <DiscoverSort>[
                        DiscoverSort.newest,
                        DiscoverSort.recommended,
                      ],
                      selected: _draft.sort,
                      label: (s) => s.label(l10n),
                      onChanged: (s) => _set(_draft.copyWith(sort: s)),
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
                label: l10n.showStudentsAction(count),
                onPressed: () => Navigator.of(context).pop(_draft),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
