import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../data/plano_trabalho_repository.dart';
import '../../domain/docente_form_service.dart';
import '../../domain/docente_models.dart';
import '../../domain/plano_trabalho_service.dart';

class PlanoTrabalhoDocentePage extends StatefulWidget {
  const PlanoTrabalhoDocentePage({
    required this.docente,
    this.repository,
    super.key,
  });

  final Docente docente;
  final PlanoTrabalhoRepository? repository;

  @override
  State<PlanoTrabalhoDocentePage> createState() =>
      _PlanoTrabalhoDocentePageState();
}

class _PlanoTrabalhoDocentePageState extends State<PlanoTrabalhoDocentePage> {
  late final PlanoTrabalhoRepository _repository;
  final _descricaoControllers =
      <TipoAtividadePlanoDocente, TextEditingController>{};
  final _horasControllers =
      <TipoAtividadePlanoDocente, TextEditingController>{};
  final _avaliadorController = TextEditingController();
  final _justificativaAulasController = TextEditingController();
  final _justificativaOutrasController = TextEditingController();
  final _indisponibilidadesController = TextEditingController();

  var _carregando = true;
  var _salvando = false;
  late String _periodoSelecionado;
  List<String> _periodos = const [];
  PlanoTrabalhoDocente? _plano;
  List<EventoHistoricoPlanoTrabalho> _historico = const [];

  static const _labels = <TipoAtividadePlanoDocente, String>{
    TipoAtividadePlanoDocente.preparacaoManutencaoApoioEnsino:
        'Preparação, manutenção e apoio ao ensino',
    TipoAtividadePlanoDocente.programasProjetosEnsino:
        'Programas e projetos de ensino',
    TipoAtividadePlanoDocente.atendimentoAcompanhamentoOrientacao:
        'Atendimento, acompanhamento e orientação',
    TipoAtividadePlanoDocente.reunioesPedagogicas:
        'Reuniões pedagógicas, de grupo e afins',
    TipoAtividadePlanoDocente.pesquisa: 'Pesquisa e inovação',
    TipoAtividadePlanoDocente.extensao: 'Extensão',
    TipoAtividadePlanoDocente.gestaoRepresentacao:
        'Gestão e representação institucional',
    TipoAtividadePlanoDocente.formacaoContinuada: 'Formação continuada',
  };

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PlanoTrabalhoRepository();
    _periodoSelecionado = _periodoAtual();
    for (final tipo in TipoAtividadePlanoDocente.values) {
      _descricaoControllers[tipo] = TextEditingController();
      _horasControllers[tipo] = TextEditingController();
    }
    _carregar();
  }

  @override
  void dispose() {
    for (final controller in _descricaoControllers.values) {
      controller.dispose();
    }
    for (final controller in _horasControllers.values) {
      controller.dispose();
    }
    _avaliadorController.dispose();
    _justificativaAulasController.dispose();
    _justificativaOutrasController.dispose();
    _indisponibilidadesController.dispose();
    super.dispose();
  }

  String _periodoAtual() {
    final agora = DateTime.now();
    return '${agora.year}.${agora.month <= 6 ? 1 : 2}';
  }

  Future<void> _carregar({String? selecionarPeriodo}) async {
    setState(() => _carregando = true);
    final todos = await _repository.loadPlanos();
    final planosDocente = todos
        .where((plano) => plano.docenteId == widget.docente.id)
        .toList(growable: false);
    final periodos = {
      _periodoAtual(),
      ...planosDocente.map((plano) => plano.periodoLetivo),
    }.toList(growable: true)..sort((a, b) => b.compareTo(a));
    final periodo =
        selecionarPeriodo ??
        (periodos.contains(_periodoSelecionado)
            ? _periodoSelecionado
            : periodos.first);
    PlanoTrabalhoDocente? plano;
    for (final item in planosDocente) {
      if (item.periodoLetivo == periodo) {
        plano = item;
        break;
      }
    }
    final historico = await _repository.loadHistorico(
      planoChave: '${widget.docente.id}::$periodo',
    );
    if (!mounted) return;
    setState(() {
      _periodos = periodos;
      _periodoSelecionado = periodo;
      _plano = plano;
      _historico = historico.reversed.toList(growable: false);
      _preencherControllers(plano);
      _carregando = false;
    });
  }

  void _preencherControllers(PlanoTrabalhoDocente? plano) {
    for (final tipo in TipoAtividadePlanoDocente.values) {
      final atividades =
          plano?.atividades
              .where((atividade) => atividade.tipo == tipo)
              .toList(growable: false) ??
          const <AtividadePlanoDocente>[];
      final minutos = atividades.fold<int>(
        0,
        (total, atividade) => total + atividade.cargaSemanalMinutos,
      );
      _descricaoControllers[tipo]!.text = atividades
          .map((atividade) => atividade.descricao)
          .where((descricao) => descricao.trim().isNotEmpty)
          .join('; ');
      _horasControllers[tipo]!.text = minutos == 0
          ? ''
          : _formatarHoras(minutos);
    }
    _avaliadorController.text =
        plano?.avaliadorId ?? 'chefia:${widget.docente.departamento}';
    _justificativaAulasController.text = plano?.justificativaCargaAulas ?? '';
    _justificativaOutrasController.text =
        plano?.justificativaExtrapolacaoOutrasAtividades ?? '';
    _indisponibilidadesController.text =
        plano?.indisponibilidades
            .map(
              (item) => [
                item.diaSemana,
                item.inicio,
                item.fim,
                if ((item.observacao ?? '').isNotEmpty) item.observacao!,
              ].join(';'),
            )
            .join('\n') ??
        '';
  }

  String _formatarHoras(int minutos) {
    final horas = minutos / 60;
    return horas == horas.roundToDouble()
        ? horas.toStringAsFixed(0)
        : horas.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  }

  int _minutos(String raw) {
    final horas = double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
    return (horas * 60).round().clamp(0, 1000000);
  }

  PlanoTrabalhoDocente _montarPlano() {
    final atividades = <AtividadePlanoDocente>[];
    for (final tipo in TipoAtividadePlanoDocente.values) {
      final descricao = _descricaoControllers[tipo]!.text.trim();
      final minutos = _minutos(_horasControllers[tipo]!.text);
      if (descricao.isEmpty && minutos == 0) continue;
      atividades.add(
        AtividadePlanoDocente(
          tipo: tipo,
          descricao: descricao,
          cargaSemanalMinutos: minutos,
        ),
      );
    }
    final atual = _plano;
    return PlanoTrabalhoDocente(
      docenteId: widget.docente.id,
      periodoLetivo: _periodoSelecionado,
      atividades: atividades,
      indisponibilidades: _parseIndisponibilidades(
        _indisponibilidadesController.text,
      ),
      status: atual?.status ?? StatusPlanoTrabalhoDocente.rascunho,
      justificativaCargaAulas: _textoOuNulo(_justificativaAulasController.text),
      justificativaExtrapolacaoOutrasAtividades: _textoOuNulo(
        _justificativaOutrasController.text,
      ),
      avaliadorId: _textoOuNulo(_avaliadorController.text),
      parecerAvaliacao: atual?.parecerAvaliacao,
      criadoEm: atual?.criadoEm,
      atualizadoEm: atual?.atualizadoEm,
      submetidoEm: atual?.submetidoEm,
      avaliadoEm: atual?.avaliadoEm,
    );
  }

  List<IndisponibilidadeDocente> _parseIndisponibilidades(String raw) {
    final itens = <IndisponibilidadeDocente>[];
    for (final linha in raw.split('\n')) {
      if (linha.trim().isEmpty) continue;
      final partes = linha.split(';').map((item) => item.trim()).toList();
      if (partes.length < 3) {
        itens.add(
          IndisponibilidadeDocente(
            diaSemana: partes.isEmpty ? '' : partes.first,
            inicio: '',
            fim: '',
          ),
        );
        continue;
      }
      itens.add(
        IndisponibilidadeDocente(
          diaSemana: partes[0],
          inicio: partes[1],
          fim: partes[2],
          observacao: partes.length > 3
              ? _textoOuNulo(partes.sublist(3).join(';'))
              : null,
        ),
      );
    }
    return itens;
  }

  String? _textoOuNulo(String raw) {
    final texto = raw.trim();
    return texto.isEmpty ? null : texto;
  }

  Future<void> _salvarRascunho() async {
    final usuario = context.read<UserContextProvider>().currentUser;
    final resultado = PlanoTrabalhoService.salvarRascunho(
      usuario: usuario,
      docente: widget.docente,
      plano: _montarPlano(),
    );
    if (!resultado.sucesso) {
      _feedback(resultado.erro ?? 'Não foi possível salvar o PIT.');
      return;
    }
    await _persistir(
      resultado.plano!,
      autorId: usuario!.id,
      acao: _plano == null
          ? AcaoHistoricoPlanoTrabalho.criado
          : AcaoHistoricoPlanoTrabalho.atualizado,
      sucesso: 'Rascunho do PIT salvo.',
    );
  }

  Future<void> _submeter() async {
    final usuario = context.read<UserContextProvider>().currentUser;
    final resultado = PlanoTrabalhoService.submeter(
      usuario: usuario,
      docente: widget.docente,
      plano: _montarPlano(),
    );
    if (!resultado.sucesso) {
      setState(() {});
      _feedback(resultado.erro ?? 'Não foi possível submeter o PIT.');
      return;
    }
    await _persistir(
      resultado.plano!,
      autorId: usuario!.id,
      acao: AcaoHistoricoPlanoTrabalho.submetido,
      sucesso: 'PIT submetido para avaliação da chefia.',
    );
  }

  Future<void> _aprovar() async {
    final usuario = context.read<UserContextProvider>().currentUser;
    final plano = _plano;
    if (plano == null) return;
    final resultado = PlanoTrabalhoService.aprovar(
      usuario: usuario,
      docente: widget.docente,
      plano: plano,
      parecer: 'Plano conferido e aprovado.',
    );
    if (!resultado.sucesso) {
      _feedback(resultado.erro ?? 'Não foi possível aprovar o PIT.');
      return;
    }
    await _persistir(
      resultado.plano!,
      autorId: usuario!.id,
      acao: AcaoHistoricoPlanoTrabalho.aprovado,
      detalhes: resultado.plano!.parecerAvaliacao,
      sucesso: 'PIT aprovado.',
    );
  }

  Future<void> _devolver() async {
    final motivoController = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Devolver PIT'),
        content: TextField(
          controller: motivoController,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Motivo e ajustes necessários',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, motivoController.text),
            child: const Text('Devolver'),
          ),
        ],
      ),
    );
    motivoController.dispose();
    if (motivo == null) return;
    if (!mounted) return;
    final usuario = context.read<UserContextProvider>().currentUser;
    final plano = _plano;
    if (plano == null) return;
    final resultado = PlanoTrabalhoService.devolver(
      usuario: usuario,
      docente: widget.docente,
      plano: plano,
      motivo: motivo,
    );
    if (!resultado.sucesso) {
      _feedback(resultado.erro ?? 'Não foi possível devolver o PIT.');
      return;
    }
    await _persistir(
      resultado.plano!,
      autorId: usuario!.id,
      acao: AcaoHistoricoPlanoTrabalho.devolvido,
      detalhes: motivo,
      sucesso: 'PIT devolvido ao docente.',
    );
  }

  Future<void> _persistir(
    PlanoTrabalhoDocente plano, {
    required String autorId,
    required AcaoHistoricoPlanoTrabalho acao,
    required String sucesso,
    String? detalhes,
  }) async {
    setState(() => _salvando = true);
    try {
      await _repository.savePlano(
        plano,
        autorId: autorId,
        acao: acao,
        detalhes: detalhes,
      );
      AppEventLogger.action(
        'pit_${acao.name}',
        details: {
          'docenteId': widget.docente.id,
          'periodo': plano.periodoLetivo,
        },
      );
      await _carregar(selecionarPeriodo: plano.periodoLetivo);
      if (mounted) _feedback(sucesso);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _feedback(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UserContextProvider>().currentUser;
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final planoFormulario = _montarPlano();
    final validacao = DocenteFormService.validarPlanoTrabalho(
      docente: widget.docente,
      plano: planoFormulario,
    );
    final status = _plano?.status ?? StatusPlanoTrabalhoDocente.rascunho;
    final podeEditar =
        PlanoTrabalhoService.podeEditar(
          usuario: usuario,
          docente: widget.docente,
        ) &&
        (status == StatusPlanoTrabalhoDocente.rascunho ||
            status == StatusPlanoTrabalhoDocente.devolvido);
    final podeAvaliar =
        PlanoTrabalhoService.podeAvaliar(
          usuario: usuario,
          docente: widget.docente,
        ) &&
        status == StatusPlanoTrabalhoDocente.submetido;
    final cargaAulasMinutos = DocenteFormService.cargaAulasDocenteMinutos(
      widget.docente,
    );
    final cargaTotalMinutos =
        cargaAulasMinutos + planoFormulario.cargaAtividadesMinutos;

    return Scaffold(
      appBar: AppBar(title: const Text('Plano Individual de Trabalho')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CabecalhoPit(
            docente: widget.docente,
            status: status,
            cargaAulas: _formatarHoras(cargaAulasMinutos),
            cargaTotal: _formatarHoras(cargaTotalMinutos),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _periodoSelecionado,
            decoration: const InputDecoration(labelText: 'Período letivo'),
            items: _periodos
                .map(
                  (periodo) =>
                      DropdownMenuItem(value: periodo, child: Text(periodo)),
                )
                .toList(growable: false),
            onChanged: _salvando
                ? null
                : (periodo) {
                    if (periodo != null) _carregar(selecionarPeriodo: periodo);
                  },
          ),
          const SizedBox(height: 16),
          Text(
            'Atividades semanais',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...TipoAtividadePlanoDocente.values.map(
            (tipo) => _AtividadePitField(
              label: _labels[tipo]!,
              descricaoController: _descricaoControllers[tipo]!,
              horasController: _horasControllers[tipo]!,
              enabled: podeEditar && !_salvando,
              onChanged: () => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _justificativaAulasController,
            enabled: podeEditar && !_salvando,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Justificativa para carga de aulas excepcional',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _justificativaOutrasController,
            enabled: podeEditar && !_salvando,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Justificativa para outras atividades excepcionais',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _avaliadorController,
            enabled: podeEditar && !_salvando,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Chefia imediata avaliadora',
              prefixIcon: Icon(Icons.supervisor_account_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _indisponibilidadesController,
            enabled: podeEditar && !_salvando,
            minLines: 2,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Indisponibilidades validadas com a chefia',
              hintText:
                  'Segunda;08:00;10:00;atividade institucional\n'
                  'Quarta;14:00;16:00',
              helperText: 'Uma restrição por linha: dia;início;fim;observação',
              prefixIcon: Icon(Icons.event_busy_outlined),
            ),
          ),
          if ((_plano?.parecerAvaliacao ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _ParecerCard(texto: _plano!.parecerAvaliacao!),
          ],
          const SizedBox(height: 16),
          _PendenciasPit(validacao: validacao),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (podeEditar)
                OutlinedButton.icon(
                  onPressed: _salvando ? null : _salvarRascunho,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar rascunho'),
                ),
              if (podeEditar)
                FilledButton.icon(
                  onPressed: _salvando ? null : _submeter,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Submeter à chefia'),
                ),
              if (podeAvaliar)
                FilledButton.icon(
                  onPressed: _salvando ? null : _aprovar,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Aprovar PIT'),
                ),
              if (podeAvaliar)
                OutlinedButton.icon(
                  onPressed: _salvando ? null : _devolver,
                  icon: const Icon(Icons.undo_outlined),
                  label: const Text('Devolver para ajustes'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _HistoricoPit(eventos: _historico),
        ],
      ),
    );
  }
}

class _CabecalhoPit extends StatelessWidget {
  const _CabecalhoPit({
    required this.docente,
    required this.status,
    required this.cargaAulas,
    required this.cargaTotal,
  });

  final Docente docente;
  final StatusPlanoTrabalhoDocente status;
  final String cargaAulas;
  final String cargaTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  docente.nome,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPit(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text('${docente.departamento} · ${docente.regimeTrabalho.label}'),
          const SizedBox(height: 8),
          Text('Aulas: ${cargaAulas}h · Total planejado: ${cargaTotal}h'),
          const SizedBox(height: 4),
          const Text(
            'Referências: Resolução CONSUP/IFMA nº 67/2019 e Portaria MEC nº 750/2024.',
            style: TextStyle(fontSize: 12, color: SigadColors.muted),
          ),
        ],
      ),
    );
  }
}

class _StatusPit extends StatelessWidget {
  const _StatusPit({required this.status});

  final StatusPlanoTrabalhoDocente status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      StatusPlanoTrabalhoDocente.rascunho => ('Rascunho', SigadColors.muted),
      StatusPlanoTrabalhoDocente.submetido => ('Em avaliação', Colors.orange),
      StatusPlanoTrabalhoDocente.aprovado => ('Aprovado', Colors.green),
      StatusPlanoTrabalhoDocente.devolvido => ('Devolvido', Colors.redAccent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AtividadePitField extends StatelessWidget {
  const _AtividadePitField({
    required this.label,
    required this.descricaoController,
    required this.horasController,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final TextEditingController descricaoController;
  final TextEditingController horasController;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: SigadColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: descricaoController,
                    enabled: enabled,
                    onChanged: (_) => onChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: horasController,
                    enabled: enabled,
                    onChanged: (_) => onChanged(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Horas/sem',
                      isDense: true,
                    ),
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

class _PendenciasPit extends StatelessWidget {
  const _PendenciasPit({required this.validacao});

  final ResultadoValidacaoPlanoTrabalho validacao;

  @override
  Widget build(BuildContext context) {
    if (validacao.pendencias.isEmpty) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.verified_outlined, color: Colors.green),
        title: Text('PIT pronto para submissão'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validação do plano',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        ...validacao.pendencias.map(
          (pendencia) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              pendencia.severidade == SeveridadePendenciaPlano.bloqueio
                  ? Icons.error_outline
                  : Icons.warning_amber_outlined,
              color: pendencia.severidade == SeveridadePendenciaPlano.bloqueio
                  ? Colors.redAccent
                  : Colors.orange,
            ),
            title: Text(pendencia.mensagem),
          ),
        ),
      ],
    );
  }
}

class _ParecerCard extends StatelessWidget {
  const _ParecerCard({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Text('Parecer da chefia: $texto'),
    );
  }
}

class _HistoricoPit extends StatelessWidget {
  const _HistoricoPit({required this.eventos});

  final List<EventoHistoricoPlanoTrabalho> eventos;

  @override
  Widget build(BuildContext context) {
    if (eventos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico e auditoria',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...eventos.map(
          (evento) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history_outlined),
            title: Text(_labelAcao(evento.acao)),
            subtitle: Text(
              '${_data(evento.ocorridoEm)} · ${evento.autorId}'
              '${evento.detalhes == null ? '' : '\n${evento.detalhes}'}',
            ),
          ),
        ),
      ],
    );
  }

  static String _labelAcao(AcaoHistoricoPlanoTrabalho acao) => switch (acao) {
    AcaoHistoricoPlanoTrabalho.criado => 'PIT criado',
    AcaoHistoricoPlanoTrabalho.atualizado => 'Rascunho atualizado',
    AcaoHistoricoPlanoTrabalho.submetido => 'Submetido à chefia',
    AcaoHistoricoPlanoTrabalho.aprovado => 'Aprovado pela chefia',
    AcaoHistoricoPlanoTrabalho.devolvido => 'Devolvido para ajustes',
  };

  static String _data(DateTime data) {
    String dois(int value) => value.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
  }
}
