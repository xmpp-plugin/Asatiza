import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/profile_header.dart';
import '../../../core/widgets/section_label.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/enums/connection_status.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teacher_gender_preference.dart';
import '../../../data/models/enums/teaches_audience.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/enums/weekday.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/teacher_details.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/block_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../connections/presentation/connect_sheet.dart';
import '../bloc/public_profile_cubit.dart';
import '../bloc/public_profile_state.dart';

/// 14 Public profile (teacher) / 14b Public profile (student).
class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context) {
    final viewer = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (viewer == null) {
      return const SizedBox.shrink();
    }
    return BlocProvider<PublicProfileCubit>(
      create: (context) => PublicProfileCubit(
        context.read<ProfileRepository>(),
        context.read<ConnectionRepository>(),
        context.read<FeedRepository>(),
        context.read<BlockRepository>(),
        viewerId: viewer.id,
        profileId: profileId,
      ),
      child: _PublicProfileView(viewerId: viewer.id),
    );
  }
}

class _PublicProfileView extends StatelessWidget {
  const _PublicProfileView({required this.viewerId});

  final String viewerId;

  Future<void> _share(BuildContext context, Profile p) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(text: l10n.profileShareText(p.fullName, p.headline ?? '')),
    );
    messenger.showSnackBar(SnackBar(content: Text(l10n.profileCopiedMessage)));
  }

  Future<void> _more(BuildContext context, Profile p) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PublicProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final block = await AppBottomSheet.show<bool>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.blockUserTitle(p.fullName),
            style: AppTextStyles.pageTitle.copyWith(color: colors.ink),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            l10n.blockUserMessage,
            style: AppTextStyles.body.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            label: l10n.blockAction,
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.space2),
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: colors.brand700,
                textStyle: AppTextStyles.label,
              ),
              child: Text(l10n.cancelAction),
            ),
          ),
        ],
      ),
    );
    if ((block ?? false) && !await cubit.block()) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.blockFailedMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return BlocConsumer<PublicProfileCubit, PublicProfileState>(
      listenWhen: (a, b) => !a.blocked && b.blocked,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.userBlockedMessage(state.profile!.fullName)),
          ),
        );
        context.pop();
      },
      builder: (context, state) {
        final p = state.profile;
        return Scaffold(
          backgroundColor: colors.surface100,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.gap6,
                      end: AppSpacing.space4,
                    ),
                    child: Row(
                      children: <Widget>[
                        _HeaderButton(
                          icon: AppIcon.chevronLeft,
                          size: 24,
                          label: l10n.backAction,
                          onTap: () => context.pop(),
                        ),
                        const Spacer(),
                        if (p != null) ...<Widget>[
                          _HeaderButton(
                            icon: AppIcon.share,
                            label: l10n.shareProfileAction,
                            onTap: () => _share(context, p),
                          ),
                          _HeaderButton(
                            icon: AppIcon.more,
                            label: l10n.reportOrBlockAction,
                            onTap: () => _more(context, p),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: state.notFound
                      ? Center(
                          child: EmptyStateView(
                            icon: AppIcon.user,
                            title: l10n.profileUnavailableTitle,
                            message: l10n.profileUnavailableMessage,
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
                            0,
                            AppSpacing.space4,
                            AppSpacing.space6,
                          ),
                          children: <Widget>[
                            ..._header(p, l10n),
                            const SizedBox(height: AppSpacing.space4),
                            _actions(context, state, p, l10n, colors),
                            const SizedBox(height: AppSpacing.space4),
                            ...p.isTeacher
                                ? _teacherBody(state, p, l10n, colors)
                                : _studentBody(p, l10n),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _header(Profile p, AppLocalizations l10n) {
    if (p.isTeacher) {
      return <Widget>[
        ProfileHeader(
          profile: p,
          subtitle: p.headline ?? '',
          badge: p.isVerified ? l10n.verifiedTeacher : null,
          goldBadge: true,
        ),
      ];
    }
    final s = p.studentDetails;
    final subtitle = <String>[
      if (s?.ageGroup != null) l10n.learnerLabel(s!.ageGroup!.label(l10n)),
      if (p.gender != null) p.gender!.label(l10n),
    ].join(' · ');
    return <Widget>[
      ProfileHeader(
        profile: p,
        subtitle: subtitle,
        badge: (s?.lookingForTeacher ?? false)
            ? l10n.lookingForTeacherLabel
            : null,
      ),
    ];
  }

  Widget _actions(
    BuildContext context,
    PublicProfileState state,
    Profile p,
    AppLocalizations l10n,
    AppColors colors,
  ) {
    final c = state.connection;
    final connected = c?.status == ConnectionStatus.accepted;
    final cubit = context.read<PublicProfileCubit>();
    void notAccepting() => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          p.isTeacher
              ? l10n.connectReceiverNotActiveTeacher
              : l10n.connectReceiverNotActiveStudent,
        ),
      ),
    );
    final (String label, String icon, VoidCallback? onTap) = switch (c) {
      // Only reachable from the feed: lists show active people only.
      null when !p.isActive => (
        l10n.notAcceptingRequestsLabel,
        AppIcon.userPlus,
        notAccepting,
      ),
      null => (
        l10n.connectAction,
        AppIcon.userPlus,
        () => ConnectSheet.show(context, target: p, requesterId: viewerId),
      ),
      Connection(status: ConnectionStatus.accepted) => (
        l10n.connectedLabel,
        AppIcon.check,
        null,
      ),
      Connection(requesterId: final from) when from == viewerId => (
        l10n.requestedLabel,
        AppIcon.check,
        null,
      ),
      _ => (l10n.acceptAction, AppIcon.check, cubit.accept),
    };
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: label,
                onPressed: onTap,
                leading: AppIcon(
                  icon,
                  size: 18,
                  color: onTap == null ? colors.inkMuted : colors.onBrand,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.gap10),
            Expanded(
              child: AppButton(
                label: l10n.messageAction,
                onPressed: connected
                    ? () => context.push(AppRoutes.chat(p.id))
                    : null,
                leading: AppIcon(
                  AppIcon.chat,
                  size: 18,
                  color: connected ? colors.onBrand : colors.inkMuted,
                ),
              ),
            ),
          ],
        ),
        if (!connected) ...<Widget>[
          const SizedBox(height: AppSpacing.space2),
          Text(
            l10n.connectFirstHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.helper.copyWith(color: colors.inkMuted),
          ),
        ],
      ],
    );
  }

  List<Widget> _teacherBody(
    PublicProfileState state,
    Profile p,
    AppLocalizations l10n,
    AppColors colors,
  ) {
    final t = p.teacherDetails;
    final fee = t?.feeAmount;
    final audience = t?.teaches ?? const <TeachesAudience>{};
    return <Widget>[
      _Card(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              _Stat(
                value: t?.experienceYears == null
                    ? '–'
                    : l10n.yearsShort(t!.experienceYears!),
                label: l10n.statExperience,
              ),
              VerticalDivider(width: 1, thickness: 1, color: colors.line),
              _Stat(
                value: '${state.connectionCount}',
                label: l10n.statConnections,
              ),
              VerticalDivider(width: 1, thickness: 1, color: colors.line),
              _Stat(value: '${state.postCount}', label: l10n.statPosts),
            ],
          ),
        ),
      ),
      if (p.bio != null) ...<Widget>[
        const SizedBox(height: AppSpacing.space4),
        SectionLabel(l10n.aboutLabel),
        const SizedBox(height: AppSpacing.space2),
        Text(p.bio!, style: AppTextStyles.bodyMd.copyWith(color: colors.ink)),
      ],
      const SizedBox(height: AppSpacing.space4),
      Wrap(
        spacing: AppSpacing.gap6,
        runSpacing: AppSpacing.gap6,
        children: <Widget>[
          for (final s in t?.subjects ?? const <Subject>[])
            _Chip(s.label(l10n), brand: true),
          if (p.languages.isNotEmpty)
            _Chip(p.languages.map((l) => l.label(l10n)).join(' · ')),
          if (audience.isNotEmpty)
            _Chip(
              l10n.teachesAudience(
                audience.map((a) => a.label(l10n).toLowerCase()).join(' & '),
              ),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.space4),
      _Card(
        child: Column(
          children: <Widget>[
            InfoRow(icon: AppIcon.mapPin, text: _location(p, l10n)),
            if (t != null && t.availableDays.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.gap10),
              InfoRow(icon: AppIcon.calendar, text: _availability(t, l10n)),
            ],
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
      ),
    ];
  }

  List<Widget> _studentBody(Profile p, AppLocalizations l10n) {
    final s = p.studentDetails;
    final preference = s?.preferredTeacherGender;
    return <Widget>[
      if (s?.note != null) ...<Widget>[
        SectionLabel(l10n.noteLabel),
        const SizedBox(height: AppSpacing.space2),
        Builder(
          builder: (context) => Text(
            l10n.quotedNote(s!.note!),
            style: AppTextStyles.bodyMd.copyWith(
              color: Theme.of(context).extension<AppColors>()!.ink,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
      ],
      if ((s?.goals ?? const <Subject>[]).isNotEmpty) ...<Widget>[
        SectionLabel(l10n.wantsToLearnLabel),
        const SizedBox(height: AppSpacing.space2),
        Wrap(
          spacing: AppSpacing.gap6,
          runSpacing: AppSpacing.gap6,
          children: <Widget>[
            for (final g in s!.goals) _Chip(g.label(l10n), brand: true),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
      ],
      _Card(
        child: Column(
          children: <Widget>[
            InfoRow(icon: AppIcon.mapPin, text: _location(p, l10n)),
            if (s?.level != null) ...<Widget>[
              const SizedBox(height: AppSpacing.gap10),
              InfoRow(
                icon: AppIcon.bookOpen,
                text: l10n.levelLine(s!.level!.label(l10n)),
              ),
            ],
            if (p.languages.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.gap10),
              InfoRow(
                icon: AppIcon.globe,
                text: l10n.speaksLine(
                  p.languages.map((l) => l.label(l10n)).join(', '),
                ),
              ),
            ],
            if (preference != null) ...<Widget>[
              const SizedBox(height: AppSpacing.gap10),
              InfoRow(
                icon: AppIcon.user,
                text: switch (preference) {
                  TeacherGenderPreference.female => l10n.prefersFemaleTeacher,
                  TeacherGenderPreference.male => l10n.prefersMaleTeacher,
                  TeacherGenderPreference.any => l10n.prefersAnyTeacher,
                },
              ),
            ],
          ],
        ),
      ),
    ];
  }

  static String _location(Profile p, AppLocalizations l10n) {
    final place = <String>[?p.city, ?p.country].join(', ');
    return p.timeZone == null
        ? place
        : l10n.cityAndTimeZone(place, p.timeZone!);
  }

  static String _availability(TeacherDetails t, AppLocalizations l10n) {
    final days = t.availableDays.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final names = days.map(_shortDay).join(', ');
    final from = t.availableFromMinutes;
    final to = t.availableToMinutes;
    if (from == null || to == null) {
      return names;
    }
    return l10n.availabilityLine(names, _time(from, false), _time(to, true));
  }

  static String _shortDay(Weekday d) =>
      DateFormat.E().format(DateTime(2024, 1, 1 + d.index));

  static String _time(int minutes, bool withPeriod) {
    final t = DateTime(2024, 1, 1, minutes ~/ 60, minutes % 60);
    return withPeriod
        ? DateFormat('h:mm a').format(t).toLowerCase()
        : DateFormat('h:mm').format(t);
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 22,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: AppIcon(icon, size: size, color: colors.ink),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.gap14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Container(
      padding: padding,
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

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Expanded(
      child: MergeSemantics(
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: AppTextStyles.pageTitle.copyWith(color: colors.ink),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w400,
                color: colors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 24 px detail chip: brand for subjects, grey for languages / audience.
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
