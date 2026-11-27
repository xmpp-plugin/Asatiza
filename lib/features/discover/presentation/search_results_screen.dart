import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_segmented_control.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/section_label.dart';
import '../../../data/models/enums/fee_unit.dart';
import '../../../data/models/enums/gender.dart';
import '../../../data/models/enums/learner_age_group.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/discover_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../connections/presentation/connect_sheet.dart';
import '../../safety/presentation/report_sheet.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import 'widgets/person_row.dart';

/// 08b Home search results: All / Teachers (Students for teachers) / Posts.
class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewer = context.select<SessionCubit, Profile?>((c) => c.state.user);
    if (viewer == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return BlocProvider<SearchCubit>(
      create: (context) => SearchCubit(
        context.read<DiscoverRepository>(),
        context.read<FeedRepository>(),
        context.read<ProfileRepository>(),
        viewerId: viewer.id,
        showTeachers: !viewer.isTeacher,
        subjectLabel: (s) => s.label(l10n),
      ),
      child: _SearchView(viewer: viewer),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({required this.viewer});

  final Profile viewer;

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _query = TextEditingController();

  /// Rows / cards shown per section on the All tab.
  static const int _preview = 3;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  String _personSubtitle(Profile p, AppLocalizations l10n) {
    if (p.isTeacher) {
      return p.headline ?? l10n.roleTeacher;
    }
    final s = p.studentDetails;
    return <String>[
      if (s?.ageGroup != null) s!.ageGroup!.label(l10n),
      if (p.gender != null) p.gender!.label(l10n),
      ...?s?.goals.map((g) => g.label(l10n)),
    ].join(' · ');
  }

  String? _fee(Profile p, AppLocalizations l10n) {
    final t = p.teacherDetails;
    final fee = t?.feeAmount;
    if (fee == null) {
      return null;
    }
    return t!.feeUnit == FeeUnit.perClass
        ? l10n.feePerClassShort(fee)
        : l10n.feePerMonthShort(fee);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final cubit = context.read<SearchCubit>();
    final teachers = !widget.viewer.isTeacher;
    return Scaffold(
      backgroundColor: colors.surface100,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.gap6,
                  end: AppSpacing.space4,
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: l10n.backAction,
                      onPressed: () => context.pop(),
                      icon: AppIcon(
                        AppIcon.chevronLeft,
                        size: 22,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space1),
                    Expanded(
                      child: SearchField(
                        controller: _query,
                        pill: true,
                        autofocus: true,
                        placeholder: l10n.searchPlaceholder,
                        semanticLabel: l10n.searchLabel,
                        onChanged: cubit.queryChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) => ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.space4,
                    AppSpacing.space1,
                    AppSpacing.space4,
                    AppSpacing.space4,
                  ),
                  children: <Widget>[
                    AppSegmentedControl<SearchTab>(
                      values: SearchTab.values,
                      selected: state.tab,
                      label: (t) => switch (t) {
                        SearchTab.all => l10n.searchTabAll,
                        SearchTab.people =>
                          teachers ? l10n.tabTeachers : l10n.studentsTitle,
                        SearchTab.posts => l10n.searchTabPosts,
                      },
                      onChanged: cubit.tabChanged,
                    ),
                    const SizedBox(height: AppSpacing.gap14),
                    ..._results(context, state, l10n, teachers),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(
    BuildContext context,
    SearchState state,
    AppLocalizations l10n,
    bool teachers,
  ) {
    final cubit = context.read<SearchCubit>();
    if (!state.hasQuery) {
      return const <Widget>[];
    }
    if (state.isEmpty) {
      return <Widget>[
        const SizedBox(height: AppSpacing.space6),
        EmptyStateView(
          icon: AppIcon.search,
          title: l10n.noResultsTitle(state.query.trim()),
          message: l10n.noResultsMessage,
          actionLabel: l10n.clearSearchAction,
          onAction: () {
            _query.clear();
            cubit.queryChanged('');
          },
        ),
      ];
    }
    final all = state.tab == SearchTab.all;
    final showPeople = state.tab != SearchTab.posts && state.people.isNotEmpty;
    final showPosts = state.tab != SearchTab.people && state.posts.isNotEmpty;
    final people = all ? state.people.take(_preview) : state.people;
    final posts = all ? state.posts.take(_preview) : state.posts;
    return <Widget>[
      if (showPeople) ...<Widget>[
        _SectionHeader(
          title: teachers ? l10n.tabTeachers : l10n.studentsTitle,
          seeAll: all && state.people.length > _preview
              ? l10n.seeAllCount(state.people.length)
              : null,
          onSeeAll: () => cubit.tabChanged(SearchTab.people),
        ),
        for (final p in people)
          PersonRow(
            profile: p,
            // Student photos never show in discover lists (decision 5).
            showPhoto: p.isTeacher,
            subtitle: _personSubtitle(p, l10n),
            detail: _fee(p, l10n),
            onTap: () => context.push(AppRoutes.profile(p.id)),
            trailing: AppButton(
              label: l10n.connectAction,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () => ConnectSheet.show(
                context,
                target: p,
                requesterId: widget.viewer.id,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.gap14),
      ],
      if (showPosts) ...<Widget>[
        _SectionHeader(
          title: l10n.searchTabPosts,
          seeAll: all && state.posts.length > _preview
              ? l10n.seeAllCount(state.posts.length)
              : null,
          onSeeAll: () => cubit.tabChanged(SearchTab.posts),
        ),
        const SizedBox(height: AppSpacing.gap10),
        for (final post in posts) ...<Widget>[
          PostCard(
            post: post,
            author: state.authors[post.authorId]!,
            onLike: () => cubit.toggleLike(post.id),
            onComment: () => context.push(AppRoutes.post(post.id)),
            onOpen: () => context.push(AppRoutes.post(post.id)),
            onReport: () => ReportSheet.show(
              context,
              post: post,
              author: state.authors[post.authorId]!,
              reporterId: widget.viewer.id,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
        ],
      ],
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
    this.seeAll,
  });

  final String title;
  final String? seeAll;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: <Widget>[
        Expanded(child: SectionLabel(title)),
        if (seeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: Text(
              seeAll!,
              style: AppTextStyles.label.copyWith(color: colors.brand700),
            ),
          ),
      ],
    );
  }
}
