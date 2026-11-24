import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/app_text_area.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/section_label.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaches_audience.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile_setup/presentation/teacher_setup_screen.dart'
    show profileCountries, profileTimeZones;
import '../../profile_setup/presentation/widgets/upload_tile.dart';
import '../../profile_setup/presentation/widgets/weekday_picker.dart';
import '../bloc/edit_profile_cubit.dart';
import '../bloc/edit_profile_state.dart';
import 'widgets/certificate_row.dart';

/// 20b Edit profile (student) / 20d Edit profile (teacher).
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<SessionCubit>().state.user;
    if (user == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<EditProfileCubit>(
      create: (context) =>
          EditProfileCubit(context.read<ProfileRepository>(), user),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late final TextEditingController _bio;
  late final TextEditingController _note;
  late final TextEditingController _qualifications;

  /// From / To options: every 30 minutes, 6:00 am to 11:00 pm.
  static final List<int> _times = <int>[
    for (var m = 6 * 60; m <= 23 * 60; m += 30) m,
  ];

  @override
  void initState() {
    super.initState();
    final p = context.read<EditProfileCubit>().state.draft;
    _bio = TextEditingController(text: p.bio ?? '');
    _note = TextEditingController(text: p.studentDetails?.note ?? '');
    _qualifications = TextEditingController(
      text: p.teacherDetails?.qualifications ?? '',
    );
  }

  @override
  void dispose() {
    _bio.dispose();
    _note.dispose();
    _qualifications.dispose();
    super.dispose();
  }

  static String _time(int minutes, String locale) => DateFormat.jm(
    locale,
  ).format(DateTime(2024, 1, 1, minutes ~/ 60, minutes % 60)).toLowerCase();

  Future<void> _pick<T>({
    required String title,
    required List<T> options,
    required T? current,
    required String Function(T) label,
    required ValueChanged<T> onSelected,
  }) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final chosen = await AppBottomSheet.show<T>(
      context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: AppTextStyles.titleLg.copyWith(color: colors.ink),
            ),
            const SizedBox(height: AppSpacing.space2),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  for (final option in options)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        label(option),
                        style: AppTextStyles.bodyLg.copyWith(color: colors.ink),
                      ),
                      trailing: option == current
                          ? AppIcon(AppIcon.check, color: colors.brand700)
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) {
      onSelected(chosen);
    }
  }

  Widget _select<T>({
    required String label,
    required T? value,
    required List<T> options,
    required String Function(T) text,
    required ValueChanged<T> onSelected,
  }) => AppTextField(
    key: ValueKey<String>('$label:${value == null ? '' : text(value)}'),
    label: label,
    initialValue: value == null ? '' : text(value),
    readOnly: true,
    trailingIcon: AppIcon.chevronDown,
    onTap: () => _pick<T>(
      title: label,
      options: options,
      current: value,
      label: text,
      onSelected: onSelected,
    ),
  );

  Widget _chips<T>(
    List<T> values,
    bool Function(T) selected,
    String Function(T) label,
    ValueChanged<T> onTap,
  ) => Wrap(
    spacing: AppSpacing.space2,
    runSpacing: AppSpacing.space2,
    children: <Widget>[
      for (final v in values)
        AppChip(label: label(v), selected: selected(v), onTap: () => onTap(v)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (a, b) => !a.saved && b.saved,
      listener: (context, _) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileSavedMessage)));
        context.pop();
      },
      builder: (context, state) {
        final cubit = context.read<EditProfileCubit>();
        final p = state.draft;
        return Scaffold(
          backgroundColor: colors.surface100,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                BackHeader(
                  title: l10n.editProfileTitle,
                  useClose: true,
                  trailing: <Widget>[
                    AppButton(
                      label: l10n.saveAction,
                      loading: state.saving,
                      onPressed: state.saving ? null : cubit.save,
                      size: AppButtonSize.small,
                      expand: false,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.space5,
                      AppSpacing.space2,
                      AppSpacing.space5,
                      28,
                    ),
                    children: p.isTeacher
                        ? _teacher(p, state, cubit, l10n, colors)
                        : _student(p, state, cubit, l10n, colors),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photo(
    Profile p,
    EditProfileCubit cubit,
    AppLocalizations l10n,
    AppColors colors, {
    required double size,
    required bool row,
  }) {
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        AppAvatar(profile: p, size: size),
        PositionedDirectional(
          end: -2,
          bottom: -2,
          child: Container(
            width: size > 80 ? 32 : 30,
            height: size > 80 ? 32 : 30,
            decoration: BoxDecoration(
              color: colors.brand600,
              shape: BoxShape.circle,
              border: Border.all(color: colors.surface100, width: 3),
            ),
            child: Center(
              child: AppIcon(AppIcon.camera, size: 16, color: colors.onBrand),
            ),
          ),
        ),
      ],
    );
    final button = TextButton(
      onPressed: cubit.photoChanged,
      style: TextButton.styleFrom(
        foregroundColor: colors.brand700,
        textStyle: AppTextStyles.label,
      ),
      child: Text(l10n.changePhotoAction),
    );
    return row
        ? Row(
            children: <Widget>[
              avatar,
              const SizedBox(width: AppSpacing.space4),
              button,
            ],
          )
        : Column(
            children: <Widget>[
              avatar,
              const SizedBox(height: AppSpacing.space1),
              button,
            ],
          );
  }

  Widget _name(
    Profile p,
    EditProfileState state,
    EditProfileCubit cubit,
    AppLocalizations l10n,
  ) => AppTextField(
    label: l10n.fullNameLabel,
    initialValue: p.fullName,
    errorText: state.nameMissing ? l10n.nameRequiredError : null,
    onChanged: cubit.nameChanged,
  );

  Widget _pair(Widget a, Widget b) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: <Widget>[
      Expanded(child: a),
      const SizedBox(width: AppSpacing.space3),
      Expanded(child: b),
    ],
  );

  List<Widget> _student(
    Profile p,
    EditProfileState state,
    EditProfileCubit cubit,
    AppLocalizations l10n,
    AppColors colors,
  ) {
    final s = p.studentDetails;
    const gap = SizedBox(height: AppSpacing.gap18);
    return <Widget>[
      _photo(p, cubit, l10n, colors, size: 88, row: false),
      gap,
      _name(p, state, cubit, l10n),
      gap,
      _pair(
        _select<Gender>(
          label: l10n.genderLabel,
          value: p.gender,
          options: Gender.values,
          text: (g) => g.label(l10n),
          onSelected: cubit.genderChanged,
        ),
        _select<LearnerAgeGroup>(
          label: l10n.ageGroupFieldLabel,
          value: s?.ageGroup,
          options: LearnerAgeGroup.values,
          text: (g) => g.label(l10n),
          onSelected: cubit.ageGroupChanged,
        ),
      ),
      gap,
      _pair(
        _select<String>(
          label: l10n.countryLabel,
          value: p.country,
          options: profileCountries,
          text: (c) => c,
          onSelected: cubit.countryChanged,
        ),
        _select<String>(
          label: l10n.timeZoneLabel,
          value: p.timeZone,
          options: profileTimeZones,
          text: (t) => t,
          onSelected: cubit.timeZoneChanged,
        ),
      ),
      gap,
      SectionLabel(l10n.wantToLearnLabel),
      const SizedBox(height: AppSpacing.gap10),
      _chips<Subject>(
        const <Subject>[
          Subject.nooraniQaida,
          Subject.nazra,
          Subject.tajweed,
          Subject.hifz,
          Subject.arabic,
        ],
        (g) => s?.goals.contains(g) ?? false,
        (g) => g.label(l10n),
        cubit.goalToggled,
      ),
      gap,
      AppTextArea(
        label: l10n.shortNoteLabel,
        controller: _note,
        maxLength: EditProfileState.noteMax,
        height: 80,
        placeholder: l10n.shortNotePlaceholder,
        onChanged: cubit.noteChanged,
      ),
    ];
  }

  List<Widget> _teacher(
    Profile p,
    EditProfileState state,
    EditProfileCubit cubit,
    AppLocalizations l10n,
    AppColors colors,
  ) {
    final t = p.teacherDetails;
    final locale = l10n.localeName;
    final from = t?.availableFromMinutes ?? 17 * 60;
    final to = t?.availableToMinutes ?? 21 * 60;
    final certificates = t?.certificatePaths ?? const <String>[];
    const gap = SizedBox(height: AppSpacing.gap18);
    return <Widget>[
      _photo(p, cubit, l10n, colors, size: 72, row: true),
      gap,
      _name(p, state, cubit, l10n),
      gap,
      AppTextField(
        label: l10n.headlineLabel,
        initialValue: p.headline ?? '',
        onChanged: cubit.headlineChanged,
      ),
      gap,
      _pair(
        _select<Gender>(
          label: l10n.genderLabel,
          value: p.gender,
          options: Gender.values,
          text: (g) => g.label(l10n),
          onSelected: cubit.genderChanged,
        ),
        _select<String>(
          label: l10n.countryLabel,
          value: p.country,
          options: profileCountries,
          text: (c) => c,
          onSelected: cubit.countryChanged,
        ),
      ),
      gap,
      _pair(
        _select<String>(
          label: l10n.timeZoneLabel,
          value: p.timeZone,
          options: profileTimeZones,
          text: (z) => z,
          onSelected: cubit.timeZoneChanged,
        ),
        AppTextField(
          label: l10n.experienceLabel,
          initialValue: t?.experienceYears?.toString() ?? '',
          keyboardType: TextInputType.number,
          onChanged: cubit.experienceChanged,
        ),
      ),
      gap,
      AppTextArea(
        label: l10n.qualificationsLabel,
        controller: _qualifications,
        maxLength: EditProfileState.qualificationsMax,
        height: 80,
        placeholder: l10n.qualificationsPlaceholder,
        onChanged: cubit.qualificationsChanged,
      ),
      gap,
      SectionLabel(l10n.subjectsLabel),
      const SizedBox(height: AppSpacing.gap10),
      _chips<Subject>(
        Subject.values,
        (s) => t?.subjects.contains(s) ?? false,
        (s) => s.label(l10n),
        cubit.subjectToggled,
      ),
      gap,
      SectionLabel(l10n.languagesLabel),
      const SizedBox(height: AppSpacing.gap10),
      _chips<TeachingLanguage>(
        const <TeachingLanguage>[
          TeachingLanguage.urdu,
          TeachingLanguage.english,
          TeachingLanguage.arabic,
          TeachingLanguage.punjabi,
          TeachingLanguage.pashto,
        ],
        p.languages.contains,
        (l) => l.label(l10n),
        cubit.languageToggled,
      ),
      gap,
      AppTextArea(
        label: l10n.bioLabel,
        controller: _bio,
        maxLength: EditProfileState.bioMax,
        onChanged: cubit.bioChanged,
      ),
      gap,
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: AppTextField(
              label: l10n.feeLabel(t?.feeCurrency ?? 'USD'),
              initialValue: t?.feeAmount == null
                  ? ''
                  : NumberFormat.decimalPattern(locale).format(t!.feeAmount),
              keyboardType: TextInputType.number,
              onChanged: cubit.feeChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            flex: 2,
            child: AppSegmentedControl<FeeUnit>(
              values: FeeUnit.values,
              selected: t?.feeUnit,
              label: (u) => u.label(l10n),
              onChanged: cubit.feeUnitChanged,
            ),
          ),
        ],
      ),
      gap,
      SectionLabel(
        l10n.availableDaysLabel,
        trailing: '${_time(from, locale)}–${_time(to, locale)}',
      ),
      const SizedBox(height: AppSpacing.gap10),
      WeekdayPicker(
        selected: t?.availableDays ?? const {},
        onToggle: cubit.dayToggled,
      ),
      gap,
      _pair(
        _select<int>(
          label: l10n.fromLabel,
          value: from,
          options: _times,
          text: (m) => _time(m, locale),
          onSelected: cubit.fromChanged,
        ),
        _select<int>(
          label: l10n.toLabel,
          value: to,
          options: _times,
          text: (m) => _time(m, locale),
          onSelected: cubit.toChanged,
        ),
      ),
      gap,
      SectionLabel(l10n.iTeachLabel),
      const SizedBox(height: AppSpacing.gap10),
      _chips<TeachesAudience>(
        TeachesAudience.values,
        (a) => t?.teaches.contains(a) ?? false,
        (a) => a.label(l10n),
        cubit.audienceToggled,
      ),
      gap,
      SectionLabel(
        l10n.certificatesLabel,
        trailing: certificates.isEmpty
            ? null
            : (p.isVerified
                  ? l10n.certificatesApprovedShort(certificates.length)
                  : l10n.certificatesInReviewShort(certificates.length)),
      ),
      const SizedBox(height: AppSpacing.gap10),
      for (final path in certificates) ...<Widget>[
        CertificateRow(
          path: path,
          onRemove: () => cubit.certificateRemoved(path),
        ),
        const SizedBox(height: AppSpacing.space2),
      ],
      UploadTile(
        label: l10n.uploadCertificateAction,
        hint: l10n.uploadCertificatesHint,
        onTap: cubit.certificateAdded,
      ),
    ];
  }
}
