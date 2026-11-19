import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// App shell with the designed bottom bar: Home · Teachers · raised centre
/// "+" · Chats · Alerts. Tab screens are the [navigationShell] branches.
///
/// Android back on a non-Home tab returns to Home; on Home it leaves the app.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const int _homeIndex = 0;

  void _selectTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = navigationShell.currentIndex;

    return PopScope(
      canPop: current == _homeIndex,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _selectTab(_homeIndex);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: _BottomBar(
          children: <Widget>[
            _TabItem(
              label: l10n.tabHome,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              selected: current == 0,
              onTap: () => _selectTab(0),
            ),
            _TabItem(
              label: l10n.tabTeachers,
              icon: Icons.people_outline,
              selectedIcon: Icons.people,
              selected: current == 1,
              onTap: () => _selectTab(1),
            ),
            _CreatePostButton(
              label: l10n.createPostAction,
              onTap: () => context.push(AppRoutes.createPost),
            ),
            _TabItem(
              label: l10n.tabChats,
              icon: Icons.chat_bubble_outline,
              selectedIcon: Icons.chat_bubble,
              selected: current == 2,
              onTap: () => _selectTab(2),
            ),
            _TabItem(
              label: l10n.tabAlerts,
              icon: Icons.notifications_none,
              selectedIcon: Icons.notifications,
              selected: current == 3,
              onTap: () => _selectTab(3),
            ),
          ],
        ),
      ),
    );
  }
}

/// 80 px bar on `surface-000` with a 1 px `line` top border.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface000,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.space1,
              end: AppSpacing.space1,
              bottom: AppSpacing.space3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// A 68 px tab: icon in a 52×30 pill (tinted when selected) above its label.
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final foreground = selected ? colors.brand700 : colors.inkMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 40,
        child: SizedBox(
          width: 68,
          height: AppSpacing.space12 + AppSpacing.space2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  color: selected ? colors.brand100 : null,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: 22,
                  color: foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (selected
                            ? AppTextStyles.captionBold
                            : AppTextStyles.caption)
                        .copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The raised 56 px centre button (`brand-600`, 4 px `surface-000` ring,
/// `shadow-raised`), lifted 22 px above the bar.
class _CreatePostButton extends StatelessWidget {
  const _CreatePostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Transform.translate(
      offset: const Offset(0, -22),
      child: Tooltip(
        message: label,
        child: Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface000,
              boxShadow: AppShadows.raised(theme.brightness),
            ),
            padding: const EdgeInsets.all(AppSpacing.space1),
            child: Material(
              color: colors.brand600,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Icon(Icons.add, size: 28, color: colors.onBrand),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
