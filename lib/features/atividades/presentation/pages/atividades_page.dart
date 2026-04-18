import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/local_storage_service.dart';

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key});

  @override
  State<AtividadesPage> createState() => _AtividadesPageState();
}

class _AtividadesPageState extends State<AtividadesPage> {
  String _busca = '';
  String _filtro = 'Todas';
  static const String _kKey = 'sigad_atividades';
  static const List<String> _statusAtividade = [
    'Concluída',
    'Em progresso',
    'Agendada',
    'Pendente',
  ];
  static const List<String> _responsaveis = [
    'Coordenação',
    'Gestão',
    'TI',
    'RH',
    'Auditoria',
    'Comunicação',
  ];

  final List<_Atividade> _atividades = [
    _Atividade(
      id: '#ATv-001',
      titulo: 'Entrega de levantamento de demandas',
      descricao: 'Documento consolidado com todas as solicitações do período',
      data: '15/04/2026 - 10:30',
      responsavel: 'Coordenação',
      status: 'Concluída',
      statusColor: SigadColors.success,
    ),
    _Atividade(
      id: '#ATv-002',
      titulo: 'Reunião de validação de requisitos',
      descricao: 'Apresentação dos requisitos para stakeholders',
      data: '18/04/2026 - 14:00',
      responsavel: 'Gestão',
      status: 'Concluída',
      statusColor: SigadColors.success,
    ),
    _Atividade(
      id: '#ATv-003',
      titulo: 'Implementação de sistema de priorização',
      descricao: 'Desenvolvimento da matriz de priorização',
      data: '22/04/2026 - 09:00',
      responsavel: 'TI',
      status: 'Em progresso',
      statusColor: SigadColors.info,
    ),
    _Atividade(
      id: '#ATv-004',
      titulo: 'Treinamento de usuários',
      descricao: 'Capacitação de 150 usuários no novo sistema',
      data: '28/04/2026 - 08:00',
      responsavel: 'RH',
      status: 'Agendada',
      statusColor: SigadColors.warning,
    ),
    _Atividade(
      id: '#ATv-005',
      titulo: 'Auditoria de conformidade',
      descricao: 'Verificação de conformidade com normas ISO',
      data: '05/05/2026 - 13:00',
      responsavel: 'Auditoria',
      status: 'Agendada',
      statusColor: SigadColors.warning,
    ),
    _Atividade(
      id: '#ATv-006',
      titulo: 'Publicação de resultados',
      descricao: 'Divulgação dos resultados para a comunidade acadêmica',
      data: '10/05/2026',
      responsavel: 'Comunicação',
      status: 'Pendente',
      statusColor: SigadColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await LocalStorageService.loadList(_kKey);
    if (list.isEmpty) return;
    setState(() {
      _atividades
        ..clear()
        ..addAll(list.map(_atividadeFromJson));
    });
  }

  void _saveData() {
    LocalStorageService.saveList(_kKey, _atividades.map(_atividadeToJson).toList());
  }

  Map<String, dynamic> _atividadeToJson(_Atividade a) => {
    'id': a.id,
    'titulo': a.titulo,
    'descricao': a.descricao,
    'data': a.data,
    'responsavel': a.responsavel,
    'status': a.status,
  };

  _Atividade _atividadeFromJson(Map<String, dynamic> json) => _Atividade(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    descricao: json['descricao'] as String,
    data: json['data'] as String,
    responsavel: json['responsavel'] as String,
    status: json['status'] as String,
    statusColor: _corStatus(json['status'] as String),
  );

  List<_Atividade> get _atividadesFiltradas {
    return _atividades.where((a) {
      final filtroMatch = _filtro == 'Todas' || a.status == _filtro;
      final busca = _busca.trim().toLowerCase();
      final buscaMatch = busca.isEmpty ||
          a.titulo.toLowerCase().contains(busca) ||
          a.descricao.toLowerCase().contains(busca) ||
          a.responsavel.toLowerCase().contains(busca);
      return filtroMatch && buscaMatch;
    }).toList();
  }

  int get _atividadesConcluidas => _atividades.where((a) => a.status == 'Concluída').length;

  int get _atividadesPendentes => _atividades.where((a) => a.status == 'Pendente').length;

  Color _corStatus(String status) {
    switch (status) {
      case 'Concluída':
        return SigadColors.success;
      case 'Em progresso':
        return SigadColors.info;
      case 'Agendada':
        return SigadColors.warning;
      case 'Pendente':
        return SigadColors.accent;
      default:
        return SigadColors.muted;
    }
  }

  String _gerarProximoIdAtividade() {
    var maiorId = 0;

    for (final atividade in _atividades) {
      final numero = int.tryParse(atividade.id.replaceAll(RegExp(r'[^0-9]'), ''));
      if (numero != null && numero > maiorId) {
        maiorId = numero;
      }
    }

    final proximoId = maiorId + 1;
    return '#ATV-${proximoId.toString().padLeft(3, '0')}';
  }

  String _dataPadraoNovaAtividade() {
    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year.toString();
    final hora = agora.hour.toString().padLeft(2, '0');
    final minuto = agora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano - $hora:$minuto';
  }

  String? _validarAtividade({
    required String titulo,
    required String descricao,
  }) {
    if (titulo.trim().isEmpty) {
      return 'Informe o título da atividade';
    }

    if (descricao.trim().isEmpty) {
      return 'Informe a descrição da atividade';
    }

    return null;
  }

  void _mostrarFeedback(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AtividadesSummaryBanner(
                  totalAtividades: _atividades.length,
                  atividadesConcluidas: _atividadesConcluidas,
                  atividadesPendentes: _atividadesPendentes,
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => setState(() => _busca = value),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por título, descrição ou responsável',
                    prefixIcon: Icon(Icons.search_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Todas',
                      'Concluída',
                      'Em progresso',
                      'Agendada',
                      'Pendente'
                    ]
                        .map((status) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(status),
                                selected: _filtro == status,
                                onSelected: (selected) {
                                  setState(() => _filtro = selected ? status : 'Todas');
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _atividadesFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 64,
                          color: SigadColors.muted.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma atividade encontrada',
                          style: textTheme.bodyLarge?.copyWith(color: SigadColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _atividadesFiltradas.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _AtividadeCard(
                      atividade: _atividadesFiltradas[index],
                      onEditar: () => _showEditarAtividade(context, _atividadesFiltradas[index]),
                      onExcluir: () => _showConfirmarExclusao(context, _atividadesFiltradas[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCriarAtividade(context),
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCriarAtividade(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    String responsavelSelecionado = 'Coordenação';
    String statusSelecionado = 'Pendente';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nova Atividade', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título da atividade',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva a atividade em detalhes',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: responsavelSelecionado,
                decoration: const InputDecoration(labelText: 'Responsável'),
                items: _responsaveis
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) => setModalState(() => responsavelSelecionado = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: statusSelecionado,
                decoration: const InputDecoration(labelText: 'Status inicial'),
                items: _statusAtividade
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setModalState(() => statusSelecionado = value!),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final erro = _validarAtividade(
                          titulo: tituloController.text,
                          descricao: descricaoController.text,
                        );

                        if (erro != null) {
                          _mostrarFeedback(erro);
                          return;
                        }

                        setState(() {
                          _atividades.insert(
                            0,
                            _Atividade(
                              id: _gerarProximoIdAtividade(),
                              titulo: tituloController.text.trim(),
                              descricao: descricaoController.text.trim(),
                              data: _dataPadraoNovaAtividade(),
                              responsavel: responsavelSelecionado,
                              status: statusSelecionado,
                              statusColor: _corStatus(statusSelecionado),
                            ),
                          );
                        });
                        _saveData();

                        Navigator.pop(context);
                        _mostrarFeedback('Atividade criada com sucesso!');
                      },
                      child: const Text('Criar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditarAtividade(BuildContext context, _Atividade atividade) {
    final textTheme = Theme.of(context).textTheme;
    final tituloController = TextEditingController(text: atividade.titulo);
    final descricaoController = TextEditingController(text: atividade.descricao);
    String responsavelSelecionado = atividade.responsavel;
    String statusSelecionado = atividade.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Editar Atividade', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título da atividade',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva a atividade em detalhes',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: responsavelSelecionado,
                decoration: const InputDecoration(labelText: 'Responsável'),
                items: _responsaveis
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (value) => setModalState(() => responsavelSelecionado = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: statusSelecionado,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statusAtividade
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setModalState(() => statusSelecionado = value!),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final erro = _validarAtividade(
                          titulo: tituloController.text,
                          descricao: descricaoController.text,
                        );

                        if (erro != null) {
                          _mostrarFeedback(erro);
                          return;
                        }

                        setState(() {
                          final index = _atividades.indexWhere((item) => item.id == atividade.id);
                          if (index >= 0) {
                            _atividades[index] = atividade.copyWith(
                              titulo: tituloController.text.trim(),
                              descricao: descricaoController.text.trim(),
                              responsavel: responsavelSelecionado,
                              status: statusSelecionado,
                              statusColor: _corStatus(statusSelecionado),
                            );
                          }
                        });
                        _saveData();

                        Navigator.pop(context);
                        _mostrarFeedback('Atividade atualizada com sucesso!');
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmarExclusao(BuildContext context, _Atividade atividade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir ${atividade.titulo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _atividades.removeWhere((item) => item.id == atividade.id);
              });
              _saveData();
              Navigator.pop(context);
              _mostrarFeedback('Atividade excluída com sucesso!');
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AtividadesSummaryBanner extends StatelessWidget {
  const _AtividadesSummaryBanner({
    required this.totalAtividades,
    required this.atividadesConcluidas,
    required this.atividadesPendentes,
  });

  final int totalAtividades;
  final int atividadesConcluidas;
  final int atividadesPendentes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agenda operacional',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _AtividadesKpi(label: 'No total', value: '$totalAtividades'),
              const SizedBox(width: 8),
              _AtividadesKpi(label: 'Concluídas', value: '$atividadesConcluidas'),
              const SizedBox(width: 8),
              _AtividadesKpi(label: 'Pendentes', value: '$atividadesPendentes'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AtividadesKpi extends StatelessWidget {
  const _AtividadesKpi({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SigadColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _AtividadeCard extends StatelessWidget {
  const _AtividadeCard({
    required this.atividade,
    required this.onEditar,
    required this.onExcluir,
  });

  final _Atividade atividade;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _showDetalhes(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SigadColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SigadColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: atividade.statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atividade.id,
                        style: textTheme.labelSmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        atividade.titulo,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: atividade.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    atividade.status,
                    style: textTheme.labelSmall?.copyWith(
                      color: atividade.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _onMenuItemSelected(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              atividade.descricao,
              style: textTheme.bodySmall?.copyWith(
                color: SigadColors.muted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: Icons.person_outline,
                  label: atividade.responsavel,
                ),
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: atividade.data,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'editar':
        onEditar();
        break;
      case 'excluir':
        onExcluir();
        break;
    }
  }

  void _showDetalhes(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(atividade.id, style: textTheme.labelSmall?.copyWith(color: SigadColors.muted)),
                      const SizedBox(height: 8),
                      Text(atividade.titulo, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(
                label: 'Descrição',
                value: atividade.descricao,
              ),
              _DetailSection(
                label: 'Responsável',
                value: atividade.responsavel,
              ),
              _DetailSection(
                label: 'Data',
                value: atividade.data,
              ),
              _DetailSection(
                label: 'Status',
                value: atividade.status,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onEditar();
                      },
                      child: const Text('Editar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: SigadColors.muted),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: SigadColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Atividade {
  const _Atividade({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.responsavel,
    required this.status,
    required this.statusColor,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String data;
  final String responsavel;
  final String status;
  final Color statusColor;

  _Atividade copyWith({
    String? titulo,
    String? descricao,
    String? data,
    String? responsavel,
    String? status,
    Color? statusColor,
  }) {
    return _Atividade(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      responsavel: responsavel ?? this.responsavel,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}
