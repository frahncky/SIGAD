import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/user_context_provider.dart';

class SigadDashboardPage extends StatelessWidget {
  const SigadDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserContextProvider>().currentUser;
    final firstName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim().split(' ').first
        : 'usuário';

    return _PageFrame(
      header: _OverviewHero(firstName: firstName),
      children: [
        const _OverviewSectionTitle(
          icon: Icons.monitor_heart_outlined,
          title: 'Panorama do departamento',
          trailing: 'Atualizado agora',
        ),
        const SizedBox(height: 12),
        _ResponsiveGrid(
          minItemWidth: 190,
          children: const [
            _MetricCard(
              icon: Icons.schedule_outlined,
              label: 'Carga horária alocada',
              value: '412h',
              detail: '↑ 6% vs. mês anterior',
              tone: _MetricTone.primary,
            ),
            _MetricCard(
              icon: Icons.science_outlined,
              label: 'Laboratórios em uso',
              value: '62%',
              detail: '↑ 12% vs. semana anterior',
              tone: _MetricTone.success,
            ),
            _MetricCard(
              icon: Icons.campaign_outlined,
              label: 'Notícias enviadas',
              value: '8',
              detail: '↑ 3 vs. semana anterior',
              tone: _MetricTone.info,
            ),
            _MetricCard(
              icon: Icons.error_outline_rounded,
              label: 'Pendências em aberto',
              value: '7',
              detail: '↓ 1 vs. semana anterior',
              tone: _MetricTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _OverviewSectionTitle(
          icon: Icons.outlined_flag_rounded,
          title: 'Próximas prioridades',
          trailing: 'Ver todas',
        ),
        const SizedBox(height: 12),
        const _SectionCard(
          title: 'Prioridades do departamento',
          subtitle: 'Planejamento e atividades mais próximas',
          icon: Icons.flag_outlined,
          showHeader: false,
          child: Column(
            children: [
              _PriorityTile(
                title: 'Planejamento da carga horária 2025.2',
                subtitle: 'Consolidar propostas e validar alocações',
                icon: Icons.calendar_month_outlined,
                tone: _MetricTone.risk,
              ),
              _PriorityTile(
                title: 'Otimizar uso dos laboratórios',
                subtitle: 'Ajustar grade de reservas e ocupação',
                icon: Icons.science_outlined,
                tone: _MetricTone.warning,
              ),
              _PriorityTile(
                title: 'Reunião departamental',
                subtitle: 'Pauta: projetos, avaliações e demandas',
                icon: Icons.groups_outlined,
                tone: _MetricTone.info,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _OverviewSectionTitle(
          icon: Icons.bolt_outlined,
          title: 'Acesso rápido',
          trailing: 'Personalizar',
        ),
        const SizedBox(height: 12),
        _ResponsiveGrid(
          minItemWidth: 180,
          children: [
            _QuickAction(
              icon: Icons.co_present_outlined,
              label: 'Carga docente',
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.cargaDocente,
              ),
            ),
            _QuickAction(
              icon: Icons.science_outlined,
              label: 'Laboratórios',
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.aulasPraticas,
              ),
            ),
            _QuickAction(
              icon: Icons.campaign_outlined,
              label: 'Notícias',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.batePapo),
            ),
            _QuickAction(
              icon: Icons.event_available_outlined,
              label: 'Reuniões',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.calendario),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33004D40),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $firstName',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Confira os destaques do departamento',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_outlined, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'INSTITUTO FEDERAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              const highlights = [
                _OverviewHighlight(
                  icon: Icons.error_outline_rounded,
                  label: 'AVISO URGENTE',
                  title: 'Laboratório 2 interditado',
                  detail: 'Manutenção elétrica até 23/05',
                  action: 'Ver detalhes',
                  color: Color(0xFFFF6B6B),
                ),
                _OverviewHighlight(
                  icon: Icons.calendar_month_outlined,
                  label: 'REUNIÃO PRÓXIMA',
                  title: 'Reunião departamental',
                  detail: 'Amanhã • 10:00 • Sala 204',
                  action: 'Ver pauta',
                  color: Color(0xFF57D68D),
                ),
                _OverviewHighlight(
                  icon: Icons.assignment_outlined,
                  label: 'DEMANDA PENDENTE',
                  title: '1 aguardando atribuição',
                  detail: 'Necessita encaminhamento',
                  action: 'Ver demanda',
                  color: Color(0xFFFFB74D),
                ),
                _OverviewHighlight(
                  icon: Icons.science_outlined,
                  label: 'MANUTENÇÃO',
                  title: 'Lab. de Eletrônica',
                  detail: 'Preventiva agendada para 24/05',
                  action: 'Ver cronograma',
                  color: Color(0xFF64B5F6),
                ),
              ];
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: highlights
                    .map((item) => SizedBox(width: width, child: item))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewHighlight extends StatelessWidget {
  const _OverviewHighlight({
    required this.icon,
    required this.label,
    required this.title,
    required this.detail,
    required this.action,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String title;
  final String detail;
  final String action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.22),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                action,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewSectionTitle extends StatelessWidget {
  const _OverviewSectionTitle({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(trailing, style: TextStyle(color: colors.primary)),
      ],
    );
  }
}

class SigadChatPage extends StatefulWidget {
  const SigadChatPage({super.key});

  @override
  State<SigadChatPage> createState() => _SigadChatPageState();
}

class _SigadChatPageState extends State<SigadChatPage> {
  String _query = '';
  int _selected = 0;
  final _controller = TextEditingController();

  final List<_Conversation> _conversations = const [
    _Conversation(
      name: 'Equipe do departamento',
      message: 'A pauta da reunião foi atualizada.',
      time: '10:42',
      unread: 3,
      group: true,
    ),
    _Conversation(
      name: 'Coordenação de curso',
      message: 'Podemos revisar a distribuição amanhã?',
      time: '09:18',
      unread: 1,
      group: true,
    ),
    _Conversation(
      name: 'Secretaria acadêmica',
      message: 'Documento recebido e encaminhado.',
      time: 'Ontem',
    ),
    _Conversation(
      name: 'Comissão de laboratórios',
      message: 'A manutenção do equipamento foi concluída.',
      time: 'Ontem',
      group: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _conversations
        .where((item) => item.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final selectedConversation = filtered.isEmpty
        ? null
        : filtered[_selected.clamp(0, filtered.length - 1)];

    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'COMUNICAÇÃO',
        title: 'Bate-papo',
        subtitle: 'Conversas, grupos e avisos internos do departamento.',
        actions: [
          _HeaderAction(
            icon: Icons.add_comment_outlined,
            label: 'Nova conversa',
            onPressed: () => _showActionDialog(
              context,
              title: 'Nova conversa',
              message:
                  'Selecione usuários ou grupos para iniciar uma conversa.',
            ),
          ),
        ],
      ),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final list = _ConversationList(
              query: _query,
              conversations: filtered,
              selectedIndex: _selected,
              onQueryChanged: (value) => setState(() {
                _query = value;
                _selected = 0;
              }),
              onSelected: (index) => setState(() => _selected = index),
            );
            final chat = _ChatPanel(
              conversation: selectedConversation,
              controller: _controller,
              onSend: () {
                if (_controller.text.trim().isEmpty) return;
                _notify(context, 'Mensagem enviada.');
                _controller.clear();
              },
            );

            if (wide) {
              return SizedBox(
                height: 650,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 340, child: list),
                    const SizedBox(width: 16),
                    Expanded(child: chat),
                  ],
                ),
              );
            }

            return Column(
              children: [
                SizedBox(height: 430, child: list),
                const SizedBox(height: 16),
                SizedBox(height: 560, child: chat),
              ],
            );
          },
        ),
      ],
    );
  }
}

class SigadCargaDocentePage extends StatefulWidget {
  const SigadCargaDocentePage({super.key});

  @override
  State<SigadCargaDocentePage> createState() => _SigadCargaDocentePageState();
}

class _SigadCargaDocentePageState extends State<SigadCargaDocentePage> {
  String _periodo = '2026.2';
  String _status = 'Todos';

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'GESTÃO ACADÊMICA',
        title: 'Carga docente',
        subtitle:
            'Distribuição, limites, conflitos e validação das atividades.',
        actions: [
          _HeaderAction(
            icon: Icons.add_rounded,
            label: 'Nova distribuição',
            onPressed: () => _showActionDialog(
              context,
              title: 'Nova distribuição',
              message: 'Cadastre disciplinas, atividades e carga do docente.',
            ),
          ),
        ],
      ),
      children: [
        _FilterToolbar(
          children: [
            _DropdownFilter(
              label: 'Período',
              value: _periodo,
              items: const ['2026.1', '2026.2', '2027.1'],
              onChanged: (value) => setState(() => _periodo = value),
            ),
            _DropdownFilter(
              label: 'Status',
              value: _status,
              items: const ['Todos', 'Regular', 'Atenção', 'Excedida'],
              onChanged: (value) => setState(() => _status = value),
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar professor',
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _ResponsiveGrid(
          minItemWidth: 210,
          children: [
            _MetricCard(
              icon: Icons.groups_2_outlined,
              label: 'Docentes',
              value: '32',
              detail: 'Período 2026.2',
              tone: _MetricTone.primary,
            ),
            _MetricCard(
              icon: Icons.check_circle_outline,
              label: 'Carga regular',
              value: '24',
              detail: '75% do quadro',
              tone: _MetricTone.success,
            ),
            _MetricCard(
              icon: Icons.warning_amber_rounded,
              label: 'Requer atenção',
              value: '06',
              detail: 'Abaixo ou acima do limite',
              tone: _MetricTone.warning,
            ),
            _MetricCard(
              icon: Icons.sync_problem_outlined,
              label: 'Conflitos',
              value: '02',
              detail: 'Horários sobrepostos',
              tone: _MetricTone.risk,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Distribuição por docente',
          subtitle: 'Ensino, pesquisa, extensão, gestão e orientações',
          icon: Icons.balance_outlined,
          child: Column(
            children: const [
              _WorkloadRow(
                name: 'Docente 01',
                initials: 'D1',
                teaching: 16,
                other: 4,
                maximum: 20,
                status: 'Regular',
                tone: _MetricTone.success,
              ),
              _WorkloadRow(
                name: 'Docente 02',
                initials: 'D2',
                teaching: 12,
                other: 4,
                maximum: 20,
                status: 'Atenção',
                tone: _MetricTone.warning,
              ),
              _WorkloadRow(
                name: 'Docente 03',
                initials: 'D3',
                teaching: 18,
                other: 4,
                maximum: 20,
                status: 'Excedida',
                tone: _MetricTone.risk,
              ),
              _WorkloadRow(
                name: 'Docente 04',
                initials: 'D4',
                teaching: 14,
                other: 6,
                maximum: 20,
                status: 'Regular',
                tone: _MetricTone.success,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SigadProfessoresPage extends StatefulWidget {
  const SigadProfessoresPage({super.key});

  @override
  State<SigadProfessoresPage> createState() => _SigadProfessoresPageState();
}

class _SigadProfessoresPageState extends State<SigadProfessoresPage> {
  String _query = '';
  String _area = 'Todas';

  @override
  Widget build(BuildContext context) {
    final docentes = const [
      _TeacherData('Docente 01', 'Eletrônica', '20h', 'Ativo', 'D1'),
      _TeacherData('Docente 02', 'Eletrotécnica', '18h', 'Ativo', 'D2'),
      _TeacherData(
        'Docente 03',
        'Telecomunicações',
        '16h',
        'Afastamento',
        'D3',
      ),
      _TeacherData('Docente 04', 'Automação', '20h', 'Ativo', 'D4'),
      _TeacherData('Docente 05', 'Computação', '14h', 'Ativo', 'D5'),
      _TeacherData('Docente 06', 'Eletrotécnica', '12h', 'Atenção', 'D6'),
    ];
    final filtered = docentes.where((item) {
      final matchesQuery =
          item.name.toLowerCase().contains(_query.toLowerCase()) ||
          item.area.toLowerCase().contains(_query.toLowerCase());
      return matchesQuery && (_area == 'Todas' || item.area == _area);
    }).toList();

    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'GESTÃO DE PESSOAS',
        title: 'Professores',
        subtitle: 'Quadro docente, áreas, situação funcional e carga atual.',
        actions: [
          _HeaderAction(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Cadastrar',
            onPressed: () => _showActionDialog(
              context,
              title: 'Cadastrar professor',
              message: 'Informe dados funcionais, área e vínculo.',
            ),
          ),
        ],
      ),
      children: [
        _FilterToolbar(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar nome ou área',
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
            ),
            _DropdownFilter(
              label: 'Área',
              value: _area,
              items: const [
                'Todas',
                'Eletrônica',
                'Eletrotécnica',
                'Telecomunicações',
                'Automação',
                'Computação',
              ],
              onChanged: (value) => setState(() => _area = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ResponsiveGrid(
          minItemWidth: 260,
          children: filtered
              .map(
                (teacher) => _TeacherCard(
                  teacher: teacher,
                  onTap: () => _showActionDialog(
                    context,
                    title: teacher.name,
                    message:
                        'Área: ${teacher.area}\nCarga atual: ${teacher.load}\nSituação: ${teacher.status}',
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class SigadDemandasPage extends StatefulWidget {
  const SigadDemandasPage({super.key});

  @override
  State<SigadDemandasPage> createState() => _SigadDemandasPageState();
}

class _SigadDemandasPageState extends State<SigadDemandasPage> {
  String _status = 'Todas';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = const [
      _DemandData(
        id: 'DEM-001',
        title: 'Atualização de equipamentos',
        owner: 'Infraestrutura',
        deadline: '22/07',
        status: 'Em análise',
        priority: 'Alta',
      ),
      _DemandData(
        id: 'DEM-002',
        title: 'Revisão do plano de trabalho',
        owner: 'Gestão',
        deadline: '25/07',
        status: 'Em andamento',
        priority: 'Média',
      ),
      _DemandData(
        id: 'DEM-003',
        title: 'Reserva de espaço institucional',
        owner: 'Extensão',
        deadline: '30/07',
        status: 'Aguardando',
        priority: 'Baixa',
      ),
      _DemandData(
        id: 'DEM-004',
        title: 'Manutenção preventiva',
        owner: 'Laboratórios',
        deadline: '18/07',
        status: 'Atrasada',
        priority: 'Alta',
      ),
    ];
    final filtered = items.where((item) {
      final text = '${item.id} ${item.title} ${item.owner}'.toLowerCase();
      return text.contains(_query.toLowerCase()) &&
          (_status == 'Todas' || item.status == _status);
    }).toList();

    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'PLANEJAMENTO',
        title: 'Demandas',
        subtitle: 'Solicitações, responsáveis, prazos e acompanhamento.',
        actions: [
          _HeaderAction(
            icon: Icons.add_task_outlined,
            label: 'Nova demanda',
            onPressed: () => _showActionDialog(
              context,
              title: 'Nova demanda',
              message: 'Cadastre descrição, responsável, prazo e prioridade.',
            ),
          ),
        ],
      ),
      children: [
        const _ResponsiveGrid(
          minItemWidth: 210,
          children: [
            _MetricCard(
              icon: Icons.inbox_outlined,
              label: 'Abertas',
              value: '12',
              detail: 'No período atual',
              tone: _MetricTone.primary,
            ),
            _MetricCard(
              icon: Icons.timelapse_outlined,
              label: 'Em andamento',
              value: '07',
              detail: '58% do total',
              tone: _MetricTone.info,
            ),
            _MetricCard(
              icon: Icons.error_outline_rounded,
              label: 'Atrasadas',
              value: '03',
              detail: 'Ação necessária',
              tone: _MetricTone.risk,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _FilterToolbar(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar demanda',
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
            ),
            _DropdownFilter(
              label: 'Status',
              value: _status,
              items: const [
                'Todas',
                'Em análise',
                'Em andamento',
                'Aguardando',
                'Atrasada',
              ],
              onChanged: (value) => setState(() => _status = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Lista de demandas',
          subtitle: '${filtered.length} resultados',
          icon: Icons.assignment_outlined,
          child: Column(
            children: filtered
                .map(
                  (item) => _DemandTile(
                    item: item,
                    onTap: () => _showActionDialog(
                      context,
                      title: item.title,
                      message:
                          '${item.id}\nResponsável: ${item.owner}\nPrazo: ${item.deadline}\nPrioridade: ${item.priority}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class SigadKanbanPage extends StatefulWidget {
  const SigadKanbanPage({super.key});

  @override
  State<SigadKanbanPage> createState() => _SigadKanbanPageState();
}

class _SigadKanbanPageState extends State<SigadKanbanPage> {
  final Map<String, List<_TaskData>> _columns = {
    'A fazer': [
      const _TaskData('Revisar inventário', 'Laboratórios', 'Alta'),
      const _TaskData('Conferir documentos', 'Secretaria', 'Média'),
    ],
    'Em andamento': [
      const _TaskData('Planejar semestre', 'Gestão', 'Alta'),
      const _TaskData('Atualizar horários', 'Coordenação', 'Média'),
    ],
    'Concluído': [
      const _TaskData('Enviar relatório mensal', 'Gestão', 'Baixa'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'EXECUÇÃO',
        title: 'Tarefas',
        subtitle: 'Quadro visual para acompanhar atividades e responsáveis.',
        actions: [
          _HeaderAction(
            icon: Icons.add_rounded,
            label: 'Nova tarefa',
            onPressed: () => _showActionDialog(
              context,
              title: 'Nova tarefa',
              message: 'Defina título, responsável, prazo e prioridade.',
            ),
          ),
        ],
      ),
      children: [
        SizedBox(
          height: 610,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 980
                  ? (constraints.maxWidth - 32) / 3
                  : 310.0;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _columns.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final entry = _columns.entries.elementAt(index);
                  return SizedBox(
                    width: width,
                    child: _KanbanColumn(
                      title: entry.key,
                      items: entry.value,
                      onAdd: () => _notify(
                        context,
                        'Ação para adicionar tarefa em ${entry.key}.',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class SigadLaboratoriosPage extends StatefulWidget {
  const SigadLaboratoriosPage({super.key});

  @override
  State<SigadLaboratoriosPage> createState() => _SigadLaboratoriosPageState();
}

class _SigadLaboratoriosPageState extends State<SigadLaboratoriosPage> {
  String _lab = 'Todos';
  String _view = 'Agenda semanal';

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'INFRAESTRUTURA',
        title: 'Laboratórios',
        subtitle: 'Disponibilidade, reservas, conflitos e manutenção.',
        actions: [
          _HeaderAction(
            icon: Icons.add_circle_outline,
            label: 'Nova reserva',
            onPressed: () => _showActionDialog(
              context,
              title: 'Nova reserva',
              message:
                  'Selecione laboratório, data, turno, disciplina e responsável.',
            ),
          ),
        ],
      ),
      children: [
        const _ResponsiveGrid(
          minItemWidth: 210,
          children: [
            _MetricCard(
              icon: Icons.event_available_outlined,
              label: 'Reservas hoje',
              value: '09',
              detail: '5 laboratórios',
              tone: _MetricTone.primary,
            ),
            _MetricCard(
              icon: Icons.meeting_room_outlined,
              label: 'Em uso',
              value: '05',
              detail: 'Neste horário',
              tone: _MetricTone.success,
            ),
            _MetricCard(
              icon: Icons.build_circle_outlined,
              label: 'Em manutenção',
              value: '01',
              detail: 'Acesso temporariamente restrito',
              tone: _MetricTone.warning,
            ),
            _MetricCard(
              icon: Icons.sync_problem_outlined,
              label: 'Conflitos',
              value: '00',
              detail: 'Nenhuma sobreposição',
              tone: _MetricTone.info,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _FilterToolbar(
          children: [
            _DropdownFilter(
              label: 'Laboratório',
              value: _lab,
              items: const [
                'Todos',
                'Laboratório 1',
                'Laboratório 2',
                'Laboratório 3',
                'Laboratório 6',
              ],
              onChanged: (value) => setState(() => _lab = value),
            ),
            _DropdownFilter(
              label: 'Visualização',
              value: _view,
              items: const ['Agenda semanal', 'Calendário mensal', 'Ocupação'],
              onChanged: (value) => setState(() => _view = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_view == 'Agenda semanal')
          _SectionCard(
            title: 'Agenda semanal',
            subtitle: 'Períodos de segunda a sexta',
            icon: Icons.calendar_view_week_outlined,
            child: const _LabSchedule(),
          )
        else if (_view == 'Calendário mensal')
          _SectionCard(
            title: 'Calendário de reservas',
            subtitle: 'Visão consolidada do mês',
            icon: Icons.calendar_month_outlined,
            child: const _MonthOverview(),
          )
        else
          _SectionCard(
            title: 'Ocupação e otimização',
            subtitle: 'Uso médio e horários disponíveis',
            icon: Icons.analytics_outlined,
            child: const _LabOccupancy(),
          ),
      ],
    );
  }
}

class SigadAtividadesPage extends StatefulWidget {
  const SigadAtividadesPage({super.key});

  @override
  State<SigadAtividadesPage> createState() => _SigadAtividadesPageState();
}

class _SigadAtividadesPageState extends State<SigadAtividadesPage> {
  String _status = 'Todas';

  @override
  Widget build(BuildContext context) {
    final atividades = const [
      _ActivityData(
        'Atualizar plano de ensino',
        'Acadêmica',
        '20/07',
        'Pendente',
      ),
      _ActivityData(
        'Revisar inventário',
        'Laboratórios',
        '22/07',
        'Em progresso',
      ),
      _ActivityData('Preparar relatório', 'Gestão', '25/07', 'Pendente'),
      _ActivityData('Publicar comunicado', 'Comunicação', '18/07', 'Concluída'),
    ];
    final filtered = atividades
        .where((item) => _status == 'Todas' || item.status == _status)
        .toList();

    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'ACOMPANHAMENTO',
        title: 'Atividades',
        subtitle:
            'Ações acadêmicas e administrativas com prazos e responsáveis.',
        actions: [
          _HeaderAction(
            icon: Icons.add_task_outlined,
            label: 'Nova atividade',
            onPressed: () => _showActionDialog(
              context,
              title: 'Nova atividade',
              message: 'Cadastre título, categoria, prazo e responsável.',
            ),
          ),
        ],
      ),
      children: [
        _FilterToolbar(
          children: [
            _DropdownFilter(
              label: 'Status',
              value: _status,
              items: const ['Todas', 'Pendente', 'Em progresso', 'Concluída'],
              onChanged: (value) => setState(() => _status = value),
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar atividade',
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Atividades do período',
          subtitle: '${filtered.length} itens',
          icon: Icons.fact_check_outlined,
          child: Column(
            children: filtered
                .map(
                  (item) => _ActivityTile(
                    item: item,
                    onTap: () => _showActionDialog(
                      context,
                      title: item.title,
                      message:
                          'Categoria: ${item.category}\nPrazo: ${item.deadline}\nStatus: ${item.status}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class SigadRelatoriosPage extends StatefulWidget {
  const SigadRelatoriosPage({super.key});

  @override
  State<SigadRelatoriosPage> createState() => _SigadRelatoriosPageState();
}

class _SigadRelatoriosPageState extends State<SigadRelatoriosPage> {
  String _periodo = '2026.2';
  String _tipo = 'Todos';

  @override
  Widget build(BuildContext context) {
    final reports = const [
      _ReportData(
        'Distribuição de carga docente',
        'Acadêmico',
        'Atualizado hoje',
        Icons.balance_outlined,
      ),
      _ReportData(
        'Ocupação dos laboratórios',
        'Infraestrutura',
        'Atualizado ontem',
        Icons.science_outlined,
      ),
      _ReportData(
        'Demandas por situação',
        'Gestão',
        'Atualizado hoje',
        Icons.assignment_outlined,
      ),
      _ReportData(
        'Atividades do departamento',
        'Produtividade',
        'Atualizado em 15/07',
        Icons.analytics_outlined,
      ),
    ];

    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'ANÁLISE',
        title: 'Relatórios',
        subtitle: 'Indicadores, documentos e exportações para apoio à gestão.',
        actions: [
          _HeaderAction(
            icon: Icons.auto_graph_outlined,
            label: 'Gerar relatório',
            onPressed: () => _showActionDialog(
              context,
              title: 'Gerar relatório',
              message: 'Selecione fonte, período, formato e filtros.',
            ),
          ),
        ],
      ),
      children: [
        _FilterToolbar(
          children: [
            _DropdownFilter(
              label: 'Período',
              value: _periodo,
              items: const ['2026.1', '2026.2', '2027.1'],
              onChanged: (value) => setState(() => _periodo = value),
            ),
            _DropdownFilter(
              label: 'Tipo',
              value: _tipo,
              items: const [
                'Todos',
                'Acadêmico',
                'Infraestrutura',
                'Gestão',
                'Produtividade',
              ],
              onChanged: (value) => setState(() => _tipo = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _ResponsiveGrid(
          minItemWidth: 210,
          children: [
            _MetricCard(
              icon: Icons.description_outlined,
              label: 'Relatórios disponíveis',
              value: '12',
              detail: '4 categorias',
              tone: _MetricTone.primary,
            ),
            _MetricCard(
              icon: Icons.download_done_outlined,
              label: 'Exportados no mês',
              value: '18',
              detail: 'PDF, XLSX e CSV',
              tone: _MetricTone.success,
            ),
            _MetricCard(
              icon: Icons.schedule_outlined,
              label: 'Agendados',
              value: '03',
              detail: 'Envio automático',
              tone: _MetricTone.info,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ResponsiveGrid(
          minItemWidth: 280,
          children: reports
              .where((item) => _tipo == 'Todos' || item.category == _tipo)
              .map(
                (report) => _ReportCard(
                  report: report,
                  onOpen: () => _notify(context, 'Abrindo ${report.title}.'),
                  onExport: () => _notify(context, 'Exportação preparada.'),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class SigadConfiguracoesPage extends StatefulWidget {
  const SigadConfiguracoesPage({super.key});

  @override
  State<SigadConfiguracoesPage> createState() => _SigadConfiguracoesPageState();
}

class _SigadConfiguracoesPageState extends State<SigadConfiguracoesPage> {
  bool _notifications = true;
  bool _email = true;
  bool _compact = false;
  bool _biometrics = false;

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      header: _PageHeader(
        eyebrow: 'PREFERÊNCIAS',
        title: 'Configurações',
        subtitle: 'Conta, notificações, aparência, segurança e dados.',
        actions: [
          _HeaderAction(
            icon: Icons.save_outlined,
            label: 'Salvar',
            onPressed: () => _notify(context, 'Configurações salvas.'),
          ),
        ],
      ),
      children: [
        _ResponsiveSplit(
          primary: _SectionCard(
            title: 'Perfil e conta',
            subtitle: 'Dados da sessão atual',
            icon: Icons.manage_accounts_outlined,
            child: Column(
              children: [
                const _SettingInfoTile(
                  icon: Icons.person_outline,
                  title: 'Nome de exibição',
                  value: 'Usuário institucional',
                ),
                const _SettingInfoTile(
                  icon: Icons.alternate_email,
                  title: 'E-mail',
                  value: 'Conta institucional',
                ),
                const _SettingInfoTile(
                  icon: Icons.badge_outlined,
                  title: 'Perfil de acesso',
                  value: 'Definido pela autenticação',
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _showActionDialog(
                      context,
                      title: 'Editar perfil',
                      message: 'Atualize dados pessoais e preferências.',
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar perfil'),
                  ),
                ),
              ],
            ),
          ),
          secondary: _SectionCard(
            title: 'Notificações',
            subtitle: 'Canais e alertas',
            icon: Icons.notifications_outlined,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _notifications,
                  onChanged: (value) => setState(() => _notifications = value),
                  title: const Text('Notificações no aplicativo'),
                  subtitle: const Text('Alertas, convites e prazos'),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _email,
                  onChanged: (value) => setState(() => _email = value),
                  title: const Text('Notificações por e-mail'),
                  subtitle: const Text('Resumo e comunicações importantes'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ResponsiveSplit(
          primary: _SectionCard(
            title: 'Aparência',
            subtitle: 'Densidade e visualização',
            icon: Icons.palette_outlined,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _compact,
                  onChanged: (value) => setState(() => _compact = value),
                  title: const Text('Modo compacto'),
                  subtitle: const Text('Exibe mais informações por tela'),
                ),
                const _SettingInfoTile(
                  icon: Icons.contrast_outlined,
                  title: 'Tema',
                  value: 'Segue a configuração do aplicativo',
                ),
              ],
            ),
          ),
          secondary: _SectionCard(
            title: 'Segurança e dados',
            subtitle: 'Sessão, acesso e armazenamento',
            icon: Icons.security_outlined,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _biometrics,
                  onChanged: (value) => setState(() => _biometrics = value),
                  title: const Text('Biometria'),
                  subtitle: const Text('Usar autenticação do dispositivo'),
                ),
                const _SettingInfoTile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Sincronização',
                  value: 'Automática quando disponível',
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _showActionDialog(
                      context,
                      title: 'Limpar dados locais',
                      message:
                          'Esta ação remove apenas caches e preferências locais.',
                    ),
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: const Text('Limpar dados locais'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({required this.header, required this.children});

  final Widget header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _AmbientBackground(),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width >= 1024 ? 24 : 16,
            18,
            MediaQuery.sizeOf(context).width >= 1024 ? 24 : 16,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header, const SizedBox(height: 18), ...children],
          ),
        ),
      ],
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -100,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<_HeaderAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          );

          final actionWidgets = actions
              .map(
                (action) => FilledButton.tonalIcon(
                  onPressed: action.onPressed,
                  icon: Icon(action.icon),
                  label: Text(action.label),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                  ),
                ),
              )
              .toList();

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text,
                if (actionWidgets.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(spacing: 10, runSpacing: 10, children: actionWidgets),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: text),
              const SizedBox(width: 18),
              Wrap(spacing: 10, runSpacing: 10, children: actionWidgets),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderAction {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.showHeader = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.minItemWidth, required this.children});

  final double minItemWidth;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / minItemWidth).floor().clamp(1, 4);
        final width = (constraints.maxWidth - (count - 1) * 12) / count;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}

class _ResponsiveSplit extends StatelessWidget {
  const _ResponsiveSplit({required this.primary, required this.secondary});

  final Widget primary;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Column(
            children: [primary, const SizedBox(height: 16), secondary],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: primary),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: secondary),
          ],
        );
      },
    );
  }
}

enum _MetricTone { primary, success, warning, risk, info }

Color _toneColor(_MetricTone tone) {
  switch (tone) {
    case _MetricTone.primary:
      return SigadColors.brand;
    case _MetricTone.success:
      return SigadColors.success;
    case _MetricTone.warning:
      return SigadColors.warning;
    case _MetricTone.risk:
      return SigadColors.risk;
    case _MetricTone.info:
      return SigadColors.info;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final _MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final color = _toneColor(tone);
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final color = _toneColor(tone);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FilterToolbar extends StatelessWidget {
  const _FilterToolbar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 680) {
            return Column(
              children: children.map((child) {
                final effectiveChild = child is Expanded ? child.child : child;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: effectiveChild,
                  ),
                );
              }).toList(),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _Conversation {
  const _Conversation({
    required this.name,
    required this.message,
    required this.time,
    this.unread = 0,
    this.group = false,
  });

  final String name;
  final String message;
  final String time;
  final int unread;
  final bool group;
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.query,
    required this.conversations,
    required this.selectedIndex,
    required this.onQueryChanged,
    required this.onSelected,
  });

  final String query;
  final List<_Conversation> conversations;
  final int selectedIndex;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Buscar conversa',
              prefixIcon: Icon(Icons.search_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: conversations.isEmpty
                ? const Center(child: Text('Nenhuma conversa encontrada.'))
                : ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = conversations[index];
                      final selected = index == selectedIndex;
                      return ListTile(
                        selected: selected,
                        selectedTileColor: colors.primaryContainer.withValues(
                          alpha: 0.55,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: selected
                              ? colors.primary
                              : colors.surfaceContainerHigh,
                          foregroundColor: selected
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                          child: Icon(
                            item.group
                                ? Icons.groups_2_outlined
                                : Icons.person_outline,
                          ),
                        ),
                        title: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.time,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            if (item.unread > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${item.unread}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: colors.onPrimary),
                                ),
                              ),
                          ],
                        ),
                        onTap: () => onSelected(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.conversation,
    required this.controller,
    required this.onSend,
  });

  final _Conversation? conversation;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: conversation == null
          ? const Center(child: Text('Selecione uma conversa.'))
          : Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      conversation!.group
                          ? Icons.groups_2_outlined
                          : Icons.person_outline,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  title: Text(conversation!.name),
                  subtitle: const Text('Disponível'),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search_outlined),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: const [
                      _MessageBubble(
                        text: 'Bom dia! A pauta da reunião foi atualizada.',
                        mine: false,
                        time: '10:38',
                      ),
                      _MessageBubble(
                        text:
                            'Recebido. Vou revisar os itens antes do encontro.',
                        mine: true,
                        time: '10:40',
                      ),
                      _MessageBubble(
                        text: 'O arquivo está fixado na conversa.',
                        mine: false,
                        time: '10:42',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.attach_file_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onSubmitted: (_) => onSend(),
                          decoration: const InputDecoration(
                            hintText: 'Escrever mensagem',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: onSend,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.mine,
    required this.time,
  });

  final String text;
  final bool mine;
  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mine ? colors.primaryContainer : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text),
            const SizedBox(height: 4),
            Text(time, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _WorkloadRow extends StatelessWidget {
  const _WorkloadRow({
    required this.name,
    required this.initials,
    required this.teaching,
    required this.other,
    required this.maximum,
    required this.status,
    required this.tone,
  });

  final String name;
  final String initials;
  final int teaching;
  final int other;
  final int maximum;
  final String status;
  final _MetricTone tone;

  @override
  Widget build(BuildContext context) {
    final total = teaching + other;
    final progress = (total / maximum).clamp(0.0, 1.2);
    final color = _toneColor(tone);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final info = Row(
            children: [
              CircleAvatar(child: Text(initials)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      'Ensino: ${teaching}h · Outras atividades: ${other}h',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          );
          final meter = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusPill(label: status, color: color),
              const SizedBox(height: 8),
              SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text('$total h de $maximum h'),
            ],
          );
          if (compact) {
            return Column(
              children: [
                info,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: meter),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: info),
              meter,
            ],
          );
        },
      ),
    );
  }
}

class _TeacherData {
  const _TeacherData(
    this.name,
    this.area,
    this.load,
    this.status,
    this.initials,
  );

  final String name;
  final String area;
  final String load;
  final String status;
  final String initials;
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({required this.teacher, required this.onTap});

  final _TeacherData teacher;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = teacher.status == 'Ativo';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    teacher.initials,
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                _StatusPill(
                  label: teacher.status,
                  color: active ? SigadColors.success : SigadColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(teacher.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(teacher.area),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 18),
                const SizedBox(width: 6),
                Text('Carga atual: ${teacher.load}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DemandData {
  const _DemandData({
    required this.id,
    required this.title,
    required this.owner,
    required this.deadline,
    required this.status,
    required this.priority,
  });

  final String id;
  final String title;
  final String owner;
  final String deadline;
  final String status;
  final String priority;
}

class _DemandTile extends StatelessWidget {
  const _DemandTile({required this.item, required this.onTap});

  final _DemandData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = item.status == 'Atrasada'
        ? SigadColors.risk
        : item.priority == 'Alta'
        ? SigadColors.warning
        : SigadColors.info;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.assignment_outlined, color: color),
      ),
      title: Text(item.title),
      subtitle: Text('${item.id} · ${item.owner} · Prazo ${item.deadline}'),
      trailing: _StatusPill(label: item.status, color: color),
      onTap: onTap,
    );
  }
}

class _TaskData {
  const _TaskData(this.title, this.area, this.priority);

  final String title;
  final String area;
  final String priority;
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.title,
    required this.items,
    required this.onAdd,
  });

  final String title;
  final List<_TaskData> items;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _StatusPill(label: '${items.length}', color: colors.primary),
              IconButton(onPressed: onAdd, icon: const Icon(Icons.add_rounded)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final color = item.priority == 'Alta'
                    ? SigadColors.risk
                    : item.priority == 'Média'
                    ? SigadColors.warning
                    : SigadColors.info;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text(item.area)),
                          _StatusPill(label: item.priority, color: color),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LabSchedule extends StatelessWidget {
  const _LabSchedule();

  @override
  Widget build(BuildContext context) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
    const slots = ['M1–M2', 'M3–M4', 'T1–T2', 'T3–T4', 'N1–N2'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Período')),
          ...days.map((day) => DataColumn(label: Text(day))),
        ],
        rows: slots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          return DataRow(
            cells: [
              DataCell(Text(slot)),
              ...days.asMap().entries.map((day) {
                final occupied = (index + day.key) % 3 != 0;
                return DataCell(
                  _StatusPill(
                    label: occupied ? 'Reservado' : 'Livre',
                    color: occupied ? SigadColors.brand : SigadColors.success,
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MonthOverview extends StatelessWidget {
  const _MonthOverview();

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minItemWidth: 130,
      children: List.generate(28, (index) {
        final day = index + 1;
        final occupied = day % 4 != 0;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: occupied
                ? SigadColors.brandLight
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text('$day', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(occupied ? 'Com reservas' : 'Disponível'),
            ],
          ),
        );
      }),
    );
  }
}

class _LabOccupancy extends StatelessWidget {
  const _LabOccupancy();

  @override
  Widget build(BuildContext context) {
    const values = [
      ('Laboratório 1', 0.82),
      ('Laboratório 2', 0.64),
      ('Laboratório 3', 0.48),
      ('Laboratório 6', 0.73),
    ];
    return Column(
      children: values
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.$1)),
                      Text('${(item.$2 * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: item.$2,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ActivityData {
  const _ActivityData(this.title, this.category, this.deadline, this.status);

  final String title;
  final String category;
  final String deadline;
  final String status;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.onTap});

  final _ActivityData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = item.status == 'Concluída'
        ? SigadColors.success
        : item.status == 'Em progresso'
        ? SigadColors.info
        : SigadColors.warning;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: Checkbox(value: item.status == 'Concluída', onChanged: (_) {}),
      title: Text(item.title),
      subtitle: Text('${item.category} · Prazo ${item.deadline}'),
      trailing: _StatusPill(label: item.status, color: color),
      onTap: onTap,
    );
  }
}

class _ReportData {
  const _ReportData(this.title, this.category, this.updated, this.icon);

  final String title;
  final String category;
  final String updated;
  final IconData icon;
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onOpen,
    required this.onExport,
  });

  final _ReportData report;
  final VoidCallback onOpen;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(report.icon, color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: 14),
          Text(report.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('${report.category} · ${report.updated}'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpen,
                  child: const Text('Visualizar'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onExport,
                icon: const Icon(Icons.download_outlined),
                tooltip: 'Exportar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingInfoTile extends StatelessWidget {
  const _SettingInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _showActionDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            _notify(context, 'Ação registrada.');
          },
          child: const Text('Continuar'),
        ),
      ],
    ),
  );
}
