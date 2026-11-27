import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/count_badge.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/teacher_card_skeleton.dart';
import '../../../data/models/connection.dart';
import '../../../data/models/enums/connection_status.dart';
import '../../../data/models/enums/experience_filter.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/learner_level.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/enums/teaching_language.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/connection_repository.dart';
import '../../../data/repositories/discover_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../connections/presentation/connect_sheet.dart';
import '../bloc/discover_cubit.dart';
import '../bloc/discover_state.dart';
import '../logic/student_filter.dart';
import '../logic/teacher_filter.dart';
import 'student_filter_sheet.dart';
import 'teacher_filter_sheet.dart';
import 'widgets/filter_chips_bar.dart';
import 'widgets/student_card.dart';
import 'widgets/teacher_card.dart';

/// 11 Teachers (student viewer) / 12 Students (teacher viewer): search,
/// filter sheet, filter chips and the list.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (user == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return BlocProvider<DiscoverCubit>(
      key: ValueKey<String>(user.id),
      create: (context) => DiscoverCubit(
        context.read<DiscoverRepository>(),
        context.read<ConnectionRepository>(),
        viewerId: user.id,
        showTeachers: !user.isTeacher,
        subjectLabel: (s) => s.label(l10n),
      ),
      child: _DiscoverView(viewer: user),
    );
  }
}

class _DiscoverView extends StatefulWidget {
  const _DiscoverView({required this.viewer});

  final Profile viewer;

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters(DiscoverState state) async {
    final cubit = context.read<DiscoverCubit>();
    if (state.showTeachers) {
      final filter = await TeacherFilterSheet.show(
        context,
        initial: state.teacherFilter,
        count: cubit.countTeachers,
      );
      if (filter != null) {
        cubit.teacherFilterChanged(filter);
      }
    } else {
      final filter = await StudentFilterSheet.show(
        context,
        initial: state.studentFilter,
        countries: <String>{for (final p in state.all) ?p.country}.toList()
          ..sort(),
        count: cubit.countStudents,
      );
      if (filter != null) {
        cubit.studentFilterChanged(filter);
      }
    }
  }

  void _clearFilters(DiscoverState state) {
    final cubit = context.read<DiscoverCubit>();
    _search.clear();
    if (state.showTeachers) {
      cubit.teacherFilterChanged(const TeacherFilter());
    } else {
      cubit.studentFilterChanged(const StudentFilter());
    }
  }

  List<FilterChipItem> _teacherChips(
    DiscoverState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<DiscoverCubit>();
    final f = state.teacherFilter;
    void set(TeacherFilter Function(TeacherFilter) edit) =>
        cubit.teacherFilterChanged(edit(f));
    return <FilterChipItem>[
      for (final s in f.subjects)
        (
          label: s.label(l10n),
          active: true,
          onTap: () =>
              set((f) => f.copyWith(subjects: {...f.subjects}..remove(s))),
        ),
      if (f.gender != null)
        (
          label: l10n.teacherGenderChip(f.gender!.label(l10n)),
          active: true,
          onTap: () => set((f) => f.copyWith(gender: () => null)),
        ),
      for (final language in f.languages)
        (
          label: language.label(l10n),
          active: true,
          onTap: () => set(
            (f) => f.copyWith(languages: {...f.languages}..remove(language)),
          ),
        ),
      if (f.feeActive)
        (
          label: l10n.feeRange(f.feeMin, f.feeMax),
          active: true,
          onTap: () => set(
            (f) => f.copyWith(
              feeMin: TeacherFilter.feeFloor,
              feeMax: TeacherFilter.feeCeiling,
            ),
          ),
        ),
      if (f.experience != ExperienceFilter.any)
        (
          label: f.experience.label(l10n),
          active: true,
          onTap: () => set((f) => f.copyWith(experience: ExperienceFilter.any)),
        ),
      if (f.teachesChildren)
        (
          label: l10n.teachesChildrenLabel,
          active: true,
          onTap: () => set((f) => f.copyWith(teachesChildren: false)),
        ),
      if (!f.languages.contains(TeachingLanguage.urdu))
        (
          label: TeachingLanguage.urdu.label(l10n),
          active: false,
          onTap: () => set(
            (f) =>
                f.copyWith(languages: {...f.languages, TeachingLanguage.urdu}),
          ),
        ),
      if (!f.teachesChildren)
        (
          label: l10n.teachesChildrenLabel,
          active: false,
          onTap: () => set((f) => f.copyWith(teachesChildren: true)),
        ),
    ];
  }

  List<FilterChipItem> _studentChips(
    DiscoverState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<DiscoverCubit>();
    final f = state.studentFilter;
    void set(StudentFilter Function(StudentFilter) edit) =>
        cubit.studentFilterChanged(edit(f));
    return <FilterChipItem>[
      for (final s in f.subjects)
        (
          label: l10n.wantsSubjectChip(s.label(l10n)),
          active: true,
          onTap: () =>
              set((f) => f.copyWith(subjects: {...f.subjects}..remove(s))),
        ),
      if (f.gender != null)
        (
          label: f.gender!.label(l10n),
          active: true,
          onTap: () => set((f) => f.copyWith(gender: () => null)),
        ),
      for (final language in f.languages)
        (
          label: language.label(l10n),
          active: true,
          onTap: () => set(
            (f) => f.copyWith(languages: {...f.languages}..remove(language)),
          ),
        ),
      if (f.country != null)
        (
          label: f.country!,
          active: true,
          onTap: () => set((f) => f.copyWith(country: () => null)),
        ),
      for (final level in f.levels)
        (
          label: level.label(l10n),
          active: true,
          onTap: () =>
              set((f) => f.copyWith(levels: {...f.levels}..remove(level))),
        ),
      for (final group in LearnerAgeGroup.values)
        (
          label: group.label(l10n),
          active: f.ageGroups.contains(group),
          onTap: () => set(
            (f) => f.copyWith(
              ageGroups: f.ageGroups.contains(group)
                  ? ({...f.ageGroups}..remove(group))
                  : {...f.ageGroups, group},
            ),
          ),
        ),
    ]..sort((a, b) => (a.active == b.active) ? 0 : (a.active ? -1 : 1));
  }

  Future<void> _connect(Profile target) =>
      ConnectSheet.show(context, target: target, requesterId: widget.viewer.id);

  Widget _connectButton(
    DiscoverState state,
    Profile p,
    AppLocalizations l10n, {
    required bool expand,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final c = state.connectionWith(p.id);
    final (String label, String icon, VoidCallback? onTap) = switch (c) {
      null => (l10n.connectAction, AppIcon.userPlus, () => _connect(p)),
      Connection(status: ConnectionStatus.accepted) => (
        l10n.messageAction,
        AppIcon.chat,
        () => context.push(AppRoutes.chat(p.id)),
      ),
      Connection(requesterId: final from) when from == widget.viewer.id => (
        l10n.requestedLabel,
        AppIcon.check,
        null,
      ),
      final Connection pending => (
        l10n.acceptAction,
        AppIcon.check,
        () => context.read<DiscoverCubit>().accept(pending),
      ),
    };
    return AppButton(
      label: label,
      onPressed: onTap,
      size: AppButtonSize.small,
      expand: expand,
      leading: AppIcon(
        icon,
        size: 18,
        color: onTap == null ? colors.inkMuted : colors.onBrand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        final teachers = state.showTeachers;
        final active = state.activeFilterCount;
        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.space4,
                  AppSpacing.space3,
                  AppSpacing.space4,
                  AppSpacing.space3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text(
                        teachers ? l10n.teachersTitle : l10n.studentsTitle,
                        style: AppTextStyles.screenTitle.copyWith(
                          color: colors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SearchField(
                            controller: _search,
                            placeholder: l10n.discoverSearchPlaceholder,
                            semanticLabel: teachers
                                ? l10n.searchTeachersLabel
                                : l10n.searchStudentsLabel,
                            onChanged: context
                                .read<DiscoverCubit>()
                                .queryChanged,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Semantics(
                          button: true,
                          label: l10n.filtersButtonLabel(active),
                          excludeSemantics: true,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Material(
                                color: colors.brand600,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _openFilters(state),
                                  child: SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: Center(
                                      child: AppIcon(
                                        AppIcon.sliders,
                                        size: 22,
                                        color: colors.onBrand,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (active > 0)
                                PositionedDirectional(
                                  top: -6,
                                  end: -6,
                                  child: CountBadge(
                                    count: active,
                                    gold: true,
                                    ringColor: colors.surface100,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FilterChipsBar(
                items: teachers
                    ? _teacherChips(state, l10n)
                    : _studentChips(state, l10n),
              ),
              const SizedBox(height: AppSpacing.space2),
              Expanded(child: _list(state, l10n, colors)),
            ],
          ),
        );
      },
    );
  }

  Widget _list(DiscoverState state, AppLocalizations l10n, AppColors colors) {
    const padding = EdgeInsetsDirectional.fromSTEB(
      AppSpacing.space4,
      AppSpacing.space1,
      AppSpacing.space4,
      AppSpacing.space4,
    );
    if (state.status == DiscoverStatus.loading) {
      return ListView.separated(
        padding: padding,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space3),
        itemBuilder: (_, _) => const TeacherCardSkeleton(),
      );
    }
    if (state.status == DiscoverStatus.error) {
      return _scrollable(
        EmptyStateView(
          icon: AppIcon.people,
          title: l10n.discoverLoadFailedTitle,
          message: l10n.discoverLoadFailedMessage,
          actionLabel: l10n.retryAction,
          onAction: context.read<DiscoverCubit>().refresh,
        ),
      );
    }
    final results = state.results;
    if (results.isEmpty) {
      final query = state.showTeachers
          ? state.teacherFilter.query
          : state.studentFilter.query;
      return _scrollable(
        EmptyStateView(
          icon: AppIcon.search,
          title: query.trim().isEmpty
              ? l10n.noFilterMatchesTitle
              : l10n.noResultsTitle(query.trim()),
          message: l10n.noResultsMessage,
          actionLabel: l10n.clearFiltersAction,
          onAction: () => _clearFilters(state),
        ),
      );
    }
    final countStyle = AppTextStyles.helper.copyWith(color: colors.inkMuted);
    return RefreshIndicator(
      onRefresh: context.read<DiscoverCubit>().refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: results.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space3),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Text(
              state.showTeachers
                  ? l10n.teacherCount(results.length)
                  : l10n.studentCount(results.length),
              style: countStyle.copyWith(color: colors.ink),
            );
          }
          final p = results[i - 1];
          void open() => context.push(AppRoutes.profile(p.id));
          return state.showTeachers
              ? TeacherCard(
                  profile: p,
                  onOpen: open,
                  connectButton: _connectButton(state, p, l10n, expand: true),
                )
              : StudentCard(
                  profile: p,
                  onOpen: open,
                  connectButton: _connectButton(state, p, l10n, expand: false),
                );
        },
      ),
    );
  }

  /// [child] centred like before, inside a scroll view so pull-to-refresh
  /// also works on the empty and error states.
  Widget _scrollable(Widget child) => RefreshIndicator(
    onRefresh: context.read<DiscoverCubit>().refresh,
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: Align(alignment: const Alignment(0, -0.4), child: child),
          ),
        ),
      ),
    ),
  );
}
