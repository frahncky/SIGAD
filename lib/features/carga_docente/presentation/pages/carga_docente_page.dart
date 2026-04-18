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

  static const String _kKey = 'sigad_docentes';
  static const List<String> _diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
  ];

  static const List<String> _modalidades = [
    'Integral',
    'Concomitante',
    'Subsequente',
    'EJA',
    'Superior',
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
      horariosAula: const [
        _HorarioAula(diaSemana: 'Segunda', inicio: '08:00', fim: '09:40', disciplina: 'Programação I', cargaHoraria: '2h/sem · 80h', turma: 'SI-2A', modalidade: 'Integral'),
        _HorarioAula(diaSemana: 'Quarta', inicio: '10:00', fim: '11:40', disciplina: 'Programação II', cargaHoraria: '2h/sem · 80h', turma: 'SI-2B', modalidade: 'Concomitante'),
        _HorarioAula(diaSemana: 'Sexta', inicio: '19:00', fim: '20:40', disciplina: 'Engenharia de Software', cargaHoraria: '4h/sem · 120h', turma: 'SI-3A', modalidade: 'Superior'),
      ],
    ),
    _Docente(
      id: '#DOC-002',
      nome: 'Prof. Dr. João Silva',
      userEmail: 'joao.silva@univ.br',
      departamento: 'Sistemas de Informação',
      cargaHoraria: 16,
      cargaMaxima: 20,
      disciplinas: ['Banco de Dados', 'Web Design'],
      horariosAula: const [
        _HorarioAula(diaSemana: 'Terça', inicio: '08:00', fim: '09:40', disciplina: 'Banco de Dados', cargaHoraria: '4h/sem · 120h', turma: 'SI-3A', modalidade: 'Subsequente'),
        _HorarioAula(diaSemana: 'Quinta', inicio: '08:00', fim: '09:40', disciplina: 'Web Design', cargaHoraria: '2h/sem · 60h', turma: 'SI-2A', modalidade: 'EJA'),
      ],
    ),
    _Docente(
      id: '#DOC-003',
      nome: 'Profa. Ana Costa',
      userEmail: 'ana.pereira@univ.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 12,
      cargaMaxima: 20,
      disciplinas: ['Computação Gráfica'],
      horariosAula: const [
        _HorarioAula(diaSemana: 'Segunda', inicio: '14:00', fim: '15:40', disciplina: 'Computação Gráfica', cargaHoraria: '2h/sem · 60h', turma: 'ES-3B', modalidade: 'Integral'),
        _HorarioAula(diaSemana: 'Quarta', inicio: '14:00', fim: '15:40', disciplina: 'Computação Gráfica', cargaHoraria: '2h/sem · 60h', turma: 'ES-3B', modalidade: 'Integral'),
      ],
    ),
    _Docente(
      id: '#DOC-004',
      nome: 'Prof. Carlos Oliveira',
      userEmail: 'carlos.oliveira@univ.br',
      departamento: 'Redes e Telecomunicações',
      cargaHoraria: 18,
      cargaMaxima: 20,
      disciplinas: ['Redes I', 'Redes II', 'Segurança de Redes'],
      horariosAula: const [
        _HorarioAula(diaSemana: 'Terça', inicio: '19:00', fim: '20:40', disciplina: 'Redes I', cargaHoraria: '2h/sem · 60h', turma: 'RT-2A', modalidade: 'Subsequente'),
        _HorarioAula(diaSemana: 'Quinta', inicio: '19:00', fim: '20:40', disciplina: 'Redes II', cargaHoraria: '2h/sem · 80h', turma: 'RT-3A', modalidade: 'Concomitante'),
        _HorarioAula(diaSemana: 'Sexta', inicio: '21:00', fim: '22:40', disciplina: 'Segurança de Redes', cargaHoraria: '4h/sem · 120h', turma: 'RT-4A', modalidade: 'Superior'),
      ],
    ),
    _Docente(
      id: '#DOC-005',
      nome: 'Profa. Beatriz Mendes',
      userEmail: 'beatriz.mendes@univ.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 14,
      cargaMaxima: 20,
      disciplinas: ['Qualidade de Software'],
      horariosAula: const [
        _HorarioAula(diaSemana: 'Terça', inicio: '10:00', fim: '11:40', disciplina: 'Qualidade de Software', cargaHoraria: '2h/sem · 60h', turma: 'ES-4A', modalidade: 'EJA'),
        _HorarioAula(diaSemana: 'Quinta', inicio: '10:00', fim: '11:40', disciplina: 'Qualidade de Software', cargaHoraria: '2h/sem · 60h', turma: 'ES-4B', modalidade: 'Integral'),
      ],
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

    final carregados = <_Docente>[];
    for (final item in list) {
      try {
        carregados.add(_docenteFromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        // Ignora entradas inválidas para evitar crash ao abrir a tela.
      }
    }

    if (carregados.isEmpty) return;

    setState(() {
      _docentes
        ..clear()
        ..addAll(carregados);
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
    'horariosAula': d.horariosAula
        .map(
          (h) => {
            'diaSemana': h.diaSemana,
            'inicio': h.inicio,
            'fim': h.fim,
            if (h.disciplina != null) 'disciplina': h.disciplina,
            if (h.cargaHoraria != null) 'cargaHoraria': h.cargaHoraria,
            if (h.turma != null) 'turma': h.turma,
            if (h.modalidade != null) 'modalidade': h.modalidade,
          },
        )
        .toList(),
  };

  _Docente _docenteFromJson(Map<String, dynamic> json) {
    return _Docente(
      id: json['id']?.toString().trim().isNotEmpty == true ? json['id']!.toString().trim() : _gerarProximoIdDocente(),
      nome: json['nome']?.toString().trim().isNotEmpty == true ? json['nome']!.toString().trim() : 'Docente sem nome',
      userEmail: json['userEmail']?.toString().trim().isEmpty == true ? null : json['userEmail']?.toString().trim().toLowerCase(),
      departamento: json['departamento']?.toString().trim().isNotEmpty == true ? json['departamento']!.toString().trim() : 'Não informado',
      cargaHoraria: _toInt(json['cargaHoraria']),
      cargaMaxima: _toInt(json['cargaMaxima'], defaultValue: 20, minValue: 0),
      disciplinas: _disciplinasFromJson(json['disciplinas']),
      horariosAula: _horariosAulaFromJson(json['horariosAula']),
    );
  }

  int _toInt(dynamic raw, {int defaultValue = 0, int minValue = 0}) {
    final parsed = int.tryParse(raw?.toString() ?? '');
    if (parsed == null) return defaultValue;
    return parsed < minValue ? minValue : parsed;
  }

  List<String> _disciplinasFromJson(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<_HorarioAula> _horariosAulaFromJson(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final diaSemana = map['diaSemana']?.toString().trim();
          final inicio = map['inicio']?.toString().trim();
          final fim = map['fim']?.toString().trim();

          if (diaSemana == null || diaSemana.isEmpty || inicio == null || inicio.isEmpty || fim == null || fim.isEmpty) {
            return null;
          }

          return _HorarioAula(
            diaSemana: diaSemana,
            inicio: inicio,
            fim: fim,
            disciplina: map['disciplina']?.toString().trim(),
            cargaHoraria: map['cargaHoraria']?.toString().trim(),
            turma: map['turma']?.toString().trim(),
            modalidade: map['modalidade']?.toString().trim(),
          );
        })
        .whereType<_HorarioAula>()
        .toList(growable: false);
  }

  List<_Docente> _docentesVisiveis(UserRole role, {String? emailUsuario}) {
    if (role == UserRole.professor) {
      final emailNormalizado = (emailUsuario ?? '').trim().toLowerCase();
      return _docentes
          .where((docente) => (docente.userEmail ?? '').trim().toLowerCase() == emailNormalizado)
          .toList();
    }

    return _docentes;
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
    final List<String> disciplinas = [];
    final List<_HorarioAula> horarios = [];

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
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nomeController,
                        decoration: const InputDecoration(labelText: 'Nome Completo', hintText: 'Digite o nome do docente'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email de acesso', hintText: 'docente@univ.br'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: departamentoController,
                        decoration: const InputDecoration(labelText: 'Departamento', hintText: 'Digite o departamento'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: cargaMaximaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Carga Horária Máxima (horas)', hintText: 'Ex: 20'),
                      ),
                      const SizedBox(height: 16),
                      Text('Disciplinas', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Horários de Aula', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Adicionar'),
                            onPressed: () => _showAdicionarHorario(context, horarios, setModalState),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (horarios.isEmpty)
                        Text('Nenhum horário cadastrado', style: textTheme.bodySmall?.copyWith(color: SigadColors.muted))
                      else
                        ...horarios.map((h) => _HorarioTile(
                              horario: h,
                              textTheme: textTheme,
                              onDelete: () => setModalState(() => horarios.remove(h)),
                            )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                              cargaHoraria: horarios.length * 2,
                              cargaMaxima: cargaMaxima,
                              disciplinas: List<String>.from(disciplinas),
                              horariosAula: List<_HorarioAula>.from(horarios),
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

  void _showAdicionarHorario(BuildContext context, List<_HorarioAula> horarios, StateSetter setModalState) {
    String diaSelecionado = _diasSemana.first;
    String modalidadeSelecionada = _modalidades.first;
    final inicioController = TextEditingController();
    final fimController = TextEditingController();
    final disciplinaController = TextEditingController();
    final cargaController = TextEditingController();
    final turmaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Horário'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: diaSelecionado,
                  decoration: const InputDecoration(labelText: 'Dia da Semana'),
                  items: _diasSemana.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setDialogState(() => diaSelecionado = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inicioController,
                        decoration: const InputDecoration(labelText: 'Início', hintText: '08:00'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: fimController,
                        decoration: const InputDecoration(labelText: 'Fim', hintText: '09:40'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: disciplinaController,
                  decoration: const InputDecoration(labelText: 'Disciplina', hintText: 'Ex: Programação I'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cargaController,
                  decoration: const InputDecoration(labelText: 'Carga Horária', hintText: 'Ex: 2h/sem · 80h'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: turmaController,
                  decoration: const InputDecoration(labelText: 'Turma', hintText: 'Ex: ES-2A'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: modalidadeSelecionada,
                  decoration: const InputDecoration(labelText: 'Modalidade'),
                  items: _modalidades.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setDialogState(() => modalidadeSelecionada = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final inicio = inicioController.text.trim();
                final fim = fimController.text.trim();
                if (inicio.isEmpty || fim.isEmpty) return;
                setModalState(() => horarios.add(_HorarioAula(
                  diaSemana: diaSelecionado,
                  inicio: inicio,
                  fim: fim,
                  disciplina: disciplinaController.text.trim().isEmpty ? null : disciplinaController.text.trim(),
                  cargaHoraria: cargaController.text.trim().isEmpty ? null : cargaController.text.trim(),
                  turma: turmaController.text.trim().isEmpty ? null : turmaController.text.trim(),
                  modalidade: modalidadeSelecionada,
                )));
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditarDocente(BuildContext context, _Docente docente) {
    final textTheme = Theme.of(context).textTheme;
    final nomeController = TextEditingController(text: docente.nome);
    final emailController = TextEditingController(text: docente.userEmail ?? '');
    final departamentoController = TextEditingController(text: docente.departamento);
    final cargaMaximaController = TextEditingController(text: docente.cargaMaxima.toString());
    final List<String> disciplinas = List<String>.from(docente.disciplinas);
    final List<_HorarioAula> horarios = List<_HorarioAula>.from(docente.horariosAula);

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
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nomeController,
                        decoration: const InputDecoration(labelText: 'Nome Completo', hintText: 'Digite o nome do docente'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email de acesso', hintText: 'docente@univ.br'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: departamentoController,
                        decoration: const InputDecoration(labelText: 'Departamento', hintText: 'Digite o departamento'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: cargaMaximaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Carga Horária Máxima (horas)', hintText: 'Ex: 20'),
                      ),
                      const SizedBox(height: 16),
                      Text('Disciplinas', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Horários de Aula', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Adicionar'),
                            onPressed: () => _showAdicionarHorario(context, horarios, setModalState),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (horarios.isEmpty)
                        Text('Nenhum horário cadastrado', style: textTheme.bodySmall?.copyWith(color: SigadColors.muted))
                      else
                        ...horarios.map((h) => _HorarioTile(
                              horario: h,
                              textTheme: textTheme,
                              onDelete: () => setModalState(() => horarios.remove(h)),
                            )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                              cargaHoraria: horarios.length * 2,
                              cargaMaxima: cargaMaxima,
                              horariosAula: List<_HorarioAula>.from(horarios),
                              disciplinas: List<String>.from(disciplinas),
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
    final emailNormalizado = (user?.email ?? '').trim().toLowerCase();
    final docentesVisiveis = _docentesVisiveis(role, emailUsuario: user?.email);
    final docentesOrdenados = podeGerenciar
        ? [
            ...docentesVisiveis.where((d) => (d.userEmail ?? '').trim().toLowerCase() == emailNormalizado),
            ...docentesVisiveis.where((d) => (d.userEmail ?? '').trim().toLowerCase() != emailNormalizado),
          ]
        : docentesVisiveis;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: docentesOrdenados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 64, color: SigadColors.muted.withValues(alpha: 0.3)),
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
              itemCount: docentesOrdenados.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _DocenteCard(
                docente: docentesOrdenados[index],
                canManage: podeGerenciar,
                onEditar: () => _showEditarDocente(context, docentesOrdenados[index]),
                onExcluir: () => _showConfirmarExclusao(context, docentesOrdenados[index]),
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

class _DocenteCard extends StatefulWidget {
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
  State<_DocenteCard> createState() => _DocenteCardState();
}

class _DocenteCardState extends State<_DocenteCard> {
  bool _horariosExpandidos = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final docente = widget.docente;
    final cargaMaxima = docente.cargaMaxima;
    final percentualCarga = cargaMaxima > 0 ? (docente.cargaHoraria / cargaMaxima * 100).round() : 0;
    final progressoCarga = cargaMaxima > 0 ? (docente.cargaHoraria / cargaMaxima).clamp(0.0, 1.0).toDouble() : 0.0;
    final podeExpandirHorarios = widget.canManage && docente.horariosAula.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: podeExpandirHorarios
              ? () => setState(() => _horariosExpandidos = !_horariosExpandidos)
              : null,
          borderRadius: BorderRadius.circular(16),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            children: [
                              Expanded(
                                child: Text(
                                  docente.nome,
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (podeExpandirHorarios)
                                Icon(
                                  _horariosExpandidos ? Icons.expand_less : Icons.expand_more,
                                  size: 18,
                                  color: SigadColors.brand,
                                ),
                            ],
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
                  if (widget.canManage)
                    PopupMenuButton<String>(
                      onSelected: _onMenuItemSelected,
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
                  value: progressoCarga,
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
        ),
        if (podeExpandirHorarios) ...[
          const SizedBox(height: 10),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    'Distribuição semanal',
                    style: textTheme.labelSmall?.copyWith(
                      color: SigadColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _MapaSemanalHorarios(
                  horarios: docente.horariosAula,
                  compacto: true,
                ),
              ],
            ),
            crossFadeState: _horariosExpandidos ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ],
    );
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'editar':
        widget.onEditar();
        break;
      case 'excluir':
        widget.onExcluir();
        break;
    }
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

class _MapaSemanalHorarios extends StatelessWidget {
  const _MapaSemanalHorarios({
    required this.horarios,
    required this.compacto,
  });

  final List<_HorarioAula> horarios;
  final bool compacto;

  static const List<String> _diasOrdem = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final horariosPorDia = _agruparPorDia();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SigadColors.divider),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 560 ? 5 : 3;
          final spacing = 8.0;
          final availableWidth = constraints.maxWidth - ((crossAxisCount - 1) * spacing);
          final itemWidth = availableWidth > 0 ? availableWidth / crossAxisCount : 80.0;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: _diasOrdem
                .map(
                  (dia) => SizedBox(
                    width: itemWidth,
                    child: _ColunaMapaSemanal(
                      dia: dia,
                      horarios: horariosPorDia[dia] ?? const [],
                      compacto: compacto,
                      textTheme: textTheme,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Map<String, List<_HorarioAula>> _agruparPorDia() {
    final agrupado = {
      for (final dia in _diasOrdem) dia: <_HorarioAula>[],
    };

    for (final horario in horarios) {
      final dia = _abreviarDia(horario.diaSemana);
      if (dia == null) continue;
      agrupado[dia]!.add(horario);
    }

    for (final dia in _diasOrdem) {
      agrupado[dia]!.sort((a, b) => a.inicio.compareTo(b.inicio));
    }

    return agrupado;
  }

  String? _abreviarDia(String diaSemana) {
    final d = diaSemana.trim().toLowerCase();
    if (d.startsWith('seg')) return 'Seg';
    if (d.startsWith('ter')) return 'Ter';
    if (d.startsWith('qua')) return 'Qua';
    if (d.startsWith('qui')) return 'Qui';
    if (d.startsWith('sex')) return 'Sex';
    return null;
  }
}

class _ColunaMapaSemanal extends StatelessWidget {
  const _ColunaMapaSemanal({
    required this.dia,
    required this.horarios,
    required this.compacto,
    required this.textTheme,
  });

  final String dia;
  final List<_HorarioAula> horarios;
  final bool compacto;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: horarios.isNotEmpty ? SigadColors.brand.withValues(alpha: 0.08) : SigadColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              dia,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: horarios.isNotEmpty ? SigadColors.brand : SigadColors.muted,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: horarios.isEmpty
                ? Text(
                    '-',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...horarios.map(
                        (h) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(
                            color: SigadColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: SigadColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${h.inicio} – ${h.fim}',
                                textAlign: TextAlign.center,
                                style: textTheme.labelSmall?.copyWith(
                                  color: SigadColors.brand,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (h.disciplina != null && h.disciplina!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  h.disciplina!,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: SigadColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                              if (h.turma != null && h.turma!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(h.turma!, style: textTheme.labelSmall?.copyWith(color: SigadColors.muted), overflow: TextOverflow.ellipsis),
                              ],
                              if (h.cargaHoraria != null && h.cargaHoraria!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(h.cargaHoraria!, style: textTheme.labelSmall?.copyWith(color: SigadColors.muted), overflow: TextOverflow.ellipsis),
                              ],
                              if (h.modalidade != null && h.modalidade!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(h.modalidade!, style: textTheme.labelSmall?.copyWith(color: SigadColors.muted), overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
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

class _HorarioTile extends StatelessWidget {
  const _HorarioTile({required this.horario, required this.textTheme, required this.onDelete});
  final _HorarioAula horario;
  final TextTheme textTheme;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${horario.diaSemana}  ${horario.inicio} – ${horario.fim}',
                  style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: SigadColors.brand),
                ),
                if (horario.disciplina != null) ...[
                  const SizedBox(height: 2),
                  Text(horario.disciplina!, style: textTheme.bodySmall?.copyWith(color: SigadColors.ink)),
                ],
                if (horario.turma != null || horario.cargaHoraria != null || horario.modalidade != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [horario.turma, horario.cargaHoraria, horario.modalidade].whereType<String>().join(' · '),
                    style: textTheme.labelSmall?.copyWith(color: SigadColors.muted),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: SigadColors.risk,
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
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
    this.horariosAula = const [],
  });

  final String id;
  final String nome;
  final String? userEmail;
  final String departamento;
  final int cargaHoraria;
  final int cargaMaxima;
  final List<String> disciplinas;
  final List<_HorarioAula> horariosAula;

  _Docente copyWith({
    String? nome,
    String? userEmail,
    String? departamento,
    int? cargaHoraria,
    int? cargaMaxima,
    List<String>? disciplinas,
    List<_HorarioAula>? horariosAula,
  }) {
    return _Docente(
      id: id,
      nome: nome ?? this.nome,
      userEmail: userEmail ?? this.userEmail,
      departamento: departamento ?? this.departamento,
      cargaHoraria: cargaHoraria ?? this.cargaHoraria,
      cargaMaxima: cargaMaxima ?? this.cargaMaxima,
      disciplinas: disciplinas ?? this.disciplinas,
      horariosAula: horariosAula ?? this.horariosAula,
    );
  }
}

class _HorarioAula {
  const _HorarioAula({
    required this.diaSemana,
    required this.inicio,
    required this.fim,
    this.disciplina,
    this.cargaHoraria,
    this.turma,
    this.modalidade,
  });

  final String diaSemana;
  final String inicio;
  final String fim;
  final String? disciplina;
  final String? cargaHoraria;
  final String? turma;
  final String? modalidade;
}
