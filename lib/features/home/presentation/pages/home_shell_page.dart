import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/navigation/navigation_items.dart';
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
        final colors = Theme.of(context).colorScheme;
        final userContext = context.watch<UserContextProvider>();
        final userRole = userContext.userRole;
        final isDashboard = currentRoute == AppRoutes.dashboard;
        final availableItems = userRole == null
            ? kNavigationItems
            : kNavigationItems
                  .where((item) => item.isAvailableFor(userRole))
                  .toList();
        final selectedIndex = availableItems.indexWhere(
          (item) => item.route == currentRoute,
        );

        return Scaffold(
          drawer: isWide
              ? null
              : _AppDrawer(
                  selectedIndex: selectedIndex,
                  availableItems: availableItems,
                  onSelected: (index) =>
                      _navigate(context, availableItems[index].route),
                  onLogout: () => _confirmLogout(context, userContext),
                ),
          appBar: isWide || isDashboard
              ? null
              : AppBar(
                  toolbarHeight: 64,
                  backgroundColor: colors.surface,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  // Diz em que tela a pessoa está; antes a barra ficava vazia.
                  title: Text(
                    rotuloDaRota(currentRoute, context.l10n) ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  actions: [
                    FutureBuilder<List<NotificacaoModel>>(
                      future: NotificacoesService.carregar(
                        userRole,
                        userName: userContext.currentUser?.name,
                      ),
                      builder: (context, snapshot) {
                        final notifCount = snapshot.data?.length ?? 0;
                        return IconButton(
                          onPressed: () => mostrarNotificacoes(context),
                          tooltip: context.l10n.notificacoes,
                          icon: notifCount > 0
                              ? Badge(
                                  label: Text(
                                    notifCount > 99 ? '99+' : '$notifCount',
                                  ),
                                  child: const SigadIcon(
                                    SigadIcons.notificacao,
                                  ),
                                )
                              : const SigadIcon(SigadIcons.notificacao),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () => mostrarMenuPerfil(context),
                      tooltip: context.l10n.perfil,
                      icon: _UserAvatar(userContext: userContext, radius: 18),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
          bottomNavigationBar: isWide
              ? null
              : _SigadBottomBar(
                  currentRoute: currentRoute,
                  onNavigate: (route) => _navigate(context, route),
                ),
          body: isWide
              ? Row(
                  children: [
                    _SideNav(
                      selectedIndex: selectedIndex,
                      availableItems: availableItems,
                      userContext: userContext,
                      onSelected: (index) =>
                          _navigate(context, availableItems[index].route),
                      onQuickAccess: () =>
                          _showQuickAccess(context, availableItems),
                      onLogout: () => _confirmLogout(context, userContext),
                    ),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).colorScheme.surfaceContainerLow,
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: currentRoute == AppRoutes.dashboard
                                    ? 1680
                                    : 1440,
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  currentRoute == AppRoutes.dashboard ? 16 : 28,
                                  16,
                                  currentRoute == AppRoutes.dashboard ? 16 : 28,
                                  28,
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SafeArea(top: !isDashboard, bottom: false, child: child),
        );
      },
    );
  }

  void _navigate(BuildContext context, String route) {
    if (currentRoute == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _showQuickAccess(
    BuildContext context,
    List<NavigationItem> availableItems,
  ) {
    var query = '';
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredItems = availableItems.where((item) {
            final haystack =
                '${item.rotuloEm(context.l10n)} ${item.subtituloEm(context.l10n) ?? ''}'
                    .toLowerCase();
            return haystack.contains(query.toLowerCase());
          }).toList();
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.acessoRapido,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    onChanged: (value) => setModalState(() => query = value),
                    decoration: InputDecoration(
                      hintText: context.l10n.buscarModulo,
                      prefixIcon: const SigadIcon(SigadIcons.buscar),
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
                                context.l10n.nenhumModulo,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                tileColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                leading: SigadIcon(
                                  item.icon,
                                  color: SigadColors.brand,
                                ),
                                title: Text(item.rotuloEm(context.l10n)),
                                subtitle: item.subtituloEm(context.l10n) == null
                                    ? null
                                    : Text(item.subtituloEm(context.l10n)!),
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
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      child: Container(
        width: 272,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: colors.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 20,
              offset: const Offset(6, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: BrandTitle(),
            ),
            const SizedBox(height: 18),
            if (userContext.isAuthenticated)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _UserCard(userContext: userContext),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: OutlinedButton.icon(
                onPressed: onQuickAccess,
                icon: const SigadIcon(SigadIcons.buscar, size: 19),
                label: Text(context.l10n.acessoRapido),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  alignment: Alignment.centerLeft,
                  backgroundColor: colors.surfaceContainerLow,
                  side: BorderSide(color: colors.outlineVariant),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: availableItems.length,
                itemBuilder: (context, index) => _NavigationTile(
                  item: availableItems[index],
                  selected: index == selectedIndex,
                  onTap: () => onSelected(index),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: ListTile(
                onTap: onLogout,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const SigadIcon(
                  SigadIcons.sair,
                  color: SigadColors.risk,
                ),
                title: Text(context.l10n.sair),
              ),
            ),
          ],
        ),
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
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: availableItems.length,
                itemBuilder: (context, index) => _NavigationTile(
                  item: availableItems[index],
                  selected: index == selectedIndex,
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(index);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  onLogout();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const SigadIcon(
                  SigadIcons.sair,
                  color: SigadColors.risk,
                ),
                title: Text(context.l10n.sair),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: selected ? colors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          selected: selected,
          selectedColor: colors.onPrimaryContainer,
          selectedTileColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: 0.12)
                  : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SigadIcon(
              item.icon,
              size: 19,
              color: selected ? colors.primary : SigadColors.muted,
            ),
          ),
          title: Text(
            item.rotuloEm(context.l10n),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          trailing: selected
              ? Container(
                  width: 5,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.72),
            colors.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.surface,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: SigadColors.brand,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  user.role.nomeEm(context.l10n),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                ),
                Text(
                  user.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
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

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.userContext, required this.radius});

  final UserContextProvider userContext;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final user = userContext.currentUser;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
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
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: SigadColors.brand.withValues(alpha: 0.14),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: SigadColors.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.role.nomeEm(context.l10n),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const SigadIcon(
                SigadIcons.configuracoes,
                color: SigadColors.brand,
              ),
              title: Text(context.l10n.navConfiguracoes),
              onTap: () {
                final navigator = Navigator.of(context);
                String? rotaAtual;
                // Fecha o menu e identifica a página por baixo dele; troca a
                // rota como o _navigate do shell, sem empilhar outro shell.
                navigator.popUntil((route) {
                  if (route is PopupRoute) return false;
                  rotaAtual = route.settings.name;
                  return true;
                });
                if (rotaAtual == AppRoutes.configuracoes) return;
                navigator.pushReplacementNamed(AppRoutes.configuracoes);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const SigadIcon(
                SigadIcons.sair,
                color: SigadColors.risk,
              ),
              title: Text(context.l10n.sair),
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                _confirmLogout(navigator.context, userContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _confirmLogout(BuildContext context, UserContextProvider userContext) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.confirmarSaida),
      content: Text(context.l10n.confirmarSaidaMensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancelar),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await userContext.logout();
            if (!context.mounted) return;
            await Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          },
          child: Text(context.l10n.sair),
        ),
      ],
    ),
  );
}

/// Abre o menu do perfil do usuário autenticado.
void mostrarMenuPerfil(BuildContext context) {
  final userContext = context.read<UserContextProvider>();
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _ProfileMenu(userContext: userContext),
  );
}

/// Abre a lista de notificações do usuário autenticado.
void mostrarNotificacoes(BuildContext context) {
  final usuario = context.read<UserContextProvider>();
  final future = NotificacoesService.carregar(
    usuario.userRole,
    userName: usuario.currentUser?.name,
  );

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.notificacoes,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: FutureBuilder<List<NotificacaoModel>>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(context.l10n.erroCarregarNotificacoes),
                      );
                    }
                    final notificacoes = snapshot.data ?? const [];
                    if (notificacoes.isEmpty) {
                      return Center(
                        child: Text(context.l10n.nenhumaNotificacao),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: notificacoes.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notificacao = notificacoes[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: SigadIcon(notificacao.icone),
                          title: Text(notificacao.titulo),
                          subtitle: Text(notificacao.subtitulo),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Barra inferior com os três destinos principais: Visão geral, Calendário
/// e Anotações. Em módulos secundários nenhum destino aparece selecionado.
class _SigadBottomBar extends StatelessWidget {
  const _SigadBottomBar({required this.currentRoute, required this.onNavigate});

  final String currentRoute;
  final ValueChanged<String> onNavigate;

  static const _destinos = [
    (AppRoutes.dashboard, SigadIcons.painel),
    (AppRoutes.calendario, SigadIcons.calendario),
    (AppRoutes.notas, SigadIcons.editarNota),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('sigad-bottom-bar'),
      color: SigadColors.brandDeep,
      elevation: 8,
      shadowColor: const Color(0x55000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              for (final (route, icon) in _destinos)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _BottomBarItem(
                      icon: icon,
                      label: rotuloDaRota(route, context.l10n) ?? route,
                      selected: currentRoute == route,
                      onTap: () => onNavigate(route),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Selecionado: pílula clara com tinta escura, contraste alto contra a
    // barra; não depende só do peso da fonte.
    final tinta = selected ? SigadColors.brandDeep : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: selected ? SigadColors.mint : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SigadIcon(icon, color: tinta, size: 24),
                  const SizedBox(height: 4),
                  MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.3,
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: tinta,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
