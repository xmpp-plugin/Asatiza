import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/failures.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/logic/profile_strength_calculator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_switch.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/profile_strength_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/tag_chip.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teacher_gender_preference.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/enums/weekday.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/my_profile_cubit.dart';
import '../bloc/my_profile_state.dart';

/// 20a My profile (student) / 20c My profile (teacher).
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (user == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<MyProfileCubit>(
      create: (context) => MyProfileCubit(
        context.read<ProfileRepository>(),
        context.read<FeedRepository>(),
        context.read<ConnectionRepository>(),
        viewerId: user.id,
      ),
      child: const _MyProfileView(),
    );
  }
}

class _MyProfileView extends StatelessWidget {
  const _MyProfileView();

  static const ProfileStrengthCalculator _strength =
      ProfileStrengthCalculator();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.surface100,
      body: SafeArea(
        child: BlocBuilder<MyProfileCubit, MyProfileState>(
          builder: (context, state) {
            final p = state.profile;
            return Column(
              children: <Widget>[
                BackHeader(
                  title: l10n.myProfileTitle,
                  trailing: <Widget>[
                    IconButton(
                      tooltip: l10n.settingsTitle,
                      onPressed: () => context.push(AppRoutes.settings),
                      icon: AppIcon(
                        AppIcon.settings,
                        size: 22,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: p == null && state.loadError != null
                      ? Center(
                          child: EmptyStateView(
                            icon: AppIcon.user,
                            title: l10n.profileLoadFailedTitle,
                            message: state.loadError == ValidationReason.network
                                ? l10n.errorNoConnection
                                : l10n.errorSomethingWentWrong,
                          ),
                        )
                      : p == null
                      ? Center(
                          child: CircularProgressIndicator(
                            color: colors.brand600,
                            semanticsLabel: l10n.loadingLabel,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.space4,
                            AppSpacing.space1,
                            AppSpacing.space4,
                            AppSpacing.space6,
                          ),
                          children: _body(context, state, p, l10n, colors),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    MyProfileState state,
    Profile p,
    AppLocalizations l10n,
    AppColors colors,
  ) {
    final cubit = context.read<MyProfileCubit>();
    void edit() => context.push(AppRoutes.editProfile);
    final s = p.studentDetails;
    final studentLine = <String>[
      l10n.roleStudent,
      if (s?.ageGroup != null) l10n.learnerLabel(s!.ageGroup!.label(l10n)),
      ?p.city,
    ].join(' · ');
    const gap = SizedBox(height: AppSpacing.space4);
    return <Widget>[
      Row(
        children: <Widget>[
          AppAvatar(profile: p, size: 80, showVerified: true),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    p.fullName,
                    style: AppTextStyles.screenTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 30 / 24,
                      color: colors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.gap2),
                Text(
                  p.isTeacher ? (p.headline ?? l10n.roleTeacher) : studentLine,
                  style: AppTextStyles.body.copyWith(color: colors.inkMuted),
                ),
                if (p.isTeacher && p.isVerified) ...<Widget>[
                  const SizedBox(height: AppSpacing.gap6),
                  Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.space1,
                      3,
                      AppSpacing.gap10,
                      3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.gold100,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const VerifiedBadge(),
                        const SizedBox(width: AppSpacing.gap6),
                        Text(
                          l10n.verifiedTeacher,
                          style: AppTextStyles.captionBold.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.gold700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      gap,
      Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              label: l10n.editProfileAction,
              onPressed: edit,
              size: AppButtonSize.small,
              variant: AppButtonVariant.secondary,
              leading: AppIcon(
                AppIcon.pencil,
                size: 18,
                color: colors.brand700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: AppButton(
              label: l10n.connectionsCountAction(state.connectionCount),
              onPressed: () => context.push(AppRoutes.connections),
              size: AppButtonSize.small,
              variant: AppButtonVariant.secondary,
              leading: AppIcon(
                AppIcon.people,
                size: 18,
                color: colors.brand700,
              ),
            ),
          ),
        ],
      ),
      if (_strength.percent(p) < 100 &&
          !state.strengthCardDismissed) ...<Widget>[
        gap,
        ProfileStrengthCard(
          profile: p,
          onComplete: edit,
          onDismiss: cubit.dismissStrengthCard,
        ),
      ],
      if (!p.isTeacher) ...<Widget>[
        gap,
        _Card(
          child: MergeSemantics(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.lookingForTeacherLabel,
                        style: AppTextStyles.nameMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        l10n.lookingSwitchHint,
                        style: AppTextStyles.helper.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                AppSwitch(
                  value: s?.lookingForTeacher ?? false,
                  semanticLabel: l10n.lookingForTeacherLabel,
                  onChanged: cubit.lookingChanged,
                ),
              ],
            ),
          ),
        ),
        gap,
        SectionLabel(l10n.learningLabel),
        const SizedBox(height: AppSpacing.gap10),
        Wrap(
          spacing: AppSpacing.gap6,
          runSpacing: AppSpacing.gap6,
          children: <Widget>[
            for (final g in s?.goals ?? const <Subject>[])
              _Chip(g.label(l10n), brand: true),
            if (s?.level != null) _Chip(s!.level!.label(l10n)),
            if (p.languages.isNotEmpty)
              _Chip(p.languages.map((l) => l.label(l10n)).join(' · ')),
            if (s?.preferredTeacherGender != null)
              _Chip(switch (s!.preferredTeacherGender!) {
                TeacherGenderPreference.female => l10n.prefersFemaleTeacher,
                TeacherGenderPreference.male => l10n.prefersMaleTeacher,
                TeacherGenderPreference.any => l10n.prefersAnyTeacher,
              }),
          ],
        ),
      ] else ...<Widget>[gap, _teacherCard(p, l10n)],
      gap,
      SectionLabel(l10n.myPostsLabel),
      const SizedBox(height: AppSpacing.gap10),
      if (state.posts.isEmpty)
        Text(
          l10n.noPostsYet,
          style: AppTextStyles.body.copyWith(color: colors.inkMuted),
        )
      else
        for (final post in state.posts.take(3)) ...<Widget>[
          _PostSummary(
            post: post,
            onTap: () => context.push(AppRoutes.post(post.id)),
          ),
          const SizedBox(height: AppSpacing.gap10),
        ],
    ];
  }

  Widget _teacherCard(Profile p, AppLocalizations l10n) {
    final t = p.teacherDetails;
    final fee = t?.feeAmount;
    final days = (t?.availableDays ?? const <Weekday>{}).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    String time(int m, bool period) {
      final d = DateTime(2024, 1, 1, m ~/ 60, m % 60);
      return (period ? DateFormat('h:mm a') : DateFormat('h:mm'))
          .format(d)
          .toLowerCase();
    }

    final dayNames = days
        .map((d) => DateFormat.E().format(DateTime(2024, 1, 1 + d.index)))
        .join(', ');
    final from = t?.availableFromMinutes;
    final to = t?.availableToMinutes;
    final certificates = t?.certificatePaths.length ?? 0;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.gap6,
            runSpacing: AppSpacing.gap6,
            children: <Widget>[
              for (final s in t?.subjects ?? const <Subject>[])
                _Chip(s.label(l10n), brand: true),
              if (p.languages.isNotEmpty)
                _Chip(p.languages.map((l) => l.label(l10n)).join(' · ')),
            ],
          ),
          if (days.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.space3),
            InfoRow(
              icon: AppIcon.calendar,
              text: from == null || to == null
                  ? dayNames
                  : l10n.availabilityLine(
                      dayNames,
                      time(from, false),
                      time(to, true),
                    ),
            ),
          ],
          const SizedBox(height: AppSpacing.gap10),
          InfoRow(
            icon: AppIcon.document,
            text: certificates == 0
                ? l10n.noCertificatesYet
                : (p.isVerified
                      ? l10n.certificatesApproved(certificates)
                      : l10n.certificatesInReview(certificates)),
          ),
          if (fee != null) ...<Widget>[
            const SizedBox(height: AppSpacing.gap10),
            InfoRow(
              icon: AppIcon.clock,
              text: l10n.feeShortLabel,
              value: t!.feeUnit == FeeUnit.perClass
                  ? l10n.feePerClassLong(fee)
                  : l10n.feePerMonthLong(fee),
            ),
          ],
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.gap14),
      decoration: BoxDecoration(
        color: colors.surface000,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card(theme.brightness),
      ),
      child: child,
    );
  }
}

/// Own post in "My posts": text, tag and counts.
class _PostSummary extends StatelessWidget {
  const _PostSummary({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              post.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: colors.ink),
            ),
            const SizedBox(height: AppSpacing.gap10),
            Row(
              children: <Widget>[
                TagChip(tag: post.tag),
                const Spacer(),
                Text(
                  l10n.postCounts(post.likeCount, post.commentCount),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w400,
                    color: colors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 24 px detail chip: brand for subjects / goals, grey otherwise.
class _Chip extends StatelessWidget {
  const _Chip(this.label, {this.brand = false});

  final String label;
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      height: 24,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: brand ? colors.brand100 : colors.surface200,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: brand ? colors.brand700 : colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
