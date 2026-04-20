import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/services/chat_provider.dart';
import '../../../../core/services/notificacoes_service.dart';
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
        final chatProvider = context.watch<ChatProvider>();
        final userRole = userContext.userRole;
        final currentUser = userContext.currentUser;
        final unreadChatCount = currentUser == null ? 0 : chatProvider.unreadCountForUser(currentUser.email);
        final notifCount = NotificacoesService.porRole(userRole).length;

        final availableItems = userRole == null
            ? kNavigationItems
            : kNavigationItems.where((item) => item.isAvailableFor(userRole)).toList();
        final currentItem = availableItems.where((item) => item.route == currentRoute).firstOrNull;
        final mobilePrimaryItems = _mobilePrimaryItems(availableItems);

        final selectedIndex = availableItems.indexWhere((item) => item.route == currentRoute);
        final selectedMobileIndex = mobilePrimaryItems.indexWhere(
          (item) => item.matchesRoute(currentRoute),
        );

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
                  titleSpacing: 0,
                  title: _MobileTopBarTitle(
                    title: currentItem?.label ?? 'SIGAD',
                    subtitle: userContext.currentUser?.role.displayName,
                  ),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  actions: [
                    IconButton(
                      onPressed: () => _showNotifications(context),
                      tooltip: 'Notificações',
                      icon: notifCount > 0
                          ? Badge(
                              label: Text(notifCount > 99 ? '99+' : '$notifCount'),
                              child: const Icon(Icons.notifications_outlined),
                            )
                          : const Icon(Icons.notifications_outlined),
                    ),
                    IconButton(
                      onPressed: () => _showProfileMenu(context, userContext),
                      tooltip: 'Perfil',
                      icon: const Icon(Icons.account_circle_outlined),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          bottomNavigationBar: isWide || mobilePrimaryItems.length < 2
              ? null
              : NavigationBar(
                  selectedIndex: selectedMobileIndex < 0
                      ? mobilePrimaryItems.length - 1
                      : selectedMobileIndex,
                  onDestinationSelected: (index) {
                    final item = mobilePrimaryItems[index];
                    if (item.isMore) {
                      _showQuickAccess(context, availableItems);
                      return;
                    }
                    _navigate(context, item.route);
                  },
                  destinations: mobilePrimaryItems
                      .map(
                        (item) => NavigationDestination(
                          icon: item.route == AppRoutes.batePapo && unreadChatCount > 0
                              ? Badge(
                                  label: Text(unreadChatCount > 99 ? '99+' : '$unreadChatCount'),
                                  child: Icon(item.icon),
                                )
                              : Icon(item.icon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
          body: isWide
              ? Row(
                  children: [
                    _SideNav(
                      selectedIndex: selectedIndex,
                      availableItems: availableItems,
                      userContext: userContext,
                      onSelected: (index) => _navigate(context, availableItems[index].route),
                      onQuickAccess: () => _showQuickAccess(context, availableItems),
                      onLogout: () => _confirmLogout(context, userContext),
                    ),
                    Expanded(
                      child: SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: currentRoute == AppRoutes.dashboard ? 1720 : 1480,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: currentRoute == AppRoutes.dashboard ? 8 : 20,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: child,
                  ),
                ),
        );
      },
    );
  }

  List<_MobileNavItem> _mobilePrimaryItems(List<NavigationItem> availableItems) {
    if (availableItems.length <= 4) {
      return availableItems.map(_MobileNavItem.route).toList(growable: false);
    }

    final base = <NavigationItem>[];
    final dashboard = availableItems.where((item) => item.route == AppRoutes.dashboard).firstOrNull;
    if (dashboard != null) {
      base.add(dashboard);
    }

    for (final item in availableItems) {
      if (base.length == 3) break;
      if (!base.contains(item)) {
        base.add(item);
      }
    }

    return [
      ...base.map(_MobileNavItem.route),
      const _MobileNavItem.more(),
    ];
  }

  void _navigate(BuildContext context, String route) {
    if (currentRoute == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _showProfileMenu(BuildContext context, UserContextProvider userContext) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ProfileMenu(userContext: userContext),
    );
  }

  void _showNotifications(BuildContext context) {
    final userRole = context.read<UserContextProvider>().userRole;
    final notificacoes = NotificacoesService.porRole(userRole);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notificações', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (notificacoes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Nenhuma notificação no momento.')),
                )
              else
                ...notificacoes.map(
                  (n) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(n.icone),
                    title: Text(n.titulo),
                    subtitle: Text(n.subtitulo),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickAccess(BuildContext context, List<NavigationItem> availableItems) {
    var query = '';
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredItems = availableItems.where((item) {
            final haystack = '${item.label} ${item.subtitle ?? ''}'.toLowerCase();
            return haystack.contains(query.toLowerCase());
          }).toList();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acesso rápido',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    onChanged: (value) => setModalState(() => query = value),
                    decoration: const InputDecoration(
                      hintText: 'Buscar módulo',
                      prefixIcon: Icon(Icons.search_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'Nenhum módulo encontrado.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                tileColor: SigadColors.surfaceAlt,
                                leading: Icon(item.icon, color: SigadColors.brand),
                                title: Text(item.label),
                                subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                                onTap: () {
                                  Navigator.pop(context);
                                  _navigate(context, item.route);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MobileNavItem {
  const _MobileNavItem.route(this.item) : isMore = false;

  const _MobileNavItem.more()
      : item = null,
        isMore = true;

  final NavigationItem? item;
  final bool isMore;

  String get route => item?.route ?? '__more__';
  String get label => item?.label ?? 'Mais';
  IconData get icon => item?.icon ?? Icons.more_horiz;

  bool matchesRoute(String route) => !isMore && item?.route == route;
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedIndex,
    required this.availableItems,
    required this.userContext,
    required this.onSelected,
    required this.onQuickAccess,
    required this.onLogout,
  });

  final int selectedIndex;
  final List<NavigationItem> availableItems;
  final UserContextProvider userContext;
  final ValueChanged<int> onSelected;
  final VoidCallback onQuickAccess;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonalIcon(
              onPressed: onQuickAccess,
              icon: const Icon(Icons.search_outlined),
              label: const Text('Acesso rápido'),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CurrentSectionCard(
              currentRoute: availableItems[selectedIndex < 0 ? 0 : selectedIndex],
            ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SigadColors.surfaceAlt, SigadColors.brand.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SigadColors.divider),
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
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTopBarTitle extends StatelessWidget {
  const _MobileTopBarTitle({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _CurrentSectionCard extends StatelessWidget {
  const _CurrentSectionCard({required this.currentRoute});

  final NavigationItem currentRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SigadColors.brand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SigadColors.brand.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(currentRoute.icon, color: SigadColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentRoute.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  currentRoute.subtitle ?? 'Área ativa no momento',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
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
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Agenda',
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
        ),
      ),
    );
  }
}

void _confirmLogout(BuildContext context, UserContextProvider userContext) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar saída'),
      content: const Text('Tem certeza de que deseja sair da aplicação?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await userContext.logout();
            if (!context.mounted) return;
            await Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          },
          child: const Text('Sair'),
        ),
      ],
    ),
  );
}
