import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../shared/widgets/brand_title.dart';

class HomeShellPage extends StatelessWidget {
  const HomeShellPage({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        final selectedIndex = kNavigationItems.indexWhere(
          (item) => item.route == currentRoute,
        );

        return Scaffold(
          drawer: isWide
              ? null
              : _AppDrawer(
                  selectedIndex: selectedIndex,
                  onSelected: (index) => _navigate(
                    context,
                    kNavigationItems[index].route,
                  ),
                ),
          appBar: isWide
              ? null
              : AppBar(
                  title: const BrandTitle(compact: true),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Notificacoes',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.account_circle_outlined),
                      tooltip: 'Perfil',
                    ),
                  ],
                ),
          body: Row(
            children: [
              if (isWide)
                _SideNav(
                  selectedIndex: selectedIndex,
                  onSelected: (index) => _navigate(
                    context,
                    kNavigationItems[index].route,
                  ),
                ),
              Expanded(
                child: SafeArea(
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigate(BuildContext context, String route) {
    if (currentRoute == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: SigadColors.surface,
        border: Border(
          right: BorderSide(color: SigadColors.divider),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const BrandTitle(),
          const SizedBox(height: 24),
          Expanded(
            child: NavigationRailTheme(
              data: NavigationRailThemeData(
                backgroundColor: SigadColors.surface,
                indicatorColor: SigadColors.accentSoft,
                selectedIconTheme: const IconThemeData(
                  color: SigadColors.brand,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: SigadColors.muted,
                ),
                selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
                  color: SigadColors.brand,
                ),
                unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
                  color: SigadColors.muted,
                ),
              ),
              child: NavigationRail(
                selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
                onDestinationSelected: onSelected,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final item in kNavigationItems)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SigadColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: SigadColors.brand,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coord. Academica',
                        style: textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Unidade Central',
                        style: textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const BrandTitle(compact: true),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: kNavigationItems.length,
                itemBuilder: (context, index) {
                  final item = kNavigationItems[index];
                  final selected = index == selectedIndex;

                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: selected ? SigadColors.brand : SigadColors.muted,
                    ),
                    title: Text(item.label),
                    selected: selected,
                    selectedColor: SigadColors.brand,
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(index);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
