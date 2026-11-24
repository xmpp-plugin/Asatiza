import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/failures.dart';
import '../../../core/logic/certificate_file_rules.dart';
import '../../../core/logic/profile_strength_calculator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/document_picker_service.dart';
import '../../../core/services/image_compressor.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_info_note.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/app_text_area.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/photo_source_sheet.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/step_progress_header.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/presentation/widgets/certificate_row.dart';
import '../bloc/teacher_setup_cubit.dart';
import '../bloc/teacher_setup_state.dart';
import 'widgets/photo_picker_tile.dart';
import 'widgets/upload_tile.dart';
import 'widgets/weekday_picker.dart';

/// Countries and time zones offered by the pickers (UI-only phase).
/// Countries offered in profile pickers (setup and Edit profile).
const List<String> profileCountries = <String>[
  'Pakistan',
  'India',
  'United Kingdom',
  'United States',
  'Canada',
  'United Arab Emirates',
  'Saudi Arabia',
  'Australia',
];

/// Time zones offered in profile pickers (setup and Edit profile).
const List<String> profileTimeZones = <String>[
  'GMT−5',
  'GMT+0',
  'GMT+1',
  'GMT+3',
  'GMT+4',
  'GMT+5',
  'GMT+5:30',
  'GMT+10',
];

/// 07a–07c Teacher setup (skip-able): photo + headline; subjects,
/// languages, gender, country, time zone; bio, experience, fee, days,
/// certificates.
class TeacherSetupScreen extends StatelessWidget {
  const TeacherSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<SessionCubit>().state.user!;
    return BlocProvider<TeacherSetupCubit>(
      create: (context) => TeacherSetupCubit(
        context.read<ProfileRepository>(),
        user,
        media: context.read<MediaRepository>(),
        picker: context.read<ImagePickerService>(),
        compressor: context.read<ImageCompressor>(),
        documents: context.read<DocumentPickerService>(),
      ),
      child: BlocListener<TeacherSetupCubit, TeacherSetupState>(
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
        child: BlocConsumer<TeacherSetupCubit, TeacherSetupState>(
          listenWhen: (a, b) => !a.done && b.done,
          listener: (context, _) {
            context.read<SessionCubit>().completeSetup();
            context.go(AppRoutes.home);
          },
          buildWhen: (a, b) => a.step != b.step,
          builder: (context, state) {
            final cubit = context.read<TeacherSetupCubit>();
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
                        total: TeacherSetupState.totalSteps,
                        onSkip: cubit.skip,
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

/// Scrollable step body whose last child sits at the bottom.
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

  static const ProfileStrengthCalculator _calculator =
      ProfileStrengthCalculator();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TeacherSetupCubit>();
    return BlocBuilder<TeacherSetupCubit, TeacherSetupState>(
      builder: (context, state) {
        final percent = _calculator.percent(state.draft);
        return _StepBody(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.space5,
            AppSpacing.space5,
            AppSpacing.space5,
            28,
          ),
          children: <Widget>[
            _Title(l10n.teacherSetupTitle1),
            const SizedBox(height: AppSpacing.space6),
            PhotoPickerTile(
              profile: state.draft,
              hasPhoto: state.draft.photoPath != null,
              title: l10n.addProfilePhoto,
              message: l10n.teacherPhotoHint,
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
            AppTextField(
              label: l10n.headlineLabel,
              initialValue: state.draft.headline,
              onChanged: cubit.headlineChanged,
              maxLength: TeacherSetupState.headlineMax,
              helper: l10n.headlineHint,
            ),
            const Spacer(),
            const SizedBox(height: AppSpacing.space6),
            Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: colors.surface200,
                        color: colors.brand600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.gap10),
                Text(
                  l10n.profilePercent(percent),
                  style: AppTextStyles.helper.copyWith(color: colors.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.gap10),
            AppButton(
              label: l10n.continueAction,
              loading: state.saving,
              onPressed: state.saving ? null : cubit.next,
            ),
          ],
        );
      },
    );
  }
}

class _StepTwo extends StatelessWidget {
  const _StepTwo({super.key});

  Future<void> _pick(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String? current,
    required ValueChanged<String> onSelected,
  }) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final chosen = await AppBottomSheet.show<String>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: AppTextStyles.titleLg.copyWith(color: colors.ink)),
          const SizedBox(height: AppSpacing.space2),
          for (final option in options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                option,
                style: AppTextStyles.bodyLg.copyWith(color: colors.ink),
              ),
              trailing: option == current
                  ? AppIcon(AppIcon.check, color: colors.brand700)
                  : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    );
    if (chosen != null) {
      onSelected(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TeacherSetupCubit>();
    return BlocBuilder<TeacherSetupCubit, TeacherSetupState>(
      builder: (context, state) => _StepBody(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.space5,
          AppSpacing.space5,
          AppSpacing.space5,
          28,
        ),
        children: <Widget>[
          _Title(l10n.teacherSetupTitle2),
          const SizedBox(height: AppSpacing.space5),
          SectionLabel(l10n.subjectsLabel),
          const SizedBox(height: AppSpacing.gap10),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: <Widget>[
              for (final s in Subject.values)
                AppChip(
                  label: s.label(l10n),
                  selected: state.details.subjects.contains(s),
                  onTap: () => cubit.subjectToggled(s),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          SectionLabel(l10n.teachingLanguagesLabel),
          const SizedBox(height: AppSpacing.gap10),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: <Widget>[
              for (final lang in TeachingLanguage.values)
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
                  onTap: () => _pick(
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
                  onTap: () => _pick(
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
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            label: l10n.continueAction,
            loading: state.saving,
            onPressed: state.saving ? null : cubit.next,
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
  late final TextEditingController _bio;
  late final TextEditingController _qualifications;

  @override
  void initState() {
    super.initState();
    _bio = TextEditingController(
      text: context.read<TeacherSetupCubit>().state.draft.bio ?? '',
    );
    _qualifications = TextEditingController(
      text:
          context.read<TeacherSetupCubit>().state.details.qualifications ?? '',
    );
  }

  @override
  void dispose() {
    _bio.dispose();
    _qualifications.dispose();
    super.dispose();
  }

  String _time(int minutes, String locale) {
    final t = DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60);
    return DateFormat.jm(locale).format(t).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TeacherSetupCubit>();
    return BlocBuilder<TeacherSetupCubit, TeacherSetupState>(
      builder: (context, state) {
        final d = state.details;
        final from = d.availableFromMinutes ?? TeacherSetupCubit.defaultFrom;
        final to = d.availableToMinutes ?? TeacherSetupCubit.defaultTo;
        return _StepBody(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.space5,
            AppSpacing.space4,
            AppSpacing.space5,
            AppSpacing.space6,
          ),
          children: <Widget>[
            _Title(l10n.teacherSetupTitle3),
            const SizedBox(height: AppSpacing.space4),
            AppTextArea(
              label: l10n.bioLabel,
              controller: _bio,
              maxLength: TeacherSetupState.bioMax,
              onChanged: cubit.bioChanged,
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    label: l10n.experienceLabel,
                    initialValue: d.experienceYears?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: cubit.experienceChanged,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: AppTextField(
                    label: l10n.feeLabel(d.feeCurrency),
                    initialValue: d.feeAmount == null
                        ? ''
                        : NumberFormat.decimalPattern(
                            l10n.localeName,
                          ).format(d.feeAmount),
                    keyboardType: TextInputType.number,
                    onChanged: cubit.feeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            AppSegmentedControl<FeeUnit>(
              values: FeeUnit.values,
              selected: d.feeUnit,
              label: (u) => u.label(l10n),
              onChanged: cubit.feeUnitChanged,
            ),
            const SizedBox(height: AppSpacing.space4),
            AppTextArea(
              label: l10n.qualificationsLabel,
              controller: _qualifications,
              maxLength: TeacherSetupState.qualificationsMax,
              height: 80,
              placeholder: l10n.qualificationsPlaceholder,
              onChanged: cubit.qualificationsChanged,
            ),
            const SizedBox(height: AppSpacing.space4),
            SectionLabel(
              l10n.availableDaysLabel,
              trailing:
                  '${_time(from, l10n.localeName)}–${_time(to, l10n.localeName)}',
            ),
            const SizedBox(height: AppSpacing.gap10),
            WeekdayPicker(
              selected: d.availableDays,
              onToggle: cubit.dayToggled,
            ),
            const SizedBox(height: AppSpacing.space4),
            for (final path in d.certificatePaths) ...<Widget>[
              CertificateRow(
                path: path,
                onTap: () => context.push(AppRoutes.certificate(path)),
                onRemove: () => cubit.certificateRemoved(path),
              ),
              const SizedBox(height: AppSpacing.space2),
            ],
            // Decision 2: one certificate; the tile hides at the limit.
            if (const CertificateFileRules().canAdd(
              d.certificatePaths.length,
            )) ...<Widget>[
              UploadTile(
                label: l10n.uploadCertificatesAction,
                hint: l10n.uploadCertificatesHint,
                loading: state.uploadingCertificate,
                onTap: cubit.certificatePicked,
              ),
              const SizedBox(height: AppSpacing.space2),
            ],
            AppInfoNote(text: l10n.certificateInstructions),
            const Spacer(),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              label: l10n.finishSetupAction,
              loading: state.saving,
              onPressed: state.saving ? null : cubit.next,
            ),
          ],
        );
      },
    );
  }
}
