import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../../configuracoes/data/agenda_convites_service.dart';
import '../../data/docente_repository.dart';
import '../../domain/docente_form_service.dart';
import '../../domain/docente_models.dart';
import '../controllers/docente_form_controller.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../l10n/l10n.dart';
import '../../../aulas_praticas/presentation/laboratorio_l10n.dart';
import '../carga_docente_l10n.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../shared/widgets/icon_avatar.dart';

class CargaDocentePage extends StatefulWidget {
  final Docente? docente;
  const CargaDocentePage({super.key, this.docente});

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

  final List<Docente> _docentes = [
    Docente(
      id: '#DOC-001',
      nome: 'Docente 01',
      userId: 'user_email_docente01@exemplo.edu.br',
      userEmail: 'docente01@exemplo.edu.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 20,
      cargaMaxima: 20,
      disciplinas: [
        'Programação I',
        'Programação II',
        'Engenharia de Software',
      ],
      horariosAula: const [
        HorarioAula(
          diaSemana: 'Segunda',
          inicio: '08:00',
          fim: '09:40',
          disciplina: 'Circuitos Elétricos I',
          cargaHoraria: '2h/sem · 80h',
          turma: 'EE-2A',
          modalidade: 'Integral',
        ),
        HorarioAula(
          diaSemana: 'Quarta',
          inicio: '10:00',
          fim: '11:40',
          disciplina: 'Circuitos Elétricos II',
          cargaHoraria: '2h/sem · 80h',
          turma: 'EE-2B',
          modalidade: 'Concomitante',
        ),
        HorarioAula(
          diaSemana: 'Sexta',
          inicio: '19:00',
          fim: '20:40',
          disciplina: 'Engenharia de Software',
          cargaHoraria: '4h/sem · 120h',
          turma: 'EE-3A',
          modalidade: 'Superior',
        ),
      ],
    ),
    Docente(
      id: '#DOC-002',
      nome: 'Docente 02',
      userId: 'user_email_docente02@exemplo.edu.br',
      userEmail: 'docente02@exemplo.edu.br',
      departamento: 'Sistemas de Informação',
      cargaHoraria: 16,
      cargaMaxima: 20,
      disciplinas: ['Sistemas de Comunicação', 'Redes de Telecomunicações'],
      horariosAula: const [
        HorarioAula(
          diaSemana: 'Terça',
          inicio: '08:00',
          fim: '09:40',
          disciplina: 'Sistemas de Comunicação',
          cargaHoraria: '4h/sem · 120h',
          turma: 'EE-3A',
          modalidade: 'Subsequente',
        ),
        HorarioAula(
          diaSemana: 'Quinta',
          inicio: '08:00',
          fim: '09:40',
          disciplina: 'Redes de Telecomunicações',
          cargaHoraria: '2h/sem · 60h',
          turma: 'EE-2A',
          modalidade: 'EJA',
        ),
      ],
    ),
    Docente(
      id: '#DOC-003',
      nome: 'Docente 03',
      userId: 'user_email_docente03@exemplo.edu.br',
      userEmail: 'docente03@exemplo.edu.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 12,
      cargaMaxima: 20,
      disciplinas: ['Máquinas Elétricas'],
      horariosAula: const [
        HorarioAula(
          diaSemana: 'Segunda',
          inicio: '14:00',
          fim: '15:40',
          disciplina: 'Máquinas Elétricas',
          cargaHoraria: '2h/sem · 60h',
          turma: 'ELET-3B',
          modalidade: 'Integral',
        ),
        HorarioAula(
          diaSemana: 'Quarta',
          inicio: '14:00',
          fim: '15:40',
          disciplina: 'Máquinas Elétricas',
          cargaHoraria: '2h/sem · 60h',
          turma: 'ELET-3B',
          modalidade: 'Integral',
        ),
      ],
    ),
    Docente(
      id: '#DOC-004',
      nome: 'Docente 04',
      userId: 'user_email_docente04@exemplo.edu.br',
      userEmail: 'docente04@exemplo.edu.br',
      departamento: 'Telecomunicações',
      cargaHoraria: 18,
      cargaMaxima: 20,
      disciplinas: ['Redes I', 'Redes II', 'Segurança de Redes'],
      horariosAula: const [
        HorarioAula(
          diaSemana: 'Terça',
          inicio: '19:00',
          fim: '20:40',
          disciplina: 'Redes I',
          cargaHoraria: '2h/sem · 60h',
          turma: 'RT-2A',
          modalidade: 'Subsequente',
        ),
        HorarioAula(
          diaSemana: 'Quinta',
          inicio: '19:00',
          fim: '20:40',
          disciplina: 'Redes II',
          cargaHoraria: '2h/sem · 80h',
          turma: 'RT-3A',
          modalidade: 'Concomitante',
        ),
        HorarioAula(
          diaSemana: 'Sexta',
          inicio: '21:00',
          fim: '22:40',
          disciplina: 'Segurança de Redes',
          cargaHoraria: '4h/sem · 120h',
          turma: 'RT-4A',
          modalidade: 'Superior',
        ),
      ],
    ),
    Docente(
      id: '#DOC-005',
      nome: 'Docente 05',
      userId: 'user_email_docente05@exemplo.edu.br',
      userEmail: 'docente05@exemplo.edu.br',
      departamento: 'Engenharia de Software',
      cargaHoraria: 14,
      cargaMaxima: 20,
      disciplinas: ['Eletrônica de Potência'],
      horariosAula: const [
        HorarioAula(
          diaSemana: 'Terça',
          inicio: '10:00',
          fim: '11:40',
          disciplina: 'Eletrônica de Potência',
          cargaHoraria: '2h/sem · 60h',
          turma: 'ELE-4A',
          modalidade: 'EJA',
        ),
        HorarioAula(
          diaSemana: 'Quinta',
          inicio: '10:00',
          fim: '11:40',
          disciplina: 'Eletrônica de Potência',
          cargaHoraria: '2h/sem · 60h',
          turma: 'ELE-4B',
          modalidade: 'Integral',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Se vier argumento via construtor, já define o docente selecionado
    if (widget.docente != null) {
      _docenteSelecionado = widget.docente;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    AppFeedbackService.info(context, context.l10n.erroDocente(mensagem));
  }

  void _showAdicionarDocente(BuildContext context) {
    final controller = DocenteFormController.createNew();

    _showDocenteFormSheet(
      context: context,
      title: context.l10n.cdNovoDocente,
      confirmLabel: context.l10n.cdAdicionar,
      controller: controller,
      onSubmit: () {
        final erro = controller.validate();
        if (erro != null) {
          _mostrarFeedback(erro);
          return false;
        }

        setState(() {
          _docentes.insert(
            0,
            controller.buildNewDocente(_gerarProximoIdDocente()),
          );
        });
        _saveData();
        AppEventLogger.action(
          'carga_docente_add_docente',
          details: {
            'nome': controller.nomeController.text.trim(),
            'qtdDisciplinas': controller.disciplinas.length,
            'qtdHorarios': controller.horarios.length,
          },
        );
        _mostrarFeedback(context.l10n.cdDocenteAdicionado);
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final textTheme = Theme.of(context).textTheme;
          return PopScope(
            onPopInvokedWithResult: (_, _) => controller.dispose(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.cdFecharFormulario,
                          onPressed: () => Navigator.pop(context),
                          icon: const SigadIcon(SigadIcons.fechar),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.nomeController,
                      decoration: InputDecoration(
                        labelText: context.l10n.cdNomeCompleto,
                        hintText: context.l10n.cdNomeDica,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: context.l10n.cdEmailAcesso,
                        hintText: 'docente@exemplo.edu.br',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.departamentoController,
                      decoration: InputDecoration(
                        labelText: context.l10n.cdDepartamento,
                        hintText: context.l10n.cdDepartamentoDica,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.cargaMaximaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.l10n.cdCargaMaxima,
                        hintText: 'Ex: 20',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RegimeTrabalhoEbtt>(
                      initialValue: controller.regimeTrabalho,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.cdRegimeEbtt,
                      ),
                      items: RegimeTrabalhoEbtt.values
                          .map(
                            (regime) => DropdownMenuItem<RegimeTrabalhoEbtt>(
                              value: regime,
                              child: Text(
                                context.l10n.cdRegimeOpcao(
                                  context.l10n.regime(regime),
                                  regime.code,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => controller.regimeTrabalho = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SigadColors.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SigadColors.info.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.cdDistribuicaoAulasSemana(
                              DocenteFormService.calcularCargaHorariaSemanal(
                                controller.horarios,
                              ),
                            ),
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.cdRegimeLimite(
                              controller.regimeTrabalho.code,
                              controller.regimeTrabalho.cargaSemanalLimite,
                            ),
                            style: textTheme.bodySmall?.copyWith(
                              color: SigadColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.cdDisciplinas,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...controller.disciplinas.map(
                          (d) => Chip(
                            label: Text(d),
                            onDeleted: () => setModalState(
                              () => controller.removeDisciplina(d),
                            ),
                          ),
                        ),
                        ActionChip(
                          label: Text(context.l10n.cdAdicionar),
                          onPressed: () => _showAdicionarDisciplina(
                            context,
                            controller,
                            setModalState,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.cdHorariosAula,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton.icon(
                          icon: const SigadIcon(SigadIcons.adicionar, size: 16),
                          label: Text(context.l10n.cdAdicionar),
                          onPressed: () => _showAdicionarHorario(
                            context,
                            controller,
                            setModalState,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (controller.horarios.isEmpty)
                      Text(
                        context.l10n.cdNenhumHorario,
                        style: textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      )
                    else
                      ...controller.horarios.map(
                        (h) => _HorarioTile(
                          horario: h,
                          textTheme: textTheme,
                          onDelete: () =>
                              setModalState(() => controller.removeHorario(h)),
                        ),
                      ),
                    if (controller.horarios.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.cdCargaDistribuida(
                          DocenteFormService.calcularCargaHorariaSemanal(
                            controller.horarios,
                          ),
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          color: SigadColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(context.l10n.cancelar),
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
          );
        },
      ),
    );
  }

  void _showAdicionarDisciplina(
    BuildContext context,
    DocenteFormController controller,
    StateSetter setState,
  ) {
    final disciplinaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.cdAdicionarDisciplina),
        content: TextField(
          controller: disciplinaController,
          decoration: InputDecoration(
            labelText: context.l10n.cdNomeDisciplina,
            hintText: context.l10n.cdExemploDisciplina,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelar),
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
            child: Text(context.l10n.cdAdicionar),
          ),
        ],
      ),
    );
  }

  void _showAdicionarHorario(
    BuildContext context,
    DocenteFormController controller,
    StateSetter setModalState,
  ) {
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
          title: Text(context.l10n.cdAdicionarHorario),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: diaSelecionado,
                  decoration: InputDecoration(
                    labelText: context.l10n.cdDiaSemana,
                  ),
                  items: _diasSemana
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(context.l10n.diaDocente(d)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() => diaSelecionado = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inicioController,
                        decoration: InputDecoration(
                          labelText: context.l10n.cdInicio,
                          hintText: '08:00',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: fimController,
                        decoration: InputDecoration(
                          labelText: context.l10n.cdFim,
                          hintText: '09:40',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: disciplinaController,
                  decoration: InputDecoration(
                    labelText: context.l10n.cdDisciplina,
                    hintText: context.l10n.cdExemploDisciplina,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cargaController,
                  decoration: InputDecoration(
                    labelText: context.l10n.cdCargaHoraria,
                    hintText: context.l10n.cdExemploCarga,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: turmaController,
                  decoration: InputDecoration(
                    labelText: context.l10n.cdTurma,
                    hintText: 'Ex: ES-2A',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: modalidadeSelecionada,
                  decoration: InputDecoration(
                    labelText: context.l10n.cdModalidade,
                  ),
                  items: _modalidades
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(context.l10n.modalidade(m)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => modalidadeSelecionada = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancelar),
            ),
            TextButton(
              onPressed: () {
                final inicio = inicioController.text.trim();
                final fim = fimController.text.trim();
                final erro = controller.validateHorario(
                  diaSemana: diaSelecionado,
                  inicio: inicio,
                  fim: fim,
                );
                if (erro != null) {
                  _mostrarFeedback(erro);
                  return;
                }

                setModalState(
                  () => controller.addHorario(
                    controller.createHorario(
                      diaSemana: diaSelecionado,
                      inicio: inicio,
                      fim: fim,
                      disciplina: disciplinaController.text,
                      cargaHoraria: cargaController.text,
                      turma: turmaController.text,
                      modalidade: modalidadeSelecionada,
                    ),
                  ),
                );
                AppEventLogger.action(
                  'carga_docente_add_horario',
                  details: {
                    'diaSemana': diaSelecionado,
                    'inicio': inicio,
                    'fim': fim,
                  },
                );
                Navigator.pop(context);
              },
              child: Text(context.l10n.cdAdicionar),
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
      title: context.l10n.cdEditarDocente,
      confirmLabel: context.l10n.salvar,
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
        AppEventLogger.action(
          'carga_docente_edit_docente',
          details: {
            'docenteId': docente.id,
            'nome': controller.nomeController.text.trim(),
            'qtdHorarios': controller.horarios.length,
          },
        );
        _mostrarFeedback(context.l10n.cdDocenteAtualizado);
        return true;
      },
    );
  }

  void _showConfirmarExclusao(BuildContext context, Docente docente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.demConfirmarExclusao),
        content: Text(context.l10n.cdExcluirMensagem(docente.nome)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelar),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _docentes.removeWhere((item) => item.id == docente.id);
              });
              _saveData();
              AppEventLogger.action(
                'carga_docente_remove_docente',
                details: {'docenteId': docente.id, 'nome': docente.nome},
              );
              Navigator.pop(context);
              _mostrarFeedback(context.l10n.cdDocenteExcluido);
            },
            child: Text(
              context.l10n.excluir,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirAgendaDocente(BuildContext context, Docente docente) {
    final userContext = context.read<UserContextProvider>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: _AgendaDocentePage(docente: docente),
        ),
      ),
    );
  }

  double _percentualOcupacao(Docente docente) {
    if (docente.cargaMaxima <= 0) return 0;
    return docente.cargaHoraria / docente.cargaMaxima;
  }

  List<Docente> _docentesComAltaCarga(List<Docente> docentes) {
    return docentes
        .where((docente) => _percentualOcupacao(docente) >= 0.9)
        .toList(growable: false);
  }

  List<Docente> _docentesComBaixaCarga(List<Docente> docentes) {
    return docentes
        .where((docente) => _percentualOcupacao(docente) <= 0.5)
        .toList(growable: false);
  }

  List<String> _gerarSugestoesDistribuicao(List<Docente> docentes) {
    final l10n = context.l10n;
    final altaCarga = _docentesComAltaCarga(docentes);
    final baixaCarga = _docentesComBaixaCarga(docentes);

    if (altaCarga.isEmpty && baixaCarga.isEmpty) {
      return [l10n.cdSugestaoEquilibrada];
    }

    final sugestoes = <String>[];

    if (altaCarga.isNotEmpty) {
      final nomes = altaCarga
          .take(2)
          .map((docente) => docente.nome.split(' ').first)
          .join(', ');
      sugestoes.add(l10n.cdSugestaoPressao(nomes));
    }

    if (baixaCarga.isNotEmpty) {
      final nomes = baixaCarga
          .take(2)
          .map((docente) => docente.nome.split(' ').first)
          .join(', ');
      sugestoes.add(l10n.cdSugestaoOciosa(nomes));
    }

    sugestoes.add(l10n.cdSugestaoRevisao);

    return sugestoes;
  }

  Future<void> _abrirSimulacaoRedistribuicao() async {
    final simulacao = DocenteFormService.simularRedistribuicaoDocentes(
      _docentesVisiveis(),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SimulacaoRedistribuicaoSheet(
        resultado: simulacao,
        onAplicar: simulacao.propostas.isEmpty
            ? null
            : () {
                _aplicarRedistribuicao(simulacao.propostas);
                Navigator.pop(context);
              },
      ),
    );
  }

  void _aplicarRedistribuicao(List<PropostaRedistribuicao> propostas) {
    if (propostas.isEmpty) return;

    final atualizados = List<Docente>.from(_docentes);

    for (final proposta in propostas) {
      final origemIndex = atualizados.indexWhere(
        (docente) => docente.id == proposta.docenteOrigemId,
      );
      final destinoIndex = atualizados.indexWhere(
        (docente) => docente.id == proposta.docenteDestinoId,
      );
      if (origemIndex < 0 || destinoIndex < 0) continue;

      final origem = atualizados[origemIndex];
      final destino = atualizados[destinoIndex];

      final horario = _encontrarHorarioTransferencia(
        origem.horariosAula,
        proposta.horario,
      );
      if (horario == null) continue;

      final horariosOrigem = List<HorarioAula>.from(origem.horariosAula)
        ..remove(horario);
      final horariosDestino = List<HorarioAula>.from(destino.horariosAula)
        ..add(horario);

      atualizados[origemIndex] = origem.copyWith(
        horariosAula: horariosOrigem,
        cargaHoraria: DocenteFormService.calcularCargaHorariaSemanal(
          horariosOrigem,
        ),
      );

      atualizados[destinoIndex] = destino.copyWith(
        horariosAula: horariosDestino,
        cargaHoraria: DocenteFormService.calcularCargaHorariaSemanal(
          horariosDestino,
        ),
      );
    }

    setState(() {
      _docentes
        ..clear()
        ..addAll(atualizados);
    });

    _saveData();
    AppEventLogger.action(
      'carga_docente_apply_redistribuicao',
      details: {'qtdPropostas': propostas.length},
    );
    _mostrarFeedback(context.l10n.cdRedistribuicoesAplicadas(propostas.length));
  }

  HorarioAula? _encontrarHorarioTransferencia(
    List<HorarioAula> horarios,
    HorarioAula referencia,
  ) {
    for (final horario in horarios) {
      if (horario.diaSemana == referencia.diaSemana &&
          horario.inicio == referencia.inicio &&
          horario.fim == referencia.fim &&
          horario.disciplina == referencia.disciplina) {
        return horario;
      }
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
    final podeGerenciar =
        role == UserRole.coordenador || role == UserRole.chefeDepartamento;
    final podeVisualizarHorarios = true; // Todos podem visualizar
    final emailNormalizado = (user?.email ?? '').trim().toLowerCase();
    final docentesVisiveis = _docentesVisiveis();
    // Filtro de busca
    List<Docente> docentesFiltrados;
    if (podeGerenciar) {
      // Coordenador e chefe veem todos, independentemente da rota de entrada.
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
      final self = docentesVisiveis
          .where(
            (d) => (d.userEmail ?? '').trim().toLowerCase() == emailNormalizado,
          )
          .toList();
      if (!isSearching) {
        docentesFiltrados = self;
      } else {
        final buscaLower = _busca.toLowerCase();
        final outros = docentesVisiveis
            .where(
              (d) =>
                  (d.nome.toLowerCase().contains(buscaLower) ||
                  (d.userEmail ?? '').toLowerCase().contains(buscaLower) ||
                  d.departamento.toLowerCase().contains(buscaLower)),
            )
            .toList();
        // Garante que o próprio sempre aparece primeiro, sem duplicar
        final outrosSemSelf = outros
            .where(
              (d) =>
                  (d.userEmail ?? '').trim().toLowerCase() != emailNormalizado,
            )
            .toList();
        docentesFiltrados = [...self, ...outrosSemSelf];
      }
    }
    final docentesOrdenados = docentesFiltrados;
    final textTheme = Theme.of(context).textTheme;
    final docentesBasePainel = _docentesVisiveis();
    final altaCarga = _docentesComAltaCarga(docentesBasePainel);
    final baixaCarga = _docentesComBaixaCarga(docentesBasePainel);
    final mediaOcupacao = docentesBasePainel.isEmpty
        ? 0.0
        : docentesBasePainel.map(_percentualOcupacao).reduce((a, b) => a + b) /
              docentesBasePainel.length;
    final sugestoesDistribuicao = _gerarSugestoesDistribuicao(
      docentesBasePainel,
    );

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
                onEditar: podeGerenciar
                    ? () => _showEditarDocente(context, selfDocente!)
                    : null,
                onExcluir: podeGerenciar
                    ? () => _showConfirmarExclusao(context, selfDocente!)
                    : null,
                somenteVisualizar: !podeGerenciar,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _buscaController,
              onChanged: (value) => setState(() => _busca = value),
              decoration: InputDecoration(
                hintText: context.l10n.cdBuscarDocente,
                prefixIcon: SigadIcon(SigadIcons.buscar),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _PainelDistribuicaoInteligente(
              mediaOcupacao: mediaOcupacao,
              docentesAltaCarga: altaCarga.length,
              docentesBaixaCarga: baixaCarga.length,
              sugestoes: sugestoesDistribuicao,
              onSimularRedistribuicao: _abrirSimulacaoRedistribuicao,
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                // Lista de outros docentes (exclui o próprio)
                final outrosDocentes = selfDocente == null
                    ? docentesOrdenados
                    : docentesOrdenados
                          .where((d) => d.id != selfDocente!.id)
                          .toList();
                if (outrosDocentes.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SigadIcon(
                            SigadIcons.pessoa,
                            size: 64,
                            color: SigadColors.muted.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.cdNenhumDocente,
                            style: textTheme.bodyLarge?.copyWith(
                              color: SigadColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: outrosDocentes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _DocenteCard(
                    docente: outrosDocentes[index],
                    canManage: podeGerenciar,
                    canViewSchedule: podeVisualizarHorarios,
                    onAbrirAgenda: () =>
                        _abrirAgendaDocente(context, outrosDocentes[index]),
                    onEditar: podeGerenciar
                        ? () =>
                              _showEditarDocente(context, outrosDocentes[index])
                        : null,
                    onExcluir: podeGerenciar
                        ? () => _showConfirmarExclusao(
                            context,
                            outrosDocentes[index],
                          )
                        : null,
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
              tooltip: context.l10n.cdAdicionarDocente,
              backgroundColor: SigadColors.brand,
              child: const SigadIcon(SigadIcons.adicionar),
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
  final VoidCallback? onAbrirAgenda;
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
              if (canManage && !somenteVisualizar)
                PopupMenuButton<String>(
                  tooltip: context.l10n.cdMaisAcoes,
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
                    PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          SigadIcon(SigadIcons.editar, size: 18),
                          SizedBox(width: 8),
                          Text(context.l10n.demEditarAcao),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          SigadIcon(SigadIcons.excluir, size: 18),
                          SizedBox(width: 8),
                          Text(context.l10n.excluir),
                        ],
                      ),
                    ),
                  ],
                ),
              // Exibe o nome do docente como Text
              Expanded(
                child: GestureDetector(
                  onTap: onAbrirAgenda,
                  child: Text(
                    docente.nome,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.cdRegimeDocente(
              context.l10n.regime(docente.regimeTrabalho),
              docente.regimeTrabalho.code,
            ),
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.cdDistribuicaoAulas(
              docente.cargaHoraria,
              docente.cargaMaxima,
            ),
            style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: docente.disciplinas
                .asMap()
                .entries
                .map(
                  (entry) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sigadToneForIndex(
                        entry.key,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.value,
                      style: textTheme.labelSmall?.copyWith(
                        color: sigadToneForIndex(entry.key),
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

class _PainelDistribuicaoInteligente extends StatelessWidget {
  const _PainelDistribuicaoInteligente({
    required this.mediaOcupacao,
    required this.docentesAltaCarga,
    required this.docentesBaixaCarga,
    required this.sugestoes,
    required this.onSimularRedistribuicao,
  });

  final double mediaOcupacao;
  final int docentesAltaCarga;
  final int docentesBaixaCarga;
  final List<String> sugestoes;
  final VoidCallback onSimularRedistribuicao;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mediaPercentual = (mediaOcupacao * 100)
        .clamp(0, 999)
        .toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SigadIconAvatar(
                icon: SigadIcons.ajustes,
                tone: SigadColors.brand,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.cdOtimizacao,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onSimularRedistribuicao,
                icon: const SigadIcon(SigadIcons.tendencia, size: 16),
                label: Text(context.l10n.cdSimular),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$mediaPercentual%',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SigadColors.brand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.cdAproveitamentoMedio,
                  style: textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _KpiChip(
                label: context.l10n.cdOcupacaoMedia,
                value: '$mediaPercentual%',
              ),
              _KpiChip(
                label: context.l10n.cdAltaCarga,
                value: '$docentesAltaCarga',
              ),
              _KpiChip(
                label: context.l10n.cdBaixaCarga,
                value: '$docentesBaixaCarga',
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...sugestoes
              .take(3)
              .map(
                (sugestao) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $sugestao',
                    style: textTheme.bodySmall?.copyWith(
                      color: SigadColors.ink,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SimulacaoRedistribuicaoSheet extends StatelessWidget {
  const _SimulacaoRedistribuicaoSheet({
    required this.resultado,
    this.onAplicar,
  });

  final ResultadoSimulacaoRedistribuicao resultado;
  final VoidCallback? onAplicar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final antes = (resultado.mediaOcupacaoAntes * 100).toStringAsFixed(1);
    final depois = (resultado.mediaOcupacaoDepois * 100).toStringAsFixed(1);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.cdSimulacao,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.cdOcupacaoPrevista(antes, depois),
              style: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
            ),
            const SizedBox(height: 12),
            if (resultado.propostas.isEmpty)
              Text(
                context.l10n.cdNenhumaRedistribuicao,
                style: textTheme.bodyMedium,
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: resultado.propostas.length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (_, index) {
                    final proposta = resultado.propostas[index];
                    return Text(
                      '${index + 1}. ${proposta.docenteOrigemNome} -> ${proposta.docenteDestinoNome} · ${proposta.horario.disciplina ?? context.l10n.cdDisciplina} · ${context.l10n.diaDocente(proposta.horario.diaSemana)} ${proposta.horario.inicio}-${proposta.horario.fim} (${context.l10n.cdHorasSemana(proposta.cargaSemanal)})',
                      style: textTheme.bodySmall,
                    );
                  },
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.fechar),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAplicar,
                    child: Text(context.l10n.cdAplicarSugestao),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: SigadColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              color: SigadColors.brandDark,
              fontWeight: FontWeight.w700,
            ),
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
            SigadIcon(
              SigadIcons.cadeado,
              size: 56,
              color: SigadColors.muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.cdAcessoRestrito,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.cdAcessoRestritoMensagem,
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

    final userContext = context.watch<UserContextProvider>();
    final user = userContext.currentUser;
    final role = userContext.userRole;
    final isSelf =
        user != null &&
        (user.email.trim().toLowerCase() ==
            (docente.userEmail ?? '').trim().toLowerCase());
    final isCoordOrChefe =
        role == UserRole.coordenador || role == UserRole.chefeDepartamento;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.cdAgendaDocente)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          14,
          horizontalPadding,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              docente.nome,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: SigadColors.brand,
              ),
            ),
            if (isSelf || isCoordOrChefe) ...[
              const SizedBox(height: 4),
              Text(
                docente.departamento,
                style: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.cdRegimeDocente(
                  context.l10n.regime(docente.regimeTrabalho),
                  docente.regimeTrabalho.code,
                ),
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.cdDistribuicaoAulas(
                  docente.cargaHoraria,
                  docente.cargaMaxima,
                ),
                style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: docente.disciplinas
                    .map(
                      (d) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              context.l10n.cdDistribuicaoSemanal,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
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
    final l10n = pageContext.l10n;
    final tituloController = TextEditingController(text: l10n.cdConviteReuniao);
    final descricaoController = TextEditingController(
      text: l10n.cdConviteEnviadoAgenda,
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
                  l10n.cdEnviarConviteReuniao,
                  style: Theme.of(
                    modalContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatarData(slot.data)} · ${slot.horarioFaixa} (${slot.turno.curtoEm(l10n)}${slot.periodo})',
                  style: Theme.of(
                    modalContext,
                  ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(
                    labelText: l10n.cdTituloConvite,
                    hintText: l10n.cdTituloConviteDica,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricaoController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.demDescricao,
                    hintText: l10n.cdDescricaoConviteDica,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: localController,
                  decoration: InputDecoration(
                    labelText: l10n.cdLocal,
                    hintText: l10n.cdLocalDica,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final inicio = _inicioSlot(slot.data, slot.horarioFaixa);
                      if (inicio == null) {
                        AppFeedbackService.info(
                          pageContext,
                          l10n.cdHorarioInvalido,
                        );
                        return;
                      }

                      final titulo = tituloController.text.trim();
                      final descricao = descricaoController.text.trim();
                      final local = localController.text.trim();
                      if (titulo.isEmpty) {
                        AppFeedbackService.info(
                          pageContext,
                          l10n.cdInformeTituloConvite,
                        );
                        return;
                      }
                      if (local.isEmpty) {
                        AppFeedbackService.info(
                          pageContext,
                          l10n.cdInformeLocalConvite,
                        );
                        return;
                      }

                      final destinatario = _destinatarioAgenda(docente);
                      await AgendaConvitesService.registrarConviteRecebido(
                        destinatarioUserId: destinatario,
                        titulo: titulo,
                        descricao: descricao.isEmpty
                            ? l10n.cdConviteEnviadoAgenda
                            : descricao,
                        inicio: _formatarDataHora(inicio),
                        inicioDateTime: inicio,
                        local: local,
                        origem: 'Convite enviado pela agenda semanal',
                      );

                      if (!pageContext.mounted) return;
                      Navigator.pop(modalContext);
                      AppFeedbackService.info(
                        pageContext,
                        l10n.cdConviteEnviado,
                      );
                    },
                    icon: const SigadIcon(SigadIcons.enviar),
                    label: Text(l10n.cdEnviarConvite),
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
  static const double _rowHeightCompact = 82;
  static const double _rowHeightRegular = 92;

  @override
  Widget build(BuildContext context) {
    final linhas = _gerarLinhasGrade();
    final gradePorDiaTurnoPeriodo = _buildGradePorDiaTurnoPeriodo(linhas);
    final rowHeight = compacto ? _rowHeightCompact : _rowHeightRegular;
    final datasDaSemana = _datasDaSemanaAtual();
    final hoje = DateTime.now();
    final l10n = context.l10n;
    final mesLabel = l10n.cdMes('${hoje.month}');
    final semanaLabel = _descricaoSemanaAtual(l10n);
    final diaSelecionadoAbreviado = _diaSemanaAbreviado(l10n, hoje.weekday);
    final diaSelecionadoCompleto = _diaSemanaCompleto(l10n, hoje.weekday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cdAgendaSemanal,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.cdSemanaDe(semanaLabel, mesLabel),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.cdDiaSelecionado(
            hoje.day,
            diaSelecionadoAbreviado,
            diaSelecionadoCompleto,
          ),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: SigadColors.surface,
                border: Border.all(color: SigadColors.divider),
              ),
              child: Column(
                children: [
                  for (var index = 0; index < linhas.length; index++) ...[
                    if (index == 0 ||
                        linhas[index - 1].turno != linhas[index].turno)
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
                              aula:
                                  gradePorDiaTurnoPeriodo[_diasOrdem[i]]?[_turnoPeriodoKey(
                                    linhas[index].turno,
                                    linhas[index].periodo,
                                  )],
                              onTap:
                                  gradePorDiaTurnoPeriodo[_diasOrdem[i]]?[_turnoPeriodoKey(
                                        linhas[index].turno,
                                        linhas[index].periodo,
                                      )] ==
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
            );
          },
        ),
      ],
    );
  }

  Map<String, Map<String, HorarioAula>> _buildGradePorDiaTurnoPeriodo(
    List<_AgendaGridRow> linhas,
  ) {
    final grade = {for (final dia in _diasOrdem) dia: <String, HorarioAula>{}};

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

  String _turnoPeriodoKey(_AgendaTurno turno, int periodo) =>
      '${turno.name}|$periodo';

  bool _aulaSobrepoeFaixa(HorarioAula aula, String faixa) {
    final inicioAula = _toMinutes(aula.inicio);
    final fimAula = _toMinutes(aula.fim);
    final partes = faixa.split('-');
    if (partes.length != 2) return false;
    final inicioFaixa = _toMinutes(partes[0].trim());
    final fimFaixa = _toMinutes(partes[1].trim());

    if (inicioAula == null ||
        fimAula == null ||
        inicioFaixa == null ||
        fimFaixa == null) {
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
    final inicioDaSemana = hoje.subtract(
      Duration(days: hoje.weekday - DateTime.monday),
    );
    return List<DateTime>.generate(
      5,
      (index) => inicioDaSemana.add(Duration(days: index)),
    );
  }

  String _descricaoSemanaAtual(AppLocalizations l10n) {
    final hoje = DateTime.now();
    final inicioDaSemana = hoje.subtract(
      Duration(days: hoje.weekday - DateTime.monday),
    );
    final fimDaSemana = inicioDaSemana.add(const Duration(days: 4));
    if (inicioDaSemana.month == fimDaSemana.month) {
      return l10n.cdIntervalo(
        _pad2(inicioDaSemana.day),
        _pad2(fimDaSemana.day),
      );
    }
    return l10n.cdIntervalo(
      '${_pad2(inicioDaSemana.day)}/${_pad2(inicioDaSemana.month)}',
      '${_pad2(fimDaSemana.day)}/${_pad2(fimDaSemana.month)}',
    );
  }

  String _diaSemanaAbreviado(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.diaSeg;
      case DateTime.tuesday:
        return l10n.diaTer;
      case DateTime.wednesday:
        return l10n.diaQua;
      case DateTime.thursday:
        return l10n.diaQui;
      case DateTime.friday:
        return l10n.diaSex;
      case DateTime.saturday:
        return l10n.cdDiaSab;
      case DateTime.sunday:
        return l10n.cdDiaDom;
      default:
        return '-';
    }
  }

  String _diaSemanaCompleto(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.diaSegunda;
      case DateTime.tuesday:
        return l10n.diaTerca;
      case DateTime.wednesday:
        return l10n.diaQuarta;
      case DateTime.thursday:
        return l10n.diaQuinta;
      case DateTime.friday:
        return l10n.diaSexta;
      case DateTime.saturday:
        return l10n.cdDiaSabado;
      case DateTime.sunday:
        return l10n.cdDiaDomingo;
      default:
        return '-';
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

  String curtoEm(AppLocalizations l10n) => switch (this) {
    _AgendaTurno.matutino => l10n.cdTurnoCurtoM,
    _AgendaTurno.vespertino => l10n.cdTurnoCurtoT,
    _AgendaTurno.noturno => l10n.cdTurnoCurtoN,
  };

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
        return const [
          '07:15-08:05',
          '08:05-08:55',
          '08:55-09:45',
          '09:45-10:35',
          '10:50-11:40',
          '11:40-12:30',
        ];
      case _AgendaTurno.vespertino:
        return const [
          '13:10-14:00',
          '14:00-14:50',
          '14:50-15:40',
          '15:55-16:45',
          '16:45-17:35',
          '17:35-18:25',
        ];
      case _AgendaTurno.noturno:
        return const [
          '18:30-19:20',
          '19:20-20:10',
          '20:30-21:15',
          '21:15-22:00',
          '22:00-22:45',
        ];
    }
  }

  String horarioDo(int periodo) {
    if (periodo < 1 || periodo > horarios.length) return '-';
    return horarios[periodo - 1];
  }
}

class _TurnoAgendaDividerRow extends StatelessWidget {
  const _TurnoAgendaDividerRow({required this.turno});

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
            switch (turno) {
              _AgendaTurno.matutino => context.l10n.turnoMatutino,
              _AgendaTurno.vespertino => context.l10n.turnoVespertino,
              _AgendaTurno.noturno => context.l10n.turnoNoturno,
            },
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
    final l10n = context.l10n;
    final statusLabel = livre
        ? l10n.cdLivre
        : (compacto ? l10n.cdAula : l10n.cdOcupado);
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
    final detailsPrimaryStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(
          color: SigadColors.brandDark,
          fontWeight: FontWeight.w600,
          fontSize: 9.2,
        );
    final detailsSecondaryStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: SigadColors.muted, fontSize: 8.8);

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
              bottom: BorderSide(color: tone.withValues(alpha: 0.35), width: 2),
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
                        compacto
                            ? '${l10n.diaAbrev(dia)} ${data.day}'
                            : '${l10n.diaAbrev(dia)} · ${data.day}',
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
                      '${turno.curtoEm(l10n)}$periodo',
                      style: chipTextStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(horario, style: horarioTextStyle),
              ),
              const SizedBox(height: 1),
              Flexible(
                child: Row(
                  children: [
                    SigadIcon(
                      livre ? SigadIcons.concluido : SigadIcons.eventoOcupado,
                      size: iconSize,
                      color: tone,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(statusLabel, style: statusTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
              if (!livre) ...[
                const SizedBox(height: 1),
                if (!compacto &&
                    aula!.disciplina != null &&
                    aula!.disciplina!.isNotEmpty)
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
                      child: Text(aula!.turma!, style: detailsSecondaryStyle),
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
  const _HorarioTile({
    required this.horario,
    required this.textTheme,
    required this.onDelete,
  });
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
                  '${context.l10n.diaDocente(horario.diaSemana)}  ${horario.inicio} – ${horario.fim}',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: SigadColors.brand,
                  ),
                ),
                if (horario.disciplina != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    horario.disciplina!,
                    style: textTheme.bodySmall?.copyWith(
                      color: SigadColors.ink,
                    ),
                  ),
                ],
                if (horario.turma != null ||
                    horario.cargaHoraria != null ||
                    horario.modalidade != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      horario.turma,
                      horario.cargaHoraria,
                      horario.modalidade,
                    ].whereType<String>().join(' · '),
                    style: textTheme.labelSmall?.copyWith(
                      color: SigadColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const SigadIcon(SigadIcons.excluir, size: 18),
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
