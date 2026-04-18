import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/user_context_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final profile = _RoleProfile.fromRole(role);
    final userName = userContext.currentUser?.name ?? 'Usuário';

    final availableModules = kNavigationItems
        .where((item) => role == null || item.isAvailableFor(role))
        .where((item) => item.route != AppRoutes.dashboard)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        return Stack(
          children: [
            const _AmbientBackground(),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 8 : 10,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroPanel(
                    profile: profile,
                    userName: userName,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Indicadores principais',
                    icon: Icons.insights_outlined,
                  ),
                  const SizedBox(height: 12),
                  _MetricsGrid(metrics: profile.metrics),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Atalhos do seu perfil',
                    icon: Icons.apps_outlined,
                  ),
                  const SizedBox(height: 12),
                  _ModuleGrid(modules: availableModules),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Prioridades de hoje',
                    icon: Icons.track_changes_outlined,
                  ),
                  const SizedBox(height: 12),
                  _DynamicPriorityList(
                    role: role,
                    fallbackItems: profile.priorities,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.profile,
    required this.userName,
  });

  final _RoleProfile profile;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= 1024;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 34 : 24,
        vertical: isWide ? 22 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            profile.tone,
            profile.tone.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: profile.tone.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, $userName',
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.title,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.focus
                .map(
                  (label) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: SigadColors.brand, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final List<_RoleMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 132,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _RoleMetric metric;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: metric.tone.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(metric.icon, color: metric.tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.label,
                  style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.modules});

  final List<NavigationItem> modules;

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const SizedBox.shrink();
    }

    final isWide = MediaQuery.of(context).size.width >= 900;
    final crossAxisCount = isWide ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 122,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => _ModuleCard(item: modules[index]),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.item});

  final NavigationItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = item.subtitle?.trim();

    return Material(
      color: SigadColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SigadColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: SigadColors.brand.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: SigadColors.brand),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_outward_rounded, color: SigadColors.muted, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.label,
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityList extends StatelessWidget {
  const _PriorityList({required this.items});

  final List<_PriorityItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SigadColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SigadColors.divider),
              ),
              child: Row(
                children: [
                  Icon(item.icon, color: item.tone),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DynamicPriorityList extends StatefulWidget {
  const _DynamicPriorityList({
    required this.role,
    required this.fallbackItems,
  });

  final UserRole? role;
  final List<_PriorityItem> fallbackItems;

  @override
  State<_DynamicPriorityList> createState() => _DynamicPriorityListState();
}

class _DynamicPriorityListState extends State<_DynamicPriorityList> {
  static const String _demandasKey = 'sigad_demandas';
  static const String _kanbanKey = 'sigad_kanban';
  late Future<List<_PriorityItem>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = _buildDynamicItems();
  }

  Future<List<_PriorityItem>> _buildDynamicItems() async {
    final demandas = await LocalStorageService.loadList(_demandasKey);
    final kanban = await LocalStorageService.loadList(_kanbanKey);

    final items = <_PriorityItem>[];

    final demandasAtrasadas = _countDemandasAtrasadas(demandas);
    if (demandasAtrasadas > 0) {
      items.add(
        _PriorityItem(
          label: 'Resolver $demandasAtrasadas demanda(s) em atraso',
          icon: Icons.warning_amber_outlined,
          tone: SigadColors.risk,
        ),
      );
    }

    final demandasAltasAbertas = _countDemandasAltasAbertas(demandas);
    if (demandasAltasAbertas > 0) {
      items.add(
        _PriorityItem(
          label: 'Tratar $demandasAltasAbertas demanda(s) de alta prioridade',
          icon: Icons.priority_high_outlined,
          tone: SigadColors.warning,
        ),
      );
    }

    final cardsEmRevisao = _countKanbanByColumn(kanban, 'Em Revisão');
    if (cardsEmRevisao > 0) {
      items.add(
        _PriorityItem(
          label: 'Validar $cardsEmRevisao card(s) em revisão no Kanban',
          icon: Icons.rate_review_outlined,
          tone: SigadColors.info,
        ),
      );
    }

    final cardsBacklogAlto = _countKanbanBacklogHigh(kanban);
    if (cardsBacklogAlto > 0) {
      items.add(
        _PriorityItem(
          label: 'Priorizar $cardsBacklogAlto card(s) críticos do backlog',
          icon: Icons.view_kanban_outlined,
          tone: SigadColors.brand,
        ),
      );
    }

    if (items.isEmpty) {
      return widget.fallbackItems;
    }

    return items.take(3).toList();
  }

  int _countDemandasAtrasadas(List<dynamic> demandas) {
    final now = DateTime.now();
    var total = 0;
    for (final item in demandas) {
      if (item is! Map<String, dynamic>) continue;
      final status = (item['statusLabel'] as String? ?? '').toLowerCase();
      if (status == 'concluído' || status == 'concluido') continue;
      final prazo = _parseDate(item['prazo'] as String?);
      if (prazo != null && prazo.isBefore(DateTime(now.year, now.month, now.day))) {
        total++;
      }
    }
    return total;
  }

  int _countDemandasAltasAbertas(List<dynamic> demandas) {
    var total = 0;
    for (final item in demandas) {
      if (item is! Map<String, dynamic>) continue;
      final prioridade = (item['prioridade'] as String? ?? '').toLowerCase();
      final status = (item['statusLabel'] as String? ?? '').toLowerCase();
      if (prioridade == 'alta' && status != 'concluído' && status != 'concluido') {
        total++;
      }
    }
    return total;
  }

  int _countKanbanByColumn(List<dynamic> cards, String column) {
    var total = 0;
    for (final item in cards) {
      if (item is! Map<String, dynamic>) continue;
      final coluna = (item['coluna'] as String? ?? '').toLowerCase();
      if (coluna == column.toLowerCase()) {
        total++;
      }
    }
    return total;
  }

  int _countKanbanBacklogHigh(List<dynamic> cards) {
    var total = 0;
    for (final item in cards) {
      if (item is! Map<String, dynamic>) continue;
      final coluna = (item['coluna'] as String? ?? '').toLowerCase();
      final prioridade = (item['prioridade'] as String? ?? '').toLowerCase();
      if (coluna == 'backlog' && prioridade == 'alta') {
        total++;
      }
    }
    return total;
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_PriorityItem>>(
      future: _futureItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 70,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
          );
        }

        final items = snapshot.data ?? widget.fallbackItems;
        return _PriorityList(items: items);
      },
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [SigadColors.canvas, SigadColors.surfaceAlt],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleMetric {
  const _RoleMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tone;
}

class _PriorityItem {
  const _PriorityItem({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final Color tone;
}

class _RoleProfile {
  const _RoleProfile({
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.metrics,
    required this.priorities,
    required this.focus,
  });

  final String title;
  final String subtitle;
  final Color tone;
  final List<_RoleMetric> metrics;
  final List<_PriorityItem> priorities;
  final List<String> focus;

  static _RoleProfile fromRole(UserRole? role) {
    switch (role) {
      case UserRole.professor:
        return _RoleProfile(
          title: 'Perfil Professor',
          subtitle: 'Acompanhe sua carga, aulas e demandas acadêmicas.',
          tone: SigadColors.brand,
          metrics: const [
            _RoleMetric(label: 'Disciplinas', value: '5', icon: Icons.menu_book_outlined, tone: SigadColors.brand),
            _RoleMetric(label: 'Carga semanal', value: '32h', icon: Icons.schedule_outlined, tone: SigadColors.info),
            _RoleMetric(label: 'Pendências', value: '3', icon: Icons.pending_actions_outlined, tone: SigadColors.warning),
          ],
          priorities: const [
            _PriorityItem(label: 'Confirmar plano de aula da semana', icon: Icons.checklist_outlined, tone: SigadColors.info),
            _PriorityItem(label: 'Atualizar registro de atividades', icon: Icons.fact_check_outlined, tone: SigadColors.brand),
            _PriorityItem(label: 'Validar horas complementares', icon: Icons.timer_outlined, tone: SigadColors.warning),
          ],
          focus: const ['Aulas', 'Carga', 'Atividades'],
        );
      case UserRole.coordenador:
        return _RoleProfile(
          title: 'Perfil Coordenador',
          subtitle: 'Gerencie demandas do curso e distribua responsabilidades.',
          tone: SigadColors.info,
          metrics: const [
            _RoleMetric(label: 'Demandas abertas', value: '24', icon: Icons.assignment_outlined, tone: SigadColors.info),
            _RoleMetric(label: 'Docentes ativos', value: '38', icon: Icons.school_outlined, tone: SigadColors.success),
            _RoleMetric(label: 'Sprints em curso', value: '2', icon: Icons.flag_outlined, tone: SigadColors.brand),
          ],
          priorities: const [
            _PriorityItem(label: 'Priorizar demandas críticas da semana', icon: Icons.priority_high_outlined, tone: SigadColors.risk),
            _PriorityItem(label: 'Fechar horários dos docentes', icon: Icons.balance_outlined, tone: SigadColors.info),
            _PriorityItem(label: 'Aprovar tarefas do curso', icon: Icons.view_kanban_outlined, tone: SigadColors.brand),
          ],
          focus: const ['Demandas', 'Tarefas', 'Relatórios'],
        );
      case UserRole.servidorAdministrativo:
        return _RoleProfile(
          title: 'Perfil Servidor Administrativo',
          subtitle: 'Mantenha processos operacionais e fluxos documentais em dia.',
          tone: SigadColors.accent,
          metrics: const [
            _RoleMetric(label: 'Processos hoje', value: '18', icon: Icons.folder_open_outlined, tone: SigadColors.accent),
            _RoleMetric(label: 'Solicitações', value: '11', icon: Icons.request_page_outlined, tone: SigadColors.info),
            _RoleMetric(label: 'Concluídos', value: '9', icon: Icons.task_alt_outlined, tone: SigadColors.success),
          ],
          priorities: const [
            _PriorityItem(label: 'Conferir documentos de laboratório', icon: Icons.description_outlined, tone: SigadColors.info),
            _PriorityItem(label: 'Atualizar status de protocolos', icon: Icons.swap_horiz_outlined, tone: SigadColors.accent),
            _PriorityItem(label: 'Enviar relatório diário para coordenação', icon: Icons.send_outlined, tone: SigadColors.brand),
          ],
          focus: const ['Protocolos', 'Relatórios', 'Atendimento'],
        );
      case UserRole.chefeDepartamento:
        return _RoleProfile(
          title: 'Perfil Chefe de Departamento',
          subtitle: 'Visão estratégica de governança, desempenho e alocação.',
          tone: SigadColors.brandDark,
          metrics: const [
            _RoleMetric(label: 'Indicadores-chave', value: '12', icon: Icons.analytics_outlined, tone: SigadColors.brandDark),
            _RoleMetric(label: 'Demandas críticas', value: '4', icon: Icons.warning_amber_outlined, tone: SigadColors.risk),
            _RoleMetric(label: 'Cumprimento SLA', value: '92%', icon: Icons.av_timer_outlined, tone: SigadColors.success),
          ],
          priorities: const [
            _PriorityItem(label: 'Validar plano de metas do mês', icon: Icons.track_changes_outlined, tone: SigadColors.brandDark),
            _PriorityItem(label: 'Aprovar redistribuição de equipe', icon: Icons.groups_outlined, tone: SigadColors.info),
            _PriorityItem(label: 'Revisar painel de desempenho institucional', icon: Icons.query_stats_outlined, tone: SigadColors.success),
          ],
          focus: const ['Estratégia', 'Governança', 'KPIs'],
        );
      default:
        return _RoleProfile(
          title: 'Visão geral do SIGAD',
          subtitle: 'Selecione um perfil para ver atalhos e prioridades personalizadas.',
          tone: SigadColors.brand,
          metrics: const [
            _RoleMetric(label: 'Módulos ativos', value: '6', icon: Icons.dashboard_outlined, tone: SigadColors.brand),
            _RoleMetric(label: 'Usuários online', value: '42', icon: Icons.groups_outlined, tone: SigadColors.info),
            _RoleMetric(label: 'Demandas no sistema', value: '24', icon: Icons.inbox_outlined, tone: SigadColors.success),
          ],
          priorities: const [
            _PriorityItem(label: 'Realize login com um dos perfis', icon: Icons.login_outlined, tone: SigadColors.brand),
            _PriorityItem(label: 'Explore os módulos disponíveis', icon: Icons.apps_outlined, tone: SigadColors.info),
          ],
          focus: const ['Planejamento', 'Fluxo', 'Transparência'],
        );
    }
  }
}
