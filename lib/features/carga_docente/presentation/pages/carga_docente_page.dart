import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/user_context_provider.dart';

class CargaDocentePage extends StatefulWidget {
  const CargaDocentePage({super.key});

  @override
  State<CargaDocentePage> createState() => _CargaDocentePageState();
}

class _CargaDocentePageState extends State<CargaDocentePage> {
  static const Set<UserRole> _allowedRoles = {
    UserRole.professor,
    UserRole.coordenador,
    UserRole.chefeDepartamento,
  };

  String _filtro = 'Todos';
  static const String _kKey = 'sigad_docentes';
  static const List<String> _statusDisponibilidade = [
    'Disponível',
    'Parcialmente',
    'Indisponível',
  ];

  final List<_Docente> _docentes = [
    _Docente(
      id: '#DOC-001',
      nome: 'Profa. Dra. Maria Silva',
      userEmail: 'maria.santos@univ.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 20,
      cargaMaxima: 20,
      disciplinas: ['Programação I', 'Programação II', 'Engenharia de Software'],
      disponibilidade: 'Indisponível',
      toneDisponibilidade: SigadColors.risk,
    ),
    _Docente(
      id: '#DOC-002',
      nome: 'Prof. Dr. João Silva',
      userEmail: 'joao.silva@univ.br',
      departamento: 'Sistemas de Informação',
      cargaHoraria: 16,
      cargaMaxima: 20,
      disciplinas: ['Banco de Dados', 'Web Design'],
      disponibilidade: 'Disponível',
      toneDisponibilidade: SigadColors.success,
    ),
    _Docente(
      id: '#DOC-003',
      nome: 'Profa. Ana Costa',
      userEmail: 'ana.pereira@univ.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 12,
      cargaMaxima: 20,
      disciplinas: ['Computação Gráfica'],
      disponibilidade: 'Disponível',
      toneDisponibilidade: SigadColors.success,
    ),
    _Docente(
      id: '#DOC-004',
      nome: 'Prof. Carlos Oliveira',
      userEmail: 'carlos.oliveira@univ.br',
      departamento: 'Redes e Telecomunicações',
      cargaHoraria: 18,
      cargaMaxima: 20,
      disciplinas: ['Redes I', 'Redes II', 'Segurança de Redes'],
      disponibilidade: 'Parcialmente',
      toneDisponibilidade: SigadColors.warning,
    ),
    _Docente(
      id: '#DOC-005',
      nome: 'Profa. Beatriz Mendes',
      userEmail: 'beatriz.mendes@univ.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 14,
      cargaMaxima: 20,
      disciplinas: ['Qualidade de Software'],
      disponibilidade: 'Disponível',
      toneDisponibilidade: SigadColors.success,
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
      _docentes
        ..clear()
        ..addAll(list.map(_docenteFromJson));
    });
  }

  void _saveData() {
    LocalStorageService.saveList(_kKey, _docentes.map(_docenteToJson).toList());
  }

  Map<String, dynamic> _docenteToJson(_Docente d) => {
    'id': d.id,
    'nome': d.nome,
    if (d.userEmail != null) 'userEmail': d.userEmail,
    'departamento': d.departamento,
    'cargaHoraria': d.cargaHoraria,
    'cargaMaxima': d.cargaMaxima,
    'disciplinas': d.disciplinas,
    'disponibilidade': d.disponibilidade,
  };

  _Docente _docenteFromJson(Map<String, dynamic> json) => _Docente(
    id: json['id'] as String,
    nome: json['nome'] as String,
    userEmail: json['userEmail'] as String?,
    departamento: json['departamento'] as String,
    cargaHoraria: json['cargaHoraria'] as int,
    cargaMaxima: json['cargaMaxima'] as int,
    disciplinas: List<String>.from(json['disciplinas'] as List),
    disponibilidade: json['disponibilidade'] as String,
    toneDisponibilidade: _toneDisponibilidade(json['disponibilidade'] as String),
  );

  List<_Docente> get _docentesFiltrados {
    if (_filtro == 'Todos') return _docentes;
    return _docentes.where((d) => d.disponibilidade == _filtro).toList();
  }

  List<_Docente> _docentesVisiveis(UserRole role, {String? emailUsuario}) {
    if (role == UserRole.professor) {
      final emailNormalizado = (emailUsuario ?? '').trim().toLowerCase();
      return _docentes
          .where((docente) => (docente.userEmail ?? '').trim().toLowerCase() == emailNormalizado)
          .toList();
    }

    if (_filtro == 'Todos') return _docentes;
    return _docentes.where((d) => d.disponibilidade == _filtro).toList();
  }

  Color _toneDisponibilidade(String disponibilidade) {
    switch (disponibilidade) {
      case 'Disponível':
        return SigadColors.success;
      case 'Parcialmente':
        return SigadColors.warning;
      case 'Indisponível':
        return SigadColors.risk;
      default:
        return SigadColors.muted;
    }
  }

  String _gerarProximoIdDocente() {
    var maiorId = 0;

    for (final docente in _docentes) {
      final numero = int.tryParse(docente.id.replaceAll(RegExp(r'[^0-9]'), ''));
      if (numero != null && numero > maiorId) {
        maiorId = numero;
      }
    }

    final proximoId = maiorId + 1;
    return '#DOC-${proximoId.toString().padLeft(3, '0')}';
  }

  String? _validarDocente({
    required String nome,
    required String departamento,
    required String cargaMaxima,
    required List<String> disciplinas,
  }) {
    if (nome.trim().isEmpty) {
      return 'Informe o nome do docente';
    }

    if (departamento.trim().isEmpty) {
      return 'Informe o departamento';
    }

    final carga = int.tryParse(cargaMaxima.trim());
    if (carga == null || carga <= 0) {
      return 'Informe uma carga horária máxima válida';
    }

    if (disciplinas.isEmpty) {
      return 'Adicione pelo menos uma disciplina';
    }

    return null;
  }

  void _mostrarFeedback(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _showAdicionarDocente(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final departamentoController = TextEditingController();
    final cargaMaximaController = TextEditingController();
    String disponibilidadeSelecionada = 'Disponível';
    final List<String> disciplinas = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Novo Docente', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Digite o nome do docente',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email de acesso',
                  hintText: 'docente@univ.br',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departamentoController,
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  hintText: 'Digite o departamento',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cargaMaximaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carga Horária Máxima (horas)',
                  hintText: 'Ex: 20',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: disponibilidadeSelecionada,
                decoration: const InputDecoration(labelText: 'Disponibilidade'),
                items: _statusDisponibilidade
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setModalState(() => disponibilidadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              Text(
                'Disciplinas',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...disciplinas.map((d) => Chip(
                        label: Text(d),
                        onDeleted: () => setModalState(() => disciplinas.remove(d)),
                      )),
                  ActionChip(
                    label: const Text('Adicionar'),
                    onPressed: () => _showAdicionarDisciplina(context, disciplinas, setModalState),
                  ),
                ],
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
                        final erro = _validarDocente(
                          nome: nomeController.text,
                          departamento: departamentoController.text,
                          cargaMaxima: cargaMaximaController.text,
                          disciplinas: disciplinas,
                        );

                        if (erro != null) {
                          _mostrarFeedback(erro);
                          return;
                        }

                        final cargaMaxima = int.parse(cargaMaximaController.text.trim());

                        setState(() {
                          _docentes.insert(
                            0,
                            _Docente(
                              id: _gerarProximoIdDocente(),
                              nome: nomeController.text.trim(),
                              userEmail: emailController.text.trim().isEmpty ? null : emailController.text.trim().toLowerCase(),
                              departamento: departamentoController.text.trim(),
                              cargaHoraria: 0,
                              cargaMaxima: cargaMaxima,
                              disciplinas: List<String>.from(disciplinas),
                              disponibilidade: disponibilidadeSelecionada,
                              toneDisponibilidade: _toneDisponibilidade(disponibilidadeSelecionada),
                            ),
                          );
                        });
                        _saveData();

                        Navigator.pop(context);
                        _mostrarFeedback('Docente adicionado com sucesso!');
                      },
                      child: const Text('Adicionar'),
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

  void _showAdicionarDisciplina(BuildContext context, List<String> disciplinas, StateSetter setState) {
    final disciplinaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Disciplina'),
        content: TextField(
          controller: disciplinaController,
          decoration: const InputDecoration(
            labelText: 'Nome da Disciplina',
            hintText: 'Ex: Programação I',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final disciplina = disciplinaController.text.trim();
              if (disciplina.isNotEmpty && !disciplinas.contains(disciplina)) {
                setState(() => disciplinas.add(disciplina));
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showEditarDocente(BuildContext context, _Docente docente) {
    final textTheme = Theme.of(context).textTheme;
    final nomeController = TextEditingController(text: docente.nome);
    final emailController = TextEditingController(text: docente.userEmail ?? '');
    final departamentoController = TextEditingController(text: docente.departamento);
    final cargaMaximaController = TextEditingController(text: docente.cargaMaxima.toString());
    String disponibilidadeSelecionada = docente.disponibilidade;
    final List<String> disciplinas = List<String>.from(docente.disciplinas);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Editar Docente', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Digite o nome do docente',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email de acesso',
                  hintText: 'docente@univ.br',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departamentoController,
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  hintText: 'Digite o departamento',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cargaMaximaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carga Horária Máxima (horas)',
                  hintText: 'Ex: 20',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: disponibilidadeSelecionada,
                decoration: const InputDecoration(labelText: 'Disponibilidade'),
                items: _statusDisponibilidade
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setModalState(() => disponibilidadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              Text(
                'Disciplinas',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...disciplinas.map((d) => Chip(
                        label: Text(d),
                        onDeleted: () => setModalState(() => disciplinas.remove(d)),
                      )),
                  ActionChip(
                    label: const Text('Adicionar'),
                    onPressed: () => _showAdicionarDisciplina(context, disciplinas, setModalState),
                  ),
                ],
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
                        final erro = _validarDocente(
                          nome: nomeController.text,
                          departamento: departamentoController.text,
                          cargaMaxima: cargaMaximaController.text,
                          disciplinas: disciplinas,
                        );

                        if (erro != null) {
                          _mostrarFeedback(erro);
                          return;
                        }

                        final cargaMaxima = int.parse(cargaMaximaController.text.trim());

                        setState(() {
                          final index = _docentes.indexWhere((item) => item.id == docente.id);
                          if (index >= 0) {
                            _docentes[index] = docente.copyWith(
                              nome: nomeController.text.trim(),
                              userEmail: emailController.text.trim().isEmpty ? null : emailController.text.trim().toLowerCase(),
                              departamento: departamentoController.text.trim(),
                              cargaMaxima: cargaMaxima,
                              disciplinas: List<String>.from(disciplinas),
                              disponibilidade: disponibilidadeSelecionada,
                              toneDisponibilidade: _toneDisponibilidade(disponibilidadeSelecionada),
                            );
                          }
                        });
                        _saveData();

                        Navigator.pop(context);
                        _mostrarFeedback('Docente atualizado com sucesso!');
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

  void _showConfirmarExclusao(BuildContext context, _Docente docente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir ${docente.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _docentes.removeWhere((item) => item.id == docente.id);
              });
              _saveData();
              Navigator.pop(context);
              _mostrarFeedback('Docente excluído com sucesso!');
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final user = userContext.currentUser;
    final hasAccess = role != null && _allowedRoles.contains(role);

    if (!hasAccess) {
      return const _AccessDenied();
    }

    final podeGerenciar = role == UserRole.coordenador || role == UserRole.chefeDepartamento;
    final docentesVisiveis = _docentesVisiveis(
      role,
      emailUsuario: user?.email,
    );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários dos Docentes'),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (podeGerenciar)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'Todos',
                    'Disponível',
                    'Parcialmente',
                    'Indisponível'
                  ]
                      .map((status) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(status),
                              selected: _filtro == status,
                              onSelected: (selected) {
                                setState(() => _filtro = selected ? status : 'Todos');
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          if (!podeGerenciar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SigadColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SigadColors.divider),
                ),
                child: Text(
                  'Você tem acesso somente ao seu próprio horário docente.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: SigadColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Expanded(
            child: docentesVisiveis.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: SigadColors.muted.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          podeGerenciar ? 'Nenhum docente encontrado' : 'Seu horário docente não foi encontrado',
                          style: textTheme.bodyLarge?.copyWith(color: SigadColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: docentesVisiveis.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _DocenteCard(
                      docente: docentesVisiveis[index],
                      canManage: podeGerenciar,
                      onEditar: () => _showEditarDocente(context, docentesVisiveis[index]),
                      onExcluir: () => _showConfirmarExclusao(context, docentesVisiveis[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: podeGerenciar
          ? FloatingActionButton(
              onPressed: () => _showAdicionarDocente(context),
              backgroundColor: SigadColors.brand,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _DocenteCard extends StatelessWidget {
  const _DocenteCard({
    required this.docente,
    required this.canManage,
    required this.onEditar,
    required this.onExcluir,
  });

  final _Docente docente;
  final bool canManage;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percentualCarga = (docente.cargaHoraria / docente.cargaMaxima * 100).toInt();

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SigadColors.brand,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      docente.nome.split(' ').map((e) => e[0]).join('').substring(0, 2),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docente.nome,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        docente.departamento,
                        style: textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: docente.toneDisponibilidade.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    docente.disponibilidade,
                    style: textTheme.labelSmall?.copyWith(
                      color: docente.toneDisponibilidade,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canManage)
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
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: docente.cargaHoraria / docente.cargaMaxima,
                minHeight: 8,
                backgroundColor: SigadColors.muted.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentualCarga >= 100 ? SigadColors.risk : SigadColors.success,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${docente.cargaHoraria}h / ${docente.cargaMaxima}h',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percentualCarga%',
                  style: textTheme.labelSmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: docente.disciplinas
                  .map((d) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: SigadColors.brand.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          d,
                          style: textTheme.labelSmall?.copyWith(
                            color: SigadColors.brand,
                          ),
                        ),
                      ))
                  .toList(),
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
    final percentualCarga = (docente.cargaHoraria / docente.cargaMaxima * 100).toInt();

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
                      Text(docente.id, style: textTheme.labelSmall?.copyWith(color: SigadColors.muted)),
                      const SizedBox(height: 8),
                      Text(docente.nome, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(label: 'Departamento', value: docente.departamento),
              if (docente.userEmail != null) _DetailSection(label: 'Email vinculado', value: docente.userEmail!),
              _DetailSection(label: 'Carga Horária', value: '${docente.cargaHoraria}h / ${docente.cargaMaxima}h ($percentualCarga%)'),
              _DetailSection(label: 'Disponibilidade', value: docente.disponibilidade),
              const SizedBox(height: 16),
              Text(
                'Disciplinas',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: docente.disciplinas
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: SigadColors.success),
                              const SizedBox(width: 8),
                              Text(d, style: textTheme.bodySmall),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 56,
              color: SigadColors.muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Acesso restrito',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Somente coordenação, chefia de departamento e o próprio docente podem acessar esta área.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: SigadColors.muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Docente {
  const _Docente({
    required this.id,
    required this.nome,
    this.userEmail,
    required this.departamento,
    required this.cargaHoraria,
    required this.cargaMaxima,
    required this.disciplinas,
    required this.disponibilidade,
    required this.toneDisponibilidade,
  });

  final String id;
  final String nome;
  final String? userEmail;
  final String departamento;
  final int cargaHoraria;
  final int cargaMaxima;
  final List<String> disciplinas;
  final String disponibilidade;
  final Color toneDisponibilidade;

  _Docente copyWith({
    String? nome,
    String? userEmail,
    String? departamento,
    int? cargaHoraria,
    int? cargaMaxima,
    List<String>? disciplinas,
    String? disponibilidade,
    Color? toneDisponibilidade,
  }) {
    return _Docente(
      id: id,
      nome: nome ?? this.nome,
      userEmail: userEmail ?? this.userEmail,
      departamento: departamento ?? this.departamento,
      cargaHoraria: cargaHoraria ?? this.cargaHoraria,
      cargaMaxima: cargaMaxima ?? this.cargaMaxima,
      disciplinas: disciplinas ?? this.disciplinas,
      disponibilidade: disponibilidade ?? this.disponibilidade,
      toneDisponibilidade: toneDisponibilidade ?? this.toneDisponibilidade,
    );
  }
}
