import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/services/user_context_provider.dart';
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
        final userContext = context.watch<UserContextProvider>();
        final userRole = userContext.userRole;

        final availableItems = userRole == null
            ? kNavigationItems
            : kNavigationItems.where((item) => item.isAvailableFor(userRole)).toList();

        final selectedIndex = availableItems.indexWhere((item) => item.route == currentRoute);

        return Scaffold(
          drawer: isWide
              ? null
              : _AppDrawer(
                  selectedIndex: selectedIndex,
                  availableItems: availableItems,
                  onSelected: (index) => _navigate(context, availableItems[index].route),
                  onLogout: () => _confirmLogout(context, userContext),
                ),
          appBar: isWide
              ? null
              : AppBar(
                  title: const BrandTitle(compact: true),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  actions: [
                    IconButton(
                      onPressed: () {},
                      tooltip: 'Notificacoes',
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                    IconButton(
                      onPressed: () => _showProfileMenu(context, userContext),
                      tooltip: 'Perfil',
                      icon: const Icon(Icons.account_circle_outlined),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          body: isWide
              ? Row(
                  children: [
                    _SideNav(
                      selectedIndex: selectedIndex,
                      availableItems: availableItems,
                      userContext: userContext,
                      onSelected: (index) => _navigate(context, availableItems[index].route),
                      onLogout: () => _confirmLogout(context, userContext),
                    ),
                    Expanded(
                      child: SafeArea(child: child),
                    ),
                  ],
                )
              : SafeArea(child: child),
        );
      },
    );
  }

  void _navigate(BuildContext context, String route) {
    if (currentRoute == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _showProfileMenu(BuildContext context, UserContextProvider userContext) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _ProfileMenu(userContext: userContext),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedIndex,
    required this.availableItems,
    required this.userContext,
    required this.onSelected,
    required this.onLogout,
  });

  final int selectedIndex;
  final List<NavigationItem> availableItems;
  final UserContextProvider userContext;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      decoration: const BoxDecoration(
        color: SigadColors.surface,
        border: Border(
          right: BorderSide(color: SigadColors.divider),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: BrandTitle(),
          ),
          const SizedBox(height: 14),
          if (userContext.isAuthenticated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _UserCard(userContext: userContext),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _NavigationList(
              selectedIndex: selectedIndex,
              availableItems: availableItems,
              onSelected: onSelected,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: ListTile(
              onTap: onLogout,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.logout, color: SigadColors.risk),
              title: const Text('Sair'),
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
    required this.availableItems,
    required this.onSelected,
    required this.onLogout,
  });

  final int selectedIndex;
  final List<NavigationItem> availableItems;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: BrandTitle(compact: true),
            ),
            if (userContext.isAuthenticated)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _UserCard(userContext: userContext),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _NavigationList(
                selectedIndex: selectedIndex,
                availableItems: availableItems,
                onSelected: (index) {
                  Navigator.pop(context);
                  onSelected(index);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  onLogout();
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout, color: SigadColors.risk),
                title: const Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationList extends StatelessWidget {
  const _NavigationList({
    required this.selectedIndex,
    required this.availableItems,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<NavigationItem> availableItems;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: availableItems.length,
      separatorBuilder: (_, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final item = availableItems[index];
        final selected = index == selectedIndex;
        return Material(
          color: selected ? SigadColors.brand.withValues(alpha: 0.10) : SigadColors.surfaceAlt,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelected(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: selected ? SigadColors.brand : SigadColors.muted,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
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
                        if (item.subtitle != null)
                          Text(
                            item.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.userContext});

  final UserContextProvider userContext;

  @override
  Widget build(BuildContext context) {
    final user = userContext.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: SigadColors.brand.withValues(alpha: 0.18),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(color: SigadColors.brand, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.role.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.userContext});

  final UserContextProvider userContext;

  @override
  Widget build(BuildContext context) {
    final user = userContext.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: SigadColors.brand.withValues(alpha: 0.14),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SigadColors.brand,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Text(user.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            user.role.displayName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: SigadColors.brand),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context);
                _confirmLogout(context, userContext);
              },
              child: const Text('Sair'),
            ),
          ),
        ],
      ),
    );
  }
}

void _confirmLogout(BuildContext context, UserContextProvider userContext) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar saida'),
      content: const Text('Tem certeza que deseja sair da aplicacao?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            userContext.logout();
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          },
          child: const Text('Sair'),
        ),
      ],
    ),
  );
}
