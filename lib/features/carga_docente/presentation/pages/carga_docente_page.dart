import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../configuracoes/data/configuracoes_repository.dart';
import '../../../configuracoes/domain/configuracoes_models.dart';
import '../../../configuracoes/domain/configuracoes_service.dart';
import '../../data/docente_repository.dart';
import '../../domain/docente_models.dart';
import '../../domain/docente_visibility_service.dart';
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
  static const Set<UserRole> _allowedRoles = {
    UserRole.professor,
    UserRole.coordenador,
    UserRole.servidorAdministrativo,
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
    _loadData();
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

  List<Docente> _docentesVisiveis(
    UserRole role, {
    String? currentUserId,
    String? emailUsuario,
  }) {
    return DocenteVisibilityService.filterDocentesForRole<Docente>(
      role: role,
      docentes: _docentes,
      currentUserId: currentUserId,
      currentUserEmail: emailUsuario,
      getUserId: (docente) => docente.userId,
      getUserEmail: (docente) => docente.userEmail,
    );
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

    final podeGerenciar = role == UserRole.coordenador || role == UserRole.chefeDepartamento;
    final podeVisualizarHorarios = role == UserRole.professor || podeGerenciar;
    final emailNormalizado = (user?.email ?? '').trim().toLowerCase();
    final docentesVisiveis = _docentesVisiveis(
      role,
      currentUserId: user?.id,
      emailUsuario: user?.email,
    );
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showNovoCompromissoAgenda(context, user?.id ?? ''),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Novo compromisso na agenda'),
              ),
            ),
          ),
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
                canViewSchedule: podeVisualizarHorarios,
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
    required this.canViewSchedule,
    required this.onEditar,
    required this.onExcluir,
  });

  final Docente docente;
  final bool canManage;
  final bool canViewSchedule;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  State<_DocenteCard> createState() => _DocenteCardState();
}

class _DocenteCardState extends State<_DocenteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final docente = widget.docente;
    final podeVisualizarHorarios = widget.canViewSchedule && docente.horariosAula.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: podeVisualizarHorarios,
          label: 'Docente ${docente.nome}. Carga horária ${docente.cargaHoraria} horas.',
          hint: podeVisualizarHorarios ? 'Toque para expandir distribuição semanal.' : null,
          child: GestureDetector(
            onTap: podeVisualizarHorarios ? () => setState(() => _isExpanded = !_isExpanded) : null,
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
                      if (podeVisualizarHorarios)
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: SigadColors.muted,
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
                  if (_isExpanded && podeVisualizarHorarios && docente.horariosAula.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Divider(color: SigadColors.divider.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'Distribuição semanal',
                      style: textTheme.labelSmall?.copyWith(
                        color: SigadColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _MapaSemanalHorarios(
                      horarios: docente.horariosAula,
                      compacto: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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

  final List<HorarioAula> horarios;
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

  Map<String, List<HorarioAula>> _agruparPorDia() {
    final agrupado = {
      for (final dia in _diasOrdem) dia: <HorarioAula>[],
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
  final List<HorarioAula> horarios;
  final bool compacto;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final temAulas = horarios.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: temAulas
                        ? SigadColors.brand.withValues(alpha: 0.12)
                        : SigadColors.divider.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dia,
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: temAulas ? SigadColors.brand : SigadColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (!temAulas)
                  Text(
                    '-',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                  )
                else
                  Column(
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

