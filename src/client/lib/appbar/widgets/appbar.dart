import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stashed/auth/auth.dart';
import 'package:stashed/l10n/l10n.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final StatefulNavigationShell _navigationShell;

  const AppBarWidget(this._navigationShell, {super.key});

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _AppBarWidgetState extends State<AppBarWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  void _goBranch(int index) {
    widget._navigationShell.goBranch(
      index,
      initialLocation: index == widget._navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    _tabController.animateTo(widget._navigationShell.currentIndex);
    var colorScheme = Theme.of(context).colorScheme;
    var l10n = context.l10n;

    return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Text(
              "stashed",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: colorScheme.onPrimaryContainer),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13, bottom: 13),
                child: TabBar(
                  indicator: (Theme.of(context).tabBarTheme.indicator! as BoxDecoration).copyWith(
                    color: colorScheme.primary,
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: colorScheme.onPrimary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  controller: _tabController,
                  tabs: [
                    _AppBarTab(
                      icon: Icons.dns_outlined,
                      label: l10n.appbarTabLabelConnect,
                    ),
                    _AppBarTab(
                      icon: Icons.search_outlined,
                      label: l10n.appbarTabLabelSearch,
                    ),
                    _AppBarTab(
                      icon: Icons.add_a_photo_outlined,
                      label: l10n.appbarTabLabelImport,
                    ),
                    _AppBarTab(
                      icon: Icons.format_list_numbered_outlined,
                      label: l10n.appbarTabLabelTasks,
                    ),
                    _AppBarTab(
                      icon: Icons.settings_outlined,
                      label: l10n.appbarTabLabelSettings,
                    ),
                  ],
                  onTap: (index) => _goBranch(index),
                ),
              ),
            ),
            const AuthWidget(),
          ],
        ));
  }
}

class _AppBarTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AppBarTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }
}
