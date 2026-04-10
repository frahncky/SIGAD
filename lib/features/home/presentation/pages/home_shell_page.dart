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
                  elevation: 2,
                  shadowColor: Colors.black12,
                  actions: [
                    Tooltip(
                      message: 'Notificações',
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(24),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.notifications_outlined, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Perfil',
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(24),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.account_circle_outlined, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          body: SafeArea(
            child: Row(
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
                  child: child,
                ),
              ],
            ),
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
                        'Coord. Acadêmica',
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
      elevation: 8,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: const BrandTitle(compact: true),
            ),
            const Divider(height: 2, color: SigadColors.divider),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: kNavigationItems.length,
                itemBuilder: (context, index) {
                  final item = kNavigationItems[index];
                  final selected = index == selectedIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: selected ? SigadColors.brand : SigadColors.muted,
                        size: 24,
                      ),
                      title: Text(
                        item.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? SigadColors.brand : SigadColors.ink,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      selected: selected,
                      selectedColor: SigadColors.brand,
                      selectedTileColor: SigadColors.brand.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(index);
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 2, color: SigadColors.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.logout, color: SigadColors.risk),
                title: const Text('Sair (Logout)'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
