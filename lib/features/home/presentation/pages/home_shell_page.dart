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
            child: child,
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: kNavigationItems.length,
                separatorBuilder: (context, i) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final item = kNavigationItems[index];
                  final selected = index == selectedIndex;

                  return Material(
                    color: selected
                        ? SigadColors.brand.withValues(alpha: 0.10)
                        : SigadColors.surfaceAlt,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: selected ? SigadColors.brand : SigadColors.muted,
                              size: 24,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: selected ? SigadColors.brand : SigadColors.ink,
                                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                        ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.subtitle!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: SigadColors.muted,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
