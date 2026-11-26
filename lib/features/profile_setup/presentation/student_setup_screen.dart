import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/image_compressor.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_option_tile.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/app_switch.dart';
import '../../../core/widgets/app_text_area.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/step_progress_header.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teacher_gender_preference.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../core/widgets/photo_source_sheet.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/student_setup_cubit.dart';
import '../bloc/student_setup_state.dart';
import 'teacher_setup_screen.dart'
    show pickProfileOption, profileCountries, profileTimeZones;
import 'widgets/photo_picker_tile.dart';

/// Subjects and languages offered to students (artboard 07d).
const List<Subject> _studentSubjects = <Subject>[
  Subject.nooraniQaida,
  Subject.nazra,
  Subject.tajweed,
  Subject.hifz,
  Subject.tafsir,
  Subject.arabic,
];
const List<TeachingLanguage> _studentLanguages = <TeachingLanguage>[
  TeachingLanguage.urdu,
  TeachingLanguage.english,
  TeachingLanguage.arabic,
  TeachingLanguage.punjabi,
];

/// 07e / 07d / 07f Student setup (required fields, no Skip): photo + learner age group;
/// goals, level, languages; preferred teacher gender, "Looking for a
/// teacher", short note.
class StudentSetupScreen extends StatelessWidget {
  const StudentSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<SessionCubit>().state.user!;
    return BlocProvider<StudentSetupCubit>(
      create: (context) => StudentSetupCubit(
        context.read<ProfileRepository>(),
        user,
        media: context.read<MediaRepository>(),
        picker: context.read<ImagePickerService>(),
        compressor: context.read<ImageCompressor>(),
      ),
      child: BlocListener<StudentSetupCubit, StudentSetupState>(
        listenWhen: (a, b) =>
            b.mediaError != null && a.mediaError != b.mediaError,
        listener: (context, state) =>
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _mediaErrorText(
                    state.mediaError!,
                    AppLocalizations.of(context),
                  ),
                ),
              ),
            ),
        child: BlocConsumer<StudentSetupCubit, StudentSetupState>(
          listenWhen: (a, b) => !a.done && b.done,
          listener: (context, state) {
            context.read<SessionCubit>().completeSetup(state.draft);
            context.go(AppRoutes.home);
          },
          buildWhen: (a, b) => a.step != b.step,
          builder: (context, state) {
            final cubit = context.read<StudentSetupCubit>();
            return PopScope(
              canPop: state.step == 1,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) {
                  cubit.back();
                }
              },
              child: Scaffold(
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      StepProgressHeader(
                        step: state.step,
                        total: StudentSetupState.totalSteps,
                        onBack: state.step > 1 ? cubit.back : null,
                      ),
                      Expanded(
                        child: switch (state.step) {
                          1 => const _StepOne(key: ValueKey<int>(1)),
                          2 => const _StepTwo(key: ValueKey<int>(2)),
                          _ => const _StepThree(key: ValueKey<int>(3)),
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Message for a refused or failed photo / certificate upload.
String _mediaErrorText(ValidationReason reason, AppLocalizations l10n) =>
    switch (reason) {
      ValidationReason.fileTooLarge => l10n.uploadErrorTooLarge,
      ValidationReason.fileTypeNotAllowed => l10n.uploadErrorNotPdf,
      ValidationReason.certificateLimitReached =>
        l10n.uploadErrorCertificateLimit,
      ValidationReason.network => l10n.errorNoConnection,
      _ => l10n.uploadErrorFailed,
    };

class _StepBody extends StatelessWidget {
  const _StepBody({required this.padding, required this.children});

  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Semantics(
      header: true,
      child: Text(
        text,
        style: AppTextStyles.authTitle.copyWith(color: colors.ink),
      ),
    );
  }
}

class _StepOne extends StatelessWidget {
  const _StepOne({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<StudentSetupCubit>();
    return BlocBuilder<StudentSetupCubit, StudentSetupState>(
      builder: (context, state) => _StepBody(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.space5,
          AppSpacing.space5,
          AppSpacing.space5,
          28,
        ),
        children: <Widget>[
          _Title(l10n.studentSetupTitle1),
          const SizedBox(height: AppSpacing.space6),
          PhotoPickerTile(
            profile: state.draft,
            hasPhoto: state.draft.photoPath != null,
            title: l10n.addPhotoOptional,
            message: l10n.studentPhotoHint,
            semanticLabel: l10n.addProfilePhoto,
            preview: state.photoPreview,
            loading: state.uploadingPhoto,
            onTap: () async {
              final source = await PhotoSourceSheet.show(context);
              if (source != null) {
                await cubit.photoPicked(source);
              }
            },
          ),
          const SizedBox(height: AppSpacing.space6),
          SectionLabel(l10n.learnerAgeGroupLabel),
          const SizedBox(height: AppSpacing.gap10),
          Row(
            children: <Widget>[
              for (final group in LearnerAgeGroup.values) ...<Widget>[
                if (group != LearnerAgeGroup.values.first)
                  const SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: _AgeGroupCard(
                    title: group.label(l10n),
                    range: group.range(l10n),
                    selected: state.details.ageGroup == group,
                    onTap: () => cubit.ageGroupChanged(group),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.space6),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.gap14,
              vertical: AppSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: colors.surface200,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppIcon(AppIcon.info, size: 18, color: colors.inkMuted),
                const SizedBox(width: AppSpacing.gap10),
                Expanded(
                  child: Text(
                    l10n.parentSetupNote,
                    style: AppTextStyles.helper.copyWith(
                      color: colors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.space6),
          AppButton(
            label: l10n.continueAction,
            loading: state.saving,
            onPressed: state.saving || !state.stepComplete ? null : cubit.next,
          ),
        ],
      ),
    );
  }
}

class _StepTwo extends StatelessWidget {
  const _StepTwo({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<StudentSetupCubit>();
    return BlocBuilder<StudentSetupCubit, StudentSetupState>(
      builder: (context, state) => _StepBody(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.space5,
          AppSpacing.space4,
          AppSpacing.space5,
          AppSpacing.space6,
        ),
        children: <Widget>[
          _Title(l10n.studentSetupTitle2),
          const SizedBox(height: AppSpacing.gap18),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: <Widget>[
              for (final s in _studentSubjects)
                AppChip(
                  label: s.label(l10n),
                  selected: state.details.goals.contains(s),
                  onTap: () => cubit.goalToggled(s),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.gap18),
          SectionLabel(l10n.currentLevelLabel),
          const SizedBox(height: AppSpacing.gap10),
          for (final level in LearnerLevel.values) ...<Widget>[
            if (level != LearnerLevel.values.first)
              const SizedBox(height: AppSpacing.gap10),
            AppOptionTile(
              title: level.label(l10n),
              subtitle: level.description(l10n),
              selected: state.details.level == level,
              onTap: () => cubit.levelChanged(level),
            ),
          ],
          const SizedBox(height: AppSpacing.gap18),
          SectionLabel(l10n.languagesLabel),
          const SizedBox(height: AppSpacing.gap10),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: <Widget>[
              for (final lang in _studentLanguages)
                AppChip(
                  label: lang.label(l10n),
                  selected: state.draft.languages.contains(lang),
                  onTap: () => cubit.languageToggled(lang),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          SectionLabel(l10n.genderLabel),
          const SizedBox(height: AppSpacing.gap10),
          AppSegmentedControl<Gender>(
            values: Gender.values,
            selected: state.draft.gender,
            label: (g) => g.label(l10n),
            onChanged: cubit.genderChanged,
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            children: <Widget>[
              Expanded(
                child: AppTextField(
                  key: ValueKey<String?>('country-${state.draft.country}'),
                  label: l10n.countryLabel,
                  initialValue: state.draft.country ?? '',
                  readOnly: true,
                  trailingIcon: AppIcon.chevronDown,
                  onTap: () => pickProfileOption(
                    context,
                    title: l10n.countryLabel,
                    options: profileCountries,
                    current: state.draft.country,
                    onSelected: cubit.countryChanged,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: AppTextField(
                  key: ValueKey<String?>('tz-${state.draft.timeZone}'),
                  label: l10n.timeZoneLabel,
                  initialValue: state.draft.timeZone ?? '',
                  readOnly: true,
                  trailingIcon: AppIcon.chevronDown,
                  onTap: () => pickProfileOption(
                    context,
                    title: l10n.timeZoneLabel,
                    options: profileTimeZones,
                    current: state.draft.timeZone,
                    onSelected: cubit.timeZoneChanged,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.gap18),
          AppButton(
            label: l10n.continueAction,
            loading: state.saving,
            onPressed: state.saving || !state.stepComplete ? null : cubit.next,
          ),
        ],
      ),
    );
  }
}

class _StepThree extends StatefulWidget {
  const _StepThree({super.key});

  @override
  State<_StepThree> createState() => _StepThreeState();
}

class _StepThreeState extends State<_StepThree> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(
      text: context.read<StudentSetupCubit>().state.details.note ?? '',
    );
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<StudentSetupCubit>();
    return BlocBuilder<StudentSetupCubit, StudentSetupState>(
      builder: (context, state) => _StepBody(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.space5,
          AppSpacing.space5,
          AppSpacing.space5,
          28,
        ),
        children: <Widget>[
          _Title(l10n.studentSetupTitle3),
          const SizedBox(height: AppSpacing.gap22),
          SectionLabel(l10n.preferredTeacherGenderLabel),
          const SizedBox(height: AppSpacing.gap10),
          AppSegmentedControl<TeacherGenderPreference>(
            values: TeacherGenderPreference.values,
            selected: state.details.preferredTeacherGender,
            label: (p) => p.label(l10n),
            onChanged: cubit.preferenceChanged,
          ),
          const SizedBox(height: AppSpacing.gap22),
          Container(
            padding: const EdgeInsets.all(AppSpacing.gap14),
            decoration: BoxDecoration(
              color: colors.surface000,
              border: Border.all(color: colors.line),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card(theme.brightness),
            ),
            child: MergeSemantics(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.lookingForTeacherLabel,
                          style: AppTextStyles.sectionTitle.copyWith(
                            color: colors.ink,
                          ),
                        ),
                        Text(
                          l10n.lookingForTeacherHint,
                          style: AppTextStyles.helper.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  AppSwitch(
                    value: state.details.lookingForTeacher,
                    onChanged: cubit.lookingChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.gap22),
          AppTextArea(
            label: l10n.shortNoteLabel,
            controller: _note,
            maxLength: StudentSetupState.noteMax,
            height: 112,
            placeholder: l10n.shortNotePlaceholder,
            onChanged: cubit.noteChanged,
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.gap22),
          AppButton(
            label: l10n.finishSetupAction,
            loading: state.saving,
            onPressed: state.saving || !state.stepComplete ? null : cubit.next,
          ),
        ],
      ),
    );
  }
}

/// Child / Teen / Adult card (14 px radius), centred title and range.
class _AgeGroupCard extends StatelessWidget {
  const _AgeGroupCard({
    required this.title,
    required this.range,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String range;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.brand100 : colors.surface000,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.optionCard),
          side: BorderSide(
            color: selected ? colors.brand600 : colors.line,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.space3,
              horizontal: AppSpacing.space2,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(color: colors.ink),
                ),
                const SizedBox(height: AppSpacing.gap2),
                Text(
                  range,
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
    );
  }
}
