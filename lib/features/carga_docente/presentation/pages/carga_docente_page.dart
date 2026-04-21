import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../configuracoes/data/configuracoes_repository.dart';
import '../../../configuracoes/domain/configuracoes_models.dart';
import '../../../configuracoes/domain/configuracoes_service.dart';
import '../../data/docente_repository.dart';
import '../../domain/docente_models.dart';
import '../controllers/docente_form_controller.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';




class CargaDocentePage extends StatefulWidget {
  const CargaDocentePage({super.key});

  @override
  State<CargaDocentePage> createState() => _CargaDocentePageState();
}

class _CargaDocentePageState extends State<CargaDocentePage> {
  Docente? _docenteSelecionado;
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';

  static const Set<UserRole> _allowedRoles = {
    UserRole.professor,
    UserRole.coordenador,
    UserRole.chefeDepartamento,
  };

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

  final DocenteRepository _docenteRepository = DocenteRepository();
  final ConfiguracoesRepository _configuracoesRepository = ConfiguracoesRepository();

  final List<Docente> _docentes = [
    Docente(
      id: '#DOC-001',
      nome: 'Profa. Dra. Maria Silva',
      userId: 'user_email_maria.santos@univ.br',
      userEmail: 'maria.santos@univ.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 20,
      cargaMaxima: 20,
      disciplinas: ['Programação I', 'Programação II', 'Engenharia de Software'],
      horariosAula: const [
        HorarioAula(diaSemana: 'Segunda', inicio: '08:00', fim: '09:40', disciplina: 'Programação I', cargaHoraria: '2h/sem · 80h', turma: 'SI-2A', modalidade: 'Integral'),
        HorarioAula(diaSemana: 'Quarta', inicio: '10:00', fim: '11:40', disciplina: 'Programação II', cargaHoraria: '2h/sem · 80h', turma: 'SI-2B', modalidade: 'Concomitante'),
        HorarioAula(diaSemana: 'Sexta', inicio: '19:00', fim: '20:40', disciplina: 'Engenharia de Software', cargaHoraria: '4h/sem · 120h', turma: 'SI-3A', modalidade: 'Superior'),
      ],
    ),
    Docente(
      id: '#DOC-002',
      nome: 'Prof. Dr. João Silva',
      userId: 'user_email_joao.silva@univ.br',
      userEmail: 'joao.silva@univ.br',
      departamento: 'Sistemas de Informação',
      cargaHoraria: 16,
      cargaMaxima: 20,
      disciplinas: ['Banco de Dados', 'Web Design'],
      horariosAula: const [
        HorarioAula(diaSemana: 'Terça', inicio: '08:00', fim: '09:40', disciplina: 'Banco de Dados', cargaHoraria: '4h/sem · 120h', turma: 'SI-3A', modalidade: 'Subsequente'),
        HorarioAula(diaSemana: 'Quinta', inicio: '08:00', fim: '09:40', disciplina: 'Web Design', cargaHoraria: '2h/sem · 60h', turma: 'SI-2A', modalidade: 'EJA'),
      ],
    ),
    Docente(
      id: '#DOC-003',
      nome: 'Profa. Ana Costa',
      userId: 'user_email_ana.pereira@univ.br',
      userEmail: 'ana.pereira@univ.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 12,
      cargaMaxima: 20,
      disciplinas: ['Computação Gráfica'],
      horariosAula: const [
        HorarioAula(diaSemana: 'Segunda', inicio: '14:00', fim: '15:40', disciplina: 'Computação Gráfica', cargaHoraria: '2h/sem · 60h', turma: 'ES-3B', modalidade: 'Integral'),
        HorarioAula(diaSemana: 'Quarta', inicio: '14:00', fim: '15:40', disciplina: 'Computação Gráfica', cargaHoraria: '2h/sem · 60h', turma: 'ES-3B', modalidade: 'Integral'),
      ],
    ),
    Docente(
      id: '#DOC-004',
      nome: 'Prof. Carlos Oliveira',
      userId: 'user_email_carlos.oliveira@univ.br',
      userEmail: 'carlos.oliveira@univ.br',
      departamento: 'Redes e Telecomunicações',
      cargaHoraria: 18,
      cargaMaxima: 20,
      disciplinas: ['Redes I', 'Redes II', 'Segurança de Redes'],
      horariosAula: const [
        HorarioAula(diaSemana: 'Terça', inicio: '19:00', fim: '20:40', disciplina: 'Redes I', cargaHoraria: '2h/sem · 60h', turma: 'RT-2A', modalidade: 'Subsequente'),
        HorarioAula(diaSemana: 'Quinta', inicio: '19:00', fim: '20:40', disciplina: 'Redes II', cargaHoraria: '2h/sem · 80h', turma: 'RT-3A', modalidade: 'Concomitante'),
        HorarioAula(diaSemana: 'Sexta', inicio: '21:00', fim: '22:40', disciplina: 'Segurança de Redes', cargaHoraria: '4h/sem · 120h', turma: 'RT-4A', modalidade: 'Superior'),
      ],
    ),
    Docente(
      id: '#DOC-005',
      nome: 'Profa. Beatriz Mendes',
      userId: 'user_email_beatriz.mendes@univ.br',
      userEmail: 'beatriz.mendes@univ.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 14,
      cargaMaxima: 20,
      disciplinas: ['Qualidade de Software'],
      horariosAula: const [
        HorarioAula(diaSemana: 'Terça', inicio: '10:00', fim: '11:40', disciplina: 'Qualidade de Software', cargaHoraria: '2h/sem · 60h', turma: 'ES-4A', modalidade: 'EJA'),
        HorarioAula(diaSemana: 'Quinta', inicio: '10:00', fim: '11:40', disciplina: 'Qualidade de Software', cargaHoraria: '2h/sem · 60h', turma: 'ES-4B', modalidade: 'Integral'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Aguarda contexto para pegar argumentos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Docente) {
        setState(() {
          _docenteSelecionado = args;
        });
      }
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final carregados = await _docenteRepository.loadDocentes(
      generateFallbackId: _gerarProximoIdDocente,
    );
    if (carregados.isEmpty) return;

    setState(() {
      _docentes
        ..clear()
        ..addAll(carregados);
    });
  }

  void _saveData() {
    _docenteRepository.saveDocentes(_docentes);
  }

  List<Docente> _docentesVisiveis() {
    // Professores podem pesquisar todos, mas só visualizar agenda e enviar convite
    return List<Docente>.from(_docentes, growable: false);
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

  void _mostrarFeedback(String mensagem) {
    AppFeedbackService.info(context, mensagem);
  }

  void _showAdicionarDocente(BuildContext context) {
    final controller = DocenteFormController.createNew();

    _showDocenteFormSheet(
      context: context,
      title: 'Novo Docente',
      confirmLabel: 'Adicionar',
      controller: controller,
      onSubmit: () {
        final erro = controller.validate();
        if (erro != null) {
          _mostrarFeedback(erro);
          return false;
        }

        setState(() {
          _docentes.insert(0, controller.buildNewDocente(_gerarProximoIdDocente()));
        });
        _saveData();
        AppEventLogger.action('carga_docente_add_docente', details: {
          'nome': controller.nomeController.text.trim(),
          'qtdDisciplinas': controller.disciplinas.length,
          'qtdHorarios': controller.horarios.length,
        });
        _mostrarFeedback('Docente adicionado com sucesso!');
        return true;
      },
    );
  }

  void _showDocenteFormSheet({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    required DocenteFormController controller,
    required bool Function() onSubmit,
  }) {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => PopScope(
          onPopInvokedWithResult: (_, _) => controller.dispose(),
          child: Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton(
                    tooltip: 'Fechar formulário do docente',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
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
                        controller: controller.nomeController,
                        decoration: const InputDecoration(labelText: 'Nome Completo', hintText: 'Digite o nome do docente'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email de acesso', hintText: 'docente@univ.br'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.departamentoController,
                        decoration: const InputDecoration(labelText: 'Departamento', hintText: 'Digite o departamento'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.cargaMaximaController,
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
                          ...controller.disciplinas.map((d) => Chip(
                                label: Text(d),
                                onDeleted: () => setModalState(() => controller.removeDisciplina(d)),
                              )),
                          ActionChip(
                            label: const Text('Adicionar'),
                            onPressed: () => _showAdicionarDisciplina(context, controller, setModalState),
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
                            onPressed: () => _showAdicionarHorario(context, controller, setModalState),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (controller.horarios.isEmpty)
                        Text('Nenhum horário cadastrado', style: textTheme.bodySmall?.copyWith(color: SigadColors.muted))
                      else
                        ...controller.horarios.map((h) => _HorarioTile(
                              horario: h,
                              textTheme: textTheme,
                              onDelete: () => setModalState(() => controller.removeHorario(h)),
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
                        if (onSubmit()) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _showAdicionarDisciplina(BuildContext context, DocenteFormController controller, StateSetter setState) {
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
              final erro = controller.validateDisciplina(disciplina);
              if (erro != null) {
                _mostrarFeedback(erro);
                return;
              }
              setState(() => controller.addDisciplina(disciplina));
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showAdicionarHorario(BuildContext context, DocenteFormController controller, StateSetter setModalState) {
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
                final erro = controller.validateHorario(inicio: inicio, fim: fim);
                if (erro != null) {
                  _mostrarFeedback(erro);
                  return;
                }

                setModalState(() => controller.addHorario(controller.createHorario(
                  diaSemana: diaSelecionado,
                  inicio: inicio,
                  fim: fim,
                  disciplina: disciplinaController.text,
                  cargaHoraria: cargaController.text,
                  turma: turmaController.text,
                  modalidade: modalidadeSelecionada,
                )));
                AppEventLogger.action('carga_docente_add_horario', details: {
                  'diaSemana': diaSelecionado,
                  'inicio': inicio,
                  'fim': fim,
                });
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditarDocente(BuildContext context, Docente docente) {
    final controller = DocenteFormController.fromDocente(docente);

    _showDocenteFormSheet(
      context: context,
      title: 'Editar Docente',
      confirmLabel: 'Salvar',
      controller: controller,
      onSubmit: () {
        final erro = controller.validate();
        if (erro != null) {
          _mostrarFeedback(erro);
          return false;
        }

        setState(() {
          final index = _docentes.indexWhere((item) => item.id == docente.id);
          if (index >= 0) {
            _docentes[index] = controller.buildUpdatedDocente(docente);
          }
        });
        _saveData();
        AppEventLogger.action('carga_docente_edit_docente', details: {
          'docenteId': docente.id,
          'nome': controller.nomeController.text.trim(),
          'qtdHorarios': controller.horarios.length,
        });
        _mostrarFeedback('Docente atualizado com sucesso!');
        return true;
      },
    );
  }

  void _showConfirmarExclusao(BuildContext context, Docente docente) {
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
              AppEventLogger.action('carga_docente_remove_docente', details: {
                'docenteId': docente.id,
                'nome': docente.nome,
              });
              Navigator.pop(context);
              _mostrarFeedback('Docente excluído com sucesso!');
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _abrirAgendaDocente(BuildContext context, Docente docente) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AgendaDocentePage(docente: docente),
      ),
    );
  }

  Future<void> _showNovoCompromissoAgenda(BuildContext context, String userId) async {
    if (userId.trim().isEmpty) {
      _mostrarFeedback('Faça login novamente para criar compromissos na agenda.');
      return;
    }

    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final localController = TextEditingController();
    final linkController = TextEditingController();

    DateTime? dataSelecionada;
    TimeOfDay? horarioSelecionado;
    String plataforma = 'Sem link';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final dataHoraLabel = _formatarDataHoraSelecionada(dataSelecionada, horarioSelecionado);
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Novo compromisso',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Ex: Reunião de planejamento',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descricaoController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Detalhes do compromisso',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: localController,
                    decoration: const InputDecoration(
                      labelText: 'Local',
                      hintText: 'Sala 12 ou Online',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final data = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                              initialDate: dataSelecionada ?? DateTime.now(),
                            );
                            if (data == null) return;
                            setModalState(() => dataSelecionada = data);
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: const Text('Data'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final horario = await showTimePicker(
                              context: context,
                              initialTime: horarioSelecionado ?? TimeOfDay.now(),
                            );
                            if (horario == null) return;
                            setModalState(() => horarioSelecionado = horario);
                          },
                          icon: const Icon(Icons.access_time_outlined),
                          label: const Text('Hora'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dataHoraLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: plataforma,
                    decoration: const InputDecoration(labelText: 'Link de reunião'),
                    items: const [
                      DropdownMenuItem(value: 'Sem link', child: Text('Sem link')),
                      DropdownMenuItem(value: 'Google Meet', child: Text('Google Meet')),
                      DropdownMenuItem(value: 'Zoom', child: Text('Zoom')),
                    ],
                    onChanged: (value) => setModalState(() => plataforma = value ?? 'Sem link'),
                  ),
                  if (plataforma != 'Sem link') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: linkController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: 'URL da reunião',
                        hintText: plataforma == 'Google Meet'
                            ? 'https://meet.google.com/...'
                            : 'https://zoom.us/j/...',
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final titulo = tituloController.text.trim();
                        final descricao = descricaoController.text.trim();
                        final local = localController.text.trim();
                        final link = linkController.text.trim();

                        if (titulo.isEmpty) {
                          _mostrarFeedback('Informe o título do compromisso.');
                          return;
                        }
                        if (local.isEmpty) {
                          _mostrarFeedback('Informe o local do compromisso.');
                          return;
                        }
                        if (dataSelecionada == null || horarioSelecionado == null) {
                          _mostrarFeedback('Selecione data e hora do compromisso.');
                          return;
                        }
                        if (plataforma != 'Sem link') {
                          final erro = _validarLinkReuniao(link, plataforma);
                          if (erro != null) {
                            _mostrarFeedback(erro);
                            return;
                          }
                        }

                        final dataHora = DateTime(
                          dataSelecionada!.year,
                          dataSelecionada!.month,
                          dataSelecionada!.day,
                          horarioSelecionado!.hour,
                          horarioSelecionado!.minute,
                        );

                        final novoCompromisso = CompromissoAgenda(
                          id: 'manual_${DateTime.now().microsecondsSinceEpoch}',
                          titulo: titulo,
                          descricao: descricao.isEmpty ? 'Compromisso criado manualmente.' : descricao,
                          inicio: _formatarDataHora(dataHora),
                          inicioIso: dataHora.toIso8601String(),
                          local: local,
                          origem: 'Agenda pessoal',
                          destinatarioUserId: userId,
                          linkReuniao: plataforma == 'Sem link' ? null : link,
                          statusConvite: StatusConviteAgenda.aceito,
                        );

                        final atual = await _configuracoesRepository.load() ?? ConfiguracoesService.defaultData();
                        final atualizado = ConfiguracoesService.adicionarConviteNaAgenda(
                          data: atual,
                          convite: novoCompromisso,
                        );
                        await _configuracoesRepository.save(atualizado);

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        _mostrarFeedback('Compromisso criado com sucesso na sua agenda.');
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Salvar compromisso'),
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

  String _formatarDataHoraSelecionada(DateTime? data, TimeOfDay? hora) {
    if (data == null || hora == null) {
      return 'Selecione data e hora';
    }
    final combinada = DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
    return _formatarDataHora(combinada);
  }

  String _formatarDataHora(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final ano = dataHora.year.toString();
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }

  String? _validarLinkReuniao(String link, String plataforma) {
    if (link.trim().isEmpty) {
      return 'Informe o link da reunião.';
    }
    final uri = Uri.tryParse(link.trim());
    if (uri == null || !(uri.hasScheme && uri.hasAuthority)) {
      return 'Informe uma URL válida (https://...).';
    }

    final host = uri.host.toLowerCase();
    if (plataforma == 'Google Meet' && !host.contains('meet.google.com')) {
      return 'Use um link válido do Google Meet.';
    }
    if (plataforma == 'Zoom' && !(host == 'zoom.us' || host.endsWith('.zoom.us'))) {
      return 'Use um link válido do Zoom.';
    }

    return null;
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

    // Se veio um docente selecionado via argumento, mostra a agenda semanal dele
    if (_docenteSelecionado != null) {
      return _AgendaDocentePage(docente: _docenteSelecionado!);
    }

    // ...código original da agenda para o próprio usuário...
    final podeGerenciar = role == UserRole.coordenador || role == UserRole.chefeDepartamento;
    final podeVisualizarHorarios = true; // Todos podem visualizar
    final emailNormalizado = (user?.email ?? '').trim().toLowerCase();
    final docentesVisiveis = _docentesVisiveis();
    // Filtro de busca
    List<Docente> docentesFiltrados;
    // Detecta se está no menu Professores (AppRoutes.professores) ou na Agenda individual (AppRoutes.cargaDocente)
    final isProfessoresMenu = ModalRoute.of(context)?.settings.name == '/professores';
    if (isProfessoresMenu && podeGerenciar) {
      // No menu Professores: coordenador/chefe veem todos e podem editar
      docentesFiltrados = _busca.isEmpty
          ? docentesVisiveis
          : docentesVisiveis.where((d) {
              final buscaLower = _busca.toLowerCase();
              return d.nome.toLowerCase().contains(buscaLower) ||
                  (d.userEmail ?? '').toLowerCase().contains(buscaLower) ||
                  d.departamento.toLowerCase().contains(buscaLower);
            }).toList();
    } else {
      // Em qualquer outro menu (inclusive Agenda): só vê a própria agenda, outros só se pesquisar
      final isSearching = _busca.trim().isNotEmpty;
      final self = docentesVisiveis.where((d) => (d.userEmail ?? '').trim().toLowerCase() == emailNormalizado).toList();
      if (!isSearching) {
        docentesFiltrados = self;
      } else {
        final buscaLower = _busca.toLowerCase();
        final outros = docentesVisiveis.where((d) =>
          (d.nome.toLowerCase().contains(buscaLower) ||
           (d.userEmail ?? '').toLowerCase().contains(buscaLower) ||
           d.departamento.toLowerCase().contains(buscaLower))
        ).toList();
        // Garante que o próprio sempre aparece primeiro, sem duplicar
        final outrosSemSelf = outros.where((d) => (d.userEmail ?? '').trim().toLowerCase() != emailNormalizado).toList();
        docentesFiltrados = [...self, ...outrosSemSelf];
      }
    }
    final docentesOrdenados = docentesFiltrados;
    final textTheme = Theme.of(context).textTheme;

    // Identifica o próprio docente
    Docente? selfDocente;
    try {
      selfDocente = docentesVisiveis.firstWhere(
        (d) => (d.userEmail ?? '').trim().toLowerCase() == emailNormalizado,
      );
    } catch (_) {
      selfDocente = null;
    }

    return Scaffold(
      body: Column(
        children: [
          if (selfDocente != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _DocenteCard(
                docente: selfDocente,
                canManage: podeGerenciar,
                canViewSchedule: true,
                onAbrirAgenda: () => _abrirAgendaDocente(context, selfDocente!),
                onEditar: podeGerenciar ? () => _showEditarDocente(context, selfDocente!) : null,
                onExcluir: podeGerenciar ? () => _showConfirmarExclusao(context, selfDocente!) : null,
                somenteVisualizar: !podeGerenciar,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _buscaController,
              onChanged: (value) => setState(() => _busca = value),
              decoration: const InputDecoration(
                hintText: 'Buscar docente por nome, e-mail ou departamento',
                prefixIcon: Icon(Icons.search_outlined),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                // Lista de outros docentes (exclui o próprio)
                final outrosDocentes = selfDocente == null
                  ? docentesOrdenados
                  : docentesOrdenados.where((d) => d.id != selfDocente!.id).toList();
                if (outrosDocentes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 64, color: SigadColors.muted.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum docente encontrado',
                          style: textTheme.bodyLarge?.copyWith(color: SigadColors.muted),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: outrosDocentes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _DocenteCard(
                    docente: outrosDocentes[index],
                    canManage: podeGerenciar,
                    canViewSchedule: podeVisualizarHorarios,
                    onAbrirAgenda: () => _abrirAgendaDocente(context, outrosDocentes[index]),
                    onEditar: podeGerenciar ? () => _showEditarDocente(context, outrosDocentes[index]) : null,
                    onExcluir: podeGerenciar ? () => _showConfirmarExclusao(context, outrosDocentes[index]) : null,
                    somenteVisualizar: !podeGerenciar,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: podeGerenciar
          ? FloatingActionButton(
              onPressed: () => _showAdicionarDocente(context),
              tooltip: 'Adicionar docente',
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
    required this.canViewSchedule,
    required this.onAbrirAgenda,
    this.onEditar,
    this.onExcluir,
    this.somenteVisualizar = false,
  });

  final Docente docente;
  final bool canManage;
  final bool canViewSchedule;
  final VoidCallback onAbrirAgenda;
  final VoidCallback? onEditar;
  final VoidCallback? onExcluir;
  final bool somenteVisualizar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SigadColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
              if (canManage && !somenteVisualizar)
                PopupMenuButton<String>(
                  tooltip: 'Mais ações do docente',
                  onSelected: (value) {
                    switch (value) {
                      case 'editar':
                        if (onEditar != null) onEditar!();
                        break;
                      case 'excluir':
                        if (onExcluir != null) onExcluir!();
                        break;
                    }
                  },
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
          Text(
            'Carga horária: ${docente.cargaHoraria}h',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: docente.disciplinas
                .map((d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SigadColors.brand.withOpacity(0.1),
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
              'Somente docentes, coordenação, chefia e servidor administrativo podem acessar esta área.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaDocentePage extends StatelessWidget {
  const _AgendaDocentePage({required this.docente});

  final Docente docente;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 1200
        ? 8.0
        : screenWidth >= 900
            ? 10.0
            : 6.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda do docente'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do professor destacado acima da grade semanal
            Text(
              docente.nome,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: SigadColors.brand,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              docente.departamento,
              style: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
            ),
            const SizedBox(height: 10),
            Text(
              'Carga horária: ${docente.cargaHoraria}h',
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: docente.disciplinas
                  .map(
                    (d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SigadColors.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        d,
                        style: textTheme.labelSmall?.copyWith(color: SigadColors.brand),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            // Nome do professor acima da grade semanal
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Agenda semanal de ${docente.nome}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            _MapaSemanalHorarios(
              horarios: docente.horariosAula,
              compacto: false,
              onTapLivre: (slot) => _showNovoCompromissoPorSlot(context, slot),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNovoCompromissoPorSlot(
    BuildContext pageContext,
    _AgendaCellTapData slot,
  ) async {
    final tituloController = TextEditingController(text: 'Compromisso');
    final descricaoController = TextEditingController(
      text: 'Compromisso criado pela grade semanal.',
    );
    final localController = TextEditingController();

    try {
      await showModalBottomSheet(
        context: pageContext,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (modalContext) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo compromisso',
                  style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatarData(slot.data)} · ${slot.horarioFaixa} (${slot.turno.shortLabel}${slot.periodo})',
                  style: Theme.of(modalContext).textTheme.bodySmall?.copyWith(
                        color: SigadColors.muted,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Titulo',
                    hintText: 'Ex: Reuniao de alinhamento',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricaoController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descricao',
                    hintText: 'Detalhes do compromisso',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: localController,
                  decoration: const InputDecoration(
                    labelText: 'Local',
                    hintText: 'Sala 12 ou Online',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final inicio = _inicioSlot(slot.data, slot.horarioFaixa);
                      if (inicio == null) {
                        AppFeedbackService.info(pageContext, 'Nao foi possivel interpretar o horario da celula.');
                        return;
                      }

                      final titulo = tituloController.text.trim();
                      final descricao = descricaoController.text.trim();
                      final local = localController.text.trim();
                      if (titulo.isEmpty) {
                        AppFeedbackService.info(pageContext, 'Informe o titulo do compromisso.');
                        return;
                      }
                      if (local.isEmpty) {
                        AppFeedbackService.info(pageContext, 'Informe o local do compromisso.');
                        return;
                      }

                      final destinatario = _destinatarioAgenda(docente);
                      final novoCompromisso = CompromissoAgenda(
                        id: 'slot_${DateTime.now().microsecondsSinceEpoch}',
                        titulo: titulo,
                        descricao: descricao.isEmpty ? 'Compromisso criado pela agenda semanal.' : descricao,
                        inicio: _formatarDataHora(inicio),
                        inicioIso: inicio.toIso8601String(),
                        local: local,
                        origem: 'Agenda semanal do docente',
                        destinatarioUserId: destinatario,
                        statusConvite: StatusConviteAgenda.aceito,
                      );

                      final repository = ConfiguracoesRepository();
                      final atual = await repository.load() ?? ConfiguracoesService.defaultData();
                      final atualizado = ConfiguracoesService.adicionarConviteNaAgenda(
                        data: atual,
                        convite: novoCompromisso,
                      );
                      await repository.save(atualizado);

                      if (!pageContext.mounted) return;
                      Navigator.pop(modalContext);
                      AppFeedbackService.info(pageContext, 'Compromisso criado com sucesso na agenda.');
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Salvar compromisso'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      tituloController.dispose();
      descricaoController.dispose();
      localController.dispose();
    }
  }

  String _destinatarioAgenda(Docente docente) {
    final id = (docente.userId ?? '').trim();
    if (id.isNotEmpty) return id;
    final email = (docente.userEmail ?? '').trim().toLowerCase();
    if (email.isNotEmpty) return 'user_email_$email';
    return docente.id;
  }

  DateTime? _inicioSlot(DateTime data, String faixa) {
    final partesFaixa = faixa.split('-');
    if (partesFaixa.length != 2) return null;
    final inicio = partesFaixa[0].trim();
    final partesHora = inicio.split(':');
    if (partesHora.length != 2) return null;

    final hora = int.tryParse(partesHora[0]);
    final minuto = int.tryParse(partesHora[1]);
    if (hora == null || minuto == null) return null;
    if (hora < 0 || hora > 23 || minuto < 0 || minuto > 59) return null;

    return DateTime(data.year, data.month, data.day, hora, minuto);
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  String _formatarDataHora(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final ano = dataHora.year.toString();
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }
}

class _MapaSemanalHorarios extends StatelessWidget {
  const _MapaSemanalHorarios({
    required this.horarios,
    required this.compacto,
    this.onTapLivre,
  });

  final List<HorarioAula> horarios;
  final bool compacto;
  final Future<void> Function(_AgendaCellTapData slot)? onTapLivre;

  static const List<String> _diasOrdem = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
  static const List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Marco',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  static const double _rowHeightCompact = 82;
  static const double _rowHeightRegular = 92;

  @override
  Widget build(BuildContext context) {
    final linhas = _gerarLinhasGrade();
    final gradePorDiaTurnoPeriodo = _buildGradePorDiaTurnoPeriodo(linhas);
    final rowHeight = compacto ? _rowHeightCompact : _rowHeightRegular;
    final datasDaSemana = _datasDaSemanaAtual();
    final hoje = DateTime.now();
    final mesLabel = _meses[hoje.month - 1];
    final semanaLabel = _descricaoSemanaAtual();
    final diaSelecionadoAbreviado = _diaSemanaAbreviado(hoje.weekday);
    final diaSelecionadoCompleto = _diaSemanaCompleto(hoje.weekday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agenda semanal',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '$semanaLabel de $mesLabel',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 2),
        Text(
          'Dia selecionado: ${hoje.day} ($diaSelecionadoAbreviado - $diaSelecionadoCompleto)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 14),
        if (horarios.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Sem aulas cadastradas na semana.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: SigadColors.surface,
              border: Border.all(color: SigadColors.divider),
            ),
            child: Column(
              children: [
                for (var index = 0; index < linhas.length; index++) ...[
                  if (index == 0 || linhas[index - 1].turno != linhas[index].turno)
                    _TurnoAgendaDividerRow(turno: linhas[index].turno),
                  Row(
                    children: [
                      for (var i = 0; i < _diasOrdem.length; i++)
                        Expanded(
                          child: _GradeAgendaCell(
                            height: rowHeight,
                            compacto: compacto,
                            dia: _diasOrdem[i],
                            data: datasDaSemana[i],
                            horario: linhas[index].horario,
                            turno: linhas[index].turno,
                            periodo: linhas[index].periodo,
                            isLastDay: i == _diasOrdem.length - 1,
                            aula: gradePorDiaTurnoPeriodo[_diasOrdem[i]]?[
                              _turnoPeriodoKey(linhas[index].turno, linhas[index].periodo)
                            ],
                            onTap: gradePorDiaTurnoPeriodo[_diasOrdem[i]]?[
                                      _turnoPeriodoKey(linhas[index].turno, linhas[index].periodo)
                                    ] ==
                                    null
                                ? () async {
                                    final callback = onTapLivre;
                                    if (callback == null) return;
                                    await callback(
                                      _AgendaCellTapData(
                                        data: datasDaSemana[i],
                                        horarioFaixa: linhas[index].horario,
                                        turno: linhas[index].turno,
                                        periodo: linhas[index].periodo,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Map<String, Map<String, HorarioAula>> _buildGradePorDiaTurnoPeriodo(
    List<_AgendaGridRow> linhas,
  ) {
    final grade = {
      for (final dia in _diasOrdem) dia: <String, HorarioAula>{},
    };

    for (final aula in horarios) {
      final dia = _abreviarDia(aula.diaSemana);
      if (dia == null) continue;

      for (final linha in linhas) {
        if (!_aulaSobrepoeFaixa(aula, linha.horario)) continue;
        grade[dia]!.putIfAbsent(
          _turnoPeriodoKey(linha.turno, linha.periodo),
          () => aula,
        );
      }
    }

    return grade;
  }

  List<_AgendaGridRow> _gerarLinhasGrade() {
    return [
      for (final turno in _AgendaTurno.values)
        for (var periodo = 1; periodo <= turno.horarios.length; periodo++)
          _AgendaGridRow(
            turno: turno,
            periodo: periodo,
            horario: turno.horarioDo(periodo),
          ),
    ];
  }

  String _turnoPeriodoKey(_AgendaTurno turno, int periodo) => '${turno.name}|$periodo';

  bool _aulaSobrepoeFaixa(HorarioAula aula, String faixa) {
    final inicioAula = _toMinutes(aula.inicio);
    final fimAula = _toMinutes(aula.fim);
    final partes = faixa.split('-');
    if (partes.length != 2) return false;
    final inicioFaixa = _toMinutes(partes[0].trim());
    final fimFaixa = _toMinutes(partes[1].trim());

    if (inicioAula == null || fimAula == null || inicioFaixa == null || fimFaixa == null) {
      return false;
    }
    if (fimAula <= inicioAula || fimFaixa <= inicioFaixa) {
      return false;
    }

    return inicioAula < fimFaixa && inicioFaixa < fimAula;
  }

  int? _toMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0].trim());
    final minute = int.tryParse(parts[1].trim());
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }

  List<DateTime> _datasDaSemanaAtual() {
    final hoje = DateTime.now();
    final inicioDaSemana = hoje.subtract(Duration(days: hoje.weekday - DateTime.monday));
    return List<DateTime>.generate(5, (index) => inicioDaSemana.add(Duration(days: index)));
  }

  String _descricaoSemanaAtual() {
    final hoje = DateTime.now();
    final inicioDaSemana = hoje.subtract(Duration(days: hoje.weekday - DateTime.monday));
    final fimDaSemana = inicioDaSemana.add(const Duration(days: 4));
    if (inicioDaSemana.month == fimDaSemana.month) {
      return '${_pad2(inicioDaSemana.day)} a ${_pad2(fimDaSemana.day)}';
    }
    return '${_pad2(inicioDaSemana.day)}/${_pad2(inicioDaSemana.month)} a ${_pad2(fimDaSemana.day)}/${_pad2(fimDaSemana.month)}';
  }

  String _diaSemanaAbreviado(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Seg';
      case DateTime.tuesday:
        return 'Ter';
      case DateTime.wednesday:
        return 'Qua';
      case DateTime.thursday:
        return 'Qui';
      case DateTime.friday:
        return 'Sex';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '-';
    }
  }

  String _diaSemanaCompleto(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'segunda-feira';
      case DateTime.tuesday:
        return 'terca-feira';
      case DateTime.wednesday:
        return 'quarta-feira';
      case DateTime.thursday:
        return 'quinta-feira';
      case DateTime.friday:
        return 'sexta-feira';
      case DateTime.saturday:
        return 'sabado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return 'dia invalido';
    }
  }

  String _pad2(int value) => value.toString().padLeft(2, '0');

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

class _AgendaGridRow {
  const _AgendaGridRow({
    required this.turno,
    required this.periodo,
    required this.horario,
  });

  final _AgendaTurno turno;
  final int periodo;
  final String horario;
}

enum _AgendaTurno {
  matutino('Matutino'),
  vespertino('Tarde'),
  noturno('Noite');

  const _AgendaTurno(this.label);

  final String label;

  String get shortLabel {
    switch (this) {
      case _AgendaTurno.matutino:
        return 'M';
      case _AgendaTurno.vespertino:
        return 'T';
      case _AgendaTurno.noturno:
        return 'N';
    }
  }

  Color get chipBackground {
    switch (this) {
      case _AgendaTurno.matutino:
        return SigadColors.successSoft.withValues(alpha: 0.85);
      case _AgendaTurno.vespertino:
        return SigadColors.accentSoft.withValues(alpha: 0.85);
      case _AgendaTurno.noturno:
        return SigadColors.surfaceAlt;
    }
  }

  Color get chipTextColor {
    switch (this) {
      case _AgendaTurno.matutino:
        return SigadColors.success;
      case _AgendaTurno.vespertino:
        return SigadColors.warning;
      case _AgendaTurno.noturno:
        return SigadColors.brandDark;
    }
  }

  List<String> get horarios {
    switch (this) {
      case _AgendaTurno.matutino:
        return const ['07:15-08:05', '08:05-08:55', '08:55-09:45', '09:45-10:35', '10:50-11:40', '11:40-12:30'];
      case _AgendaTurno.vespertino:
        return const ['13:10-14:00', '14:00-14:50', '14:50-15:40', '15:55-16:45', '16:45-17:35', '17:35-18:25'];
      case _AgendaTurno.noturno:
        return const ['18:30-19:20', '19:20-20:10', '20:30-21:15', '21:15-22:00', '22:00-22:45'];
    }
  }

  String horarioDo(int periodo) {
    if (periodo < 1 || periodo > horarios.length) return 'Horario indefinido';
    return horarios[periodo - 1];
  }
}

class _TurnoAgendaDividerRow extends StatelessWidget {
  const _TurnoAgendaDividerRow({
    required this.turno,
  });

  final _AgendaTurno turno;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: turno.chipBackground,
        border: const Border(
          top: BorderSide(color: SigadColors.divider),
          bottom: BorderSide(color: SigadColors.divider),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: turno.chipTextColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            turno.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: turno.chipTextColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _GradeAgendaCell extends StatelessWidget {
  const _GradeAgendaCell({
    required this.height,
    required this.compacto,
    required this.dia,
    required this.data,
    required this.horario,
    required this.turno,
    required this.periodo,
    required this.isLastDay,
    required this.aula,
    this.onTap,
  });

  final double height;
  final bool compacto;
  final String dia;
  final DateTime data;
  final String horario;
  final _AgendaTurno turno;
  final int periodo;
  final bool isLastDay;
  final HorarioAula? aula;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final livre = aula == null;
    final tone = livre ? SigadColors.success : SigadColors.warning;
    final background = livre
        ? SigadColors.successSoft.withValues(alpha: 0.55)
        : SigadColors.accentSoft.withValues(alpha: 0.70);
    final cellPadding = compacto
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 5);
    final chipPadding = compacto
        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5)
        : const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
    final iconSize = compacto ? 12.0 : 14.0;
    final statusLabel = livre ? 'Livre' : (compacto ? 'Aula' : 'Ocupado');
    final headerTextStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: SigadColors.brandDark,
          fontWeight: FontWeight.w700,
          fontSize: compacto ? 9.5 : 10.5,
        );
    final chipTextStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: turno.chipTextColor,
          fontWeight: FontWeight.w700,
          fontSize: compacto ? 8.5 : 9.5,
        );
    final horarioTextStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: SigadColors.muted,
          fontWeight: FontWeight.w600,
          fontSize: compacto ? 8.8 : 9.8,
        );
    final statusTextStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: tone,
          fontSize: compacto ? 9.0 : 10.0,
        );
    final detailsPrimaryStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: SigadColors.brandDark,
          fontWeight: FontWeight.w600,
          fontSize: 9.2,
        );
    final detailsSecondaryStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: SigadColors.muted,
          fontSize: 8.8,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          padding: cellPadding,
          decoration: BoxDecoration(
            color: background,
            border: Border(
              top: const BorderSide(color: SigadColors.divider),
              right: BorderSide(
                color: isLastDay ? Colors.transparent : SigadColors.divider,
              ),
              bottom: BorderSide(
                color: tone.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        compacto ? '$dia ${data.day}' : '$dia · ${data.day}',
                        style: headerTextStyle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: chipPadding,
                    decoration: BoxDecoration(
                      color: turno.chipBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${turno.shortLabel}$periodo',
                      style: chipTextStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  horario,
                  style: horarioTextStyle,
                ),
              ),
              const SizedBox(height: 1),
              Flexible(
                child: Row(
                  children: [
                    Icon(
                      livre ? Icons.check_circle_outline : Icons.event_busy_outlined,
                      size: iconSize,
                      color: tone,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          statusLabel,
                          style: statusTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!livre) ...[
                const SizedBox(height: 1),
                if (!compacto && aula!.disciplina != null && aula!.disciplina!.isNotEmpty)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        aula!.disciplina!,
                        style: detailsPrimaryStyle,
                      ),
                    ),
                  ),
                if (!compacto && aula!.turma != null && aula!.turma!.isNotEmpty)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        aula!.turma!,
                        style: detailsSecondaryStyle,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AgendaCellTapData {
  const _AgendaCellTapData({
    required this.data,
    required this.horarioFaixa,
    required this.turno,
    required this.periodo,
  });

  final DateTime data;
  final String horarioFaixa;
  final _AgendaTurno turno;
  final int periodo;
}

class _HorarioTile extends StatelessWidget {
  const _HorarioTile({required this.horario, required this.textTheme, required this.onDelete});
  final HorarioAula horario;
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

