import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../aulas_praticas/data/reserva_repository.dart';
import '../../../aulas_praticas/domain/reserva_models.dart';
import '../../../aulas_praticas/domain/reserva_service.dart';
import '../../../../l10n/l10n.dart';
import '../calendario_l10n.dart';
import '../widgets/calendario_mes_widget.dart';
import '../../../../shared/widgets/icon_avatar.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime _mesAtual = DateTime.now();
  DateTime _diaSelecionado = DateTime.now();
  bool _intlReady = false;
  bool _loadingReservas = true;
  final ReservaRepository _reservaRepository = ReservaRepository();
  List<ReservaLaboratorio> _reservas = const [];

  String _departamento = 'Eletroeletrônica (DEE)';
  String _tipoItem = 'Todos';
  String _laboratorio = 'Todos';

  final Map<DateTime, String> _feriados = {
    DateTime(2026, 1, 1): 'Confraternização Universal',
    DateTime(2026, 2, 16): 'Carnaval',
    DateTime(2026, 2, 17): 'Carnaval',
    DateTime(2026, 4, 3): 'Sexta-feira Santa',
    DateTime(2026, 4, 21): 'Tiradentes',
    DateTime(2026, 5, 1): 'Dia do Trabalho',
    DateTime(2026, 7, 28): 'Adesão do Maranhão à Independência',
    DateTime(2026, 9, 7): 'Independência do Brasil',
    DateTime(2026, 10, 12): 'Nossa Senhora Aparecida',
    DateTime(2026, 11, 2): 'Finados',
    DateTime(2026, 11, 15): 'Proclamação da República',
    DateTime(2026, 12, 8): 'Nossa Senhora da Conceição',
    DateTime(2026, 12, 25): 'Natal',
  };

  @override
  void initState() {
    super.initState();
    _carregarReservas();
    initializeDateFormatting().then((_) {
      if (!mounted) return;
      setState(() => _intlReady = true);
    });
  }

  Future<void> _carregarReservas() async {
    final armazenadas = await _reservaRepository.loadReservas();
    final reservas = armazenadas.isEmpty
        ? ReservaService.defaultReservas(
            ano: DateTime.now().year,
            mes: DateTime.now().month,
          )
        : armazenadas;
    if (!mounted) return;
    setState(() {
      _reservas = reservas;
      _loadingReservas = false;
    });
  }

  List<ReservaLaboratorio> get _reservasFiltradas => _reservas
      .where((reserva) {
        if (_tipoItem != 'Todos' && _tipoItem != 'Laboratório') return false;
        if (_laboratorio != 'Todos' && reserva.laboratorio != _laboratorio) {
          return false;
        }
        return true;
      })
      .toList(growable: false);

  List<String> get _laboratorios {
    final nomes =
        _reservas.map((reserva) => reserva.laboratorio).toSet().toList()
          ..sort();
    return ['Todos', ...nomes];
  }

  void _onDiaSelecionado(DateTime dia) {
    setState(() {
      _diaSelecionado = dia;
      _mesAtual = DateTime(dia.year, dia.month);
    });
  }

  Map<DateTime, List<Color>> _marcadoresDoMes() {
    final ano = _mesAtual.year;
    final mes = _mesAtual.month;
    final marcadores = <DateTime, List<Color>>{
      DateTime(ano, mes, 7): [SigadColors.accent],
      DateTime(ano, mes, 9): [SigadColors.info],
      DateTime(ano, mes, 14): [SigadColors.success],
      DateTime(ano, mes, 22): [SigadColors.success],
      DateTime(ano, mes, 27): [SigadColors.accent, SigadColors.risk],
      DateTime(ano, mes, 30): [SigadColors.info],
    };
    for (final reserva in _reservasFiltradas.where(
      (r) => r.ano == ano && r.mes == mes,
    )) {
      final data = _dataDaReserva(reserva, ano);
      if (data != null) {
        marcadores.putIfAbsent(data, () => []).add(SigadColors.success);
      }
    }
    return marcadores;
  }

  DateTime? _dataDaReserva(ReservaLaboratorio reserva, int ano) {
    if (reserva.ano != ano) return null;
    const weekdays = {'Seg': 1, 'Ter': 2, 'Qua': 3, 'Qui': 4, 'Sex': 5};
    final weekday = weekdays[reserva.diaSemana];
    if (weekday == null) return null;
    final primeiroDia = DateTime(ano, reserva.mes, 1);
    final deslocamento = (weekday - primeiroDia.weekday + 7) % 7;
    final dia = 1 + deslocamento + ((reserva.semanaDoMes - 1) * 7);
    final data = DateTime(ano, reserva.mes, dia);
    return data.month == reserva.mes ? data : null;
  }

  List<_Evento> _eventosPara(DateTime dia) {
    final l10n = context.l10n;
    return _reservasFiltradas
        .where((reserva) {
          final data = _dataDaReserva(reserva, dia.year);
          return data != null && DateUtils.isSameDay(data, dia);
        })
        .map((reserva) {
          final partes = reserva.turno.horarioDo(reserva.periodo).split('-');
          return _Evento(
            partes.first,
            partes.length > 1 ? partes.last : '',
            reserva.disciplina?.trim().isNotEmpty == true
                ? l10n.calAulaPratica(reserva.disciplina!)
                : l10n.calReservaLaboratorio,
            '${reserva.laboratorio} · ${reserva.professor}',
            'Laboratório',
          );
        })
        .toList()
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
  }

  void _abrirAgendaCompleta() {
    final eventos = _eventosPara(_diaSelecionado);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final alturaMaxima = MediaQuery.sizeOf(sheetContext).height * 0.9;
        return SafeArea(
          child: ConstrainedBox(
            key: const Key('calendario-agenda-completa'),
            constraints: BoxConstraints(maxHeight: alturaMaxima),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    context.l10n.calAgendaCompleta,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                ),
                Flexible(
                  child: eventos.isEmpty
                      ? const SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: _EmptyAgenda(),
                        )
                      : ListView.builder(
                          key: const Key('calendario-agenda-completa-lista'),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: eventos.length,
                          itemBuilder: (context, index) =>
                              _EventoTile(evento: eventos[index]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_intlReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 16, isWide ? 24 : 16, 28),
      children: [
        _ResumoDaSemana(
          reservas: _reservasFiltradas,
          onVerAgenda: _abrirAgendaCompleta,
        ),
        const SizedBox(height: 16),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _calendarCard()),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _AgendaDoDia(
                  dia: _diaSelecionado,
                  eventos: _eventosPara(_diaSelecionado),
                  onVerCompleta: _abrirAgendaCompleta,
                ),
              ),
            ],
          )
        else ...[
          _calendarCard(),
          const SizedBox(height: 16),
          _FiltrosCalendario(
            departamento: _departamento,
            tipoItem: _tipoItem,
            laboratorio: _laboratorio,
            laboratorios: _laboratorios,
            onDepartamentoChanged: (value) =>
                setState(() => _departamento = value),
            onTipoItemChanged: (value) => setState(() => _tipoItem = value),
            onLaboratorioChanged: (value) =>
                setState(() => _laboratorio = value),
          ),
          const SizedBox(height: 16),
          _ProximosCompromissos(
            reservas: _reservasFiltradas,
            dataDaReserva: _dataDaReserva,
            onVerTodos: _abrirAgendaCompleta,
          ),
          const SizedBox(height: 16),
          _AgendaDoDia(
            dia: _diaSelecionado,
            eventos: _eventosPara(_diaSelecionado),
            onVerCompleta: _abrirAgendaCompleta,
          ),
          const SizedBox(height: 16),
          _OcupacaoLaboratorios(
            reservas: _reservasFiltradas,
            loading: _loadingReservas,
            onVerTodos: () =>
                Navigator.of(context).pushNamed(AppRoutes.aulasPraticas),
          ),
        ],
      ],
    );
  }

  Widget _calendarCard() {
    final usarPaddingCompacto = MediaQuery.sizeOf(context).width <= 360;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(usarPaddingCompacto ? 12 : 18),
        child: CalendarioMesWidget(
          mesAtual: _mesAtual,
          diaSelecionado: _diaSelecionado,
          feriados: _feriados,
          marcadores: _marcadoresDoMes(),
          onDiaSelecionado: _onDiaSelecionado,
        ),
      ),
    );
  }
}

class _ResumoDaSemana extends StatelessWidget {
  const _ResumoDaSemana({required this.reservas, required this.onVerAgenda});

  final List<ReservaLaboratorio> reservas;
  final VoidCallback onVerAgenda;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final inicioSemana = hoje.subtract(Duration(days: hoje.weekday % 7));
    final fimSemana = inicioSemana.add(const Duration(days: 6));
    final reservasNaSemana = reservas.where((reserva) {
      if (reserva.ano != hoje.year || reserva.mes != hoje.month) return false;
      final semanaAtual = ((hoje.day - 1) ~/ 7) + 1;
      return reserva.semanaDoMes == semanaAtual;
    }).length;
    final l10n = context.l10n;
    // Em português: "3 a 9 de agosto"; em inglês: "August 3 – August 9".
    final formatoInicio =
        inicioSemana.month == fimSemana.month && l10n.localeName == 'pt'
        ? DateFormat.d(l10n.localeDatas)
        : DateFormat.MMMMd(l10n.localeDatas);
    final periodo = l10n.calPeriodoSemana(
      formatoInicio.format(inicioSemana),
      DateFormat.MMMMd(l10n.localeDatas).format(fimSemana),
    );
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final escalaTexto = MediaQuery.textScalerOf(context).scale(14) / 14;
        final usarLayoutVertical =
            constraints.maxWidth < 400 || escalaTexto >= 1.4;
        final identificacao = Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SigadColors.brandLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const SigadIcon(
                SigadIcons.calendario,
                color: SigadColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.calResumoSemana,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    periodo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final botaoAgenda = OutlinedButton.icon(
          onPressed: onVerAgenda,
          icon: const SigadIcon(SigadIcons.setaDireita, size: 15),
          label: Text(l10n.calVerAgenda),
          style: OutlinedButton.styleFrom(
            foregroundColor: SigadColors.brand,
            side: const BorderSide(color: SigadColors.brand),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
        final estatisticas = <_ResumoStat>[
          _ResumoStat(
            icon: SigadIcons.eventoNota,
            value: '—',
            label: l10n.calEventosAgendados,
            tone: SigadColors.violet,
          ),
          _ResumoStat(
            icon: SigadIcons.laboratorio,
            value: '$reservasNaSemana',
            label: l10n.calReservasLaboratorio,
            tone: SigadColors.success,
          ),
          _ResumoStat(
            icon: SigadIcons.grupo,
            value: '—',
            label: l10n.calReuniaoMarcada,
            tone: SigadColors.info,
          ),
        ];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (usarLayoutVertical) ...[
                identificacao,
                const SizedBox(height: 12),
                botaoAgenda,
              ] else
                Row(
                  children: [
                    Expanded(child: identificacao),
                    const SizedBox(width: 8),
                    botaoAgenda,
                  ],
                ),
              const SizedBox(height: 16),
              if (usarLayoutVertical)
                ...estatisticas.map(
                  (stat) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: stat,
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: estatisticas
                      .map((stat) => Expanded(child: stat))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumoStat extends StatelessWidget {
  const _ResumoStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SigadIconAvatar(
              icon: icon,
              tone: tone,
              size: 28,
              iconSize: 15,
              borderRadius: 9,
            ),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _FiltrosCalendario extends StatelessWidget {
  const _FiltrosCalendario({
    required this.departamento,
    required this.tipoItem,
    required this.laboratorio,
    required this.laboratorios,
    required this.onDepartamentoChanged,
    required this.onTipoItemChanged,
    required this.onLaboratorioChanged,
  });

  final String departamento;
  final String tipoItem;
  final String laboratorio;
  final List<String> laboratorios;
  final ValueChanged<String> onDepartamentoChanged;
  final ValueChanged<String> onTipoItemChanged;
  final ValueChanged<String> onLaboratorioChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final escalaTexto = MediaQuery.textScalerOf(context).scale(14) / 14;
        final empilharFiltros =
            constraints.maxWidth < 600 || escalaTexto >= 1.4;
        final larguraFiltro = empilharFiltros
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 3;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: larguraFiltro,
              child: _FiltroChip(
                icon: SigadIcons.grupo,
                label: l10n.calDepartamento,
                value: departamento,
                options: const [
                  'Eletroeletrônica (DEE)',
                  'Informática',
                  'Mecânica',
                ],
                onChanged: onDepartamentoChanged,
              ),
            ),
            SizedBox(
              width: larguraFiltro,
              child: _FiltroChip(
                icon: SigadIcons.etiqueta,
                label: l10n.calTipoItem,
                value: tipoItem,
                options: const [
                  'Todos',
                  'Reunião',
                  'Laboratório',
                  'Comunicação',
                ],
                onChanged: onTipoItemChanged,
              ),
            ),
            SizedBox(
              width: larguraFiltro,
              child: _FiltroChip(
                icon: SigadIcons.laboratorio,
                label: l10n.navLaboratorios,
                value: laboratorio,
                options: laboratorios,
                onChanged: onLaboratorioChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '$label: ${l10n.opcaoCalendario(value)}',
      hint: l10n.calToqueParaAlterar,
      onTap: () => _abrirSelecao(context),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirSelecao(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SigadIcon(icon, size: 15, color: SigadColors.brand),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l10n.opcaoCalendario(value),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SigadIcon(SigadIcons.chevronBaixo, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirSelecao(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final alturaMaxima = MediaQuery.sizeOf(sheetContext).height * 0.75;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: alturaMaxima),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              children: options
                  .map(
                    (option) => ListTile(
                      title: Text(sheetContext.l10n.opcaoCalendario(option)),
                      trailing: option == value
                          ? const SigadIcon(
                              SigadIcons.confirmar,
                              color: SigadColors.brand,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onChanged(option);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _Compromisso {
  const _Compromisso(
    this.titulo,
    this.subtitulo,
    this.categoria,
    this.quando,
    this.icone,
  );

  final String titulo;
  final String subtitulo;
  final String categoria;
  final String quando;
  final IconData icone;
}

Color _corCategoria(String categoria) {
  switch (categoria) {
    case 'Reunião':
      return SigadColors.info;
    case 'Laboratório':
      return SigadColors.success;
    case 'Comunicação':
      return SigadColors.violet;
    default:
      return SigadColors.brand;
  }
}

Color _corOcupacao(double ocupacao) {
  if (ocupacao < 0.4) return SigadColors.success;
  if (ocupacao < 0.75) return SigadColors.warning;
  return SigadColors.risk;
}

class _ProximosCompromissos extends StatelessWidget {
  const _ProximosCompromissos({
    required this.reservas,
    required this.dataDaReserva,
    required this.onVerTodos,
  });

  final List<ReservaLaboratorio> reservas;
  final DateTime? Function(ReservaLaboratorio reserva, int ano) dataDaReserva;
  final VoidCallback onVerTodos;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final agora = DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day);
    final agendadas =
        reservas
            .map(
              (reserva) =>
                  (reserva: reserva, data: dataDaReserva(reserva, reserva.ano)),
            )
            .where(
              (item) => item.data != null && !item.data!.isBefore(inicioHoje),
            )
            .toList()
          ..sort((a, b) => a.data!.compareTo(b.data!));
    final compromissos = agendadas
        .take(3)
        .map((item) {
          final reserva = item.reserva;
          final horario = reserva.turno
              .horarioDo(reserva.periodo)
              .split('-')
              .first;
          return _Compromisso(
            l10n.calReservaDe(reserva.laboratorio),
            reserva.disciplina ?? l10n.calResponsavel(reserva.professor),
            'Laboratório',
            '${DateFormat.yMd(l10n.localeDatas).format(item.data!)} • $horario',
            SigadIcons.laboratorio,
          );
        })
        .toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final escalaTexto =
                    MediaQuery.textScalerOf(context).scale(14) / 14;
                final usarLayoutVertical =
                    constraints.maxWidth < 400 || escalaTexto >= 1.4;
                final titulo = Row(
                  children: [
                    const SigadIcon(
                      SigadIcons.calendario,
                      color: SigadColors.brand,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.calProximosCompromissos,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                );
                final acao = TextButton(
                  onPressed: onVerTodos,
                  child: Text(context.l10n.calVerTodos),
                );

                if (usarLayoutVertical) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [titulo, const SizedBox(height: 4), acao],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: titulo),
                    acao,
                  ],
                );
              },
            ),
            const SizedBox(height: 6),
            if (compromissos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(context.l10n.calNenhumaReservaFutura),
                ),
              )
            else
              ...compromissos.map((item) => _CompromissoTile(item: item)),
          ],
        ),
      ),
    );
  }
}

class _CompromissoTile extends StatelessWidget {
  const _CompromissoTile({required this.item});

  final _Compromisso item;

  @override
  Widget build(BuildContext context) {
    final cor = _corCategoria(item.categoria);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final escalaTexto = MediaQuery.textScalerOf(context).scale(14) / 14;
          final usarLayoutVertical =
              constraints.maxWidth < 520 || escalaTexto >= 1.4;
          final icone = Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SigadIcon(item.icone, color: cor, size: 20),
          );
          final informacoes = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.titulo,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitulo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final categoria = Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.l10n.opcaoCalendario(item.categoria),
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          );
          final quando = Text(
            item.quando,
            style: Theme.of(context).textTheme.bodySmall,
          );

          if (usarLayoutVertical) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    icone,
                    const SizedBox(width: 12),
                    Expanded(child: informacoes),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [categoria, const SizedBox(height: 4), quando],
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icone,
              const SizedBox(width: 12),
              Expanded(child: informacoes),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [categoria, const SizedBox(height: 4), quando],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AgendaDoDia extends StatelessWidget {
  const _AgendaDoDia({
    required this.dia,
    required this.eventos,
    required this.onVerCompleta,
  });

  final DateTime dia;
  final List<_Evento> eventos;
  final VoidCallback onVerCompleta;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final escalaTexto =
                    MediaQuery.textScalerOf(context).scale(14) / 14;
                final usarLayoutVertical =
                    constraints.maxWidth < 400 || escalaTexto >= 1.4;
                final titulo = Row(
                  children: [
                    const SigadIcon(
                      SigadIcons.calendario,
                      color: SigadColors.brand,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.calAgendaDoDia,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            DateFormat.yMMMMd(l10n.localeDatas).format(dia),
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                final acao = TextButton(
                  onPressed: onVerCompleta,
                  child: Text(l10n.calVerAgendaCompleta),
                );

                if (usarLayoutVertical) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [titulo, const SizedBox(height: 4), acao],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: titulo),
                    acao,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            if (eventos.isEmpty)
              const _EmptyAgenda()
            else
              ...eventos.map((evento) => _EventoTile(evento: evento)),
          ],
        ),
      ),
    );
  }
}

class _Evento {
  const _Evento(this.inicio, this.fim, this.titulo, this.local, this.categoria);

  final String inicio;
  final String fim;
  final String titulo;
  final String local;
  final String categoria;
}

class _EventoTile extends StatelessWidget {
  const _EventoTile({required this.evento});

  final _Evento evento;

  @override
  Widget build(BuildContext context) {
    final cor = _corCategoria(evento.categoria);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final escalaTexto = MediaQuery.textScalerOf(context).scale(14) / 14;
          final usarLayoutVertical =
              constraints.maxWidth < 480 || escalaTexto >= 1.4;
          final horario = SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.inicio,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(evento.fim, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
          final marcador = Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
              ),
              Container(
                width: 2,
                height: 34,
                color: cor.withValues(alpha: 0.25),
              ),
            ],
          );
          final informacoes = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                evento.titulo,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                evento.local,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final categoria = Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.l10n.opcaoCalendario(evento.categoria),
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          );

          if (usarLayoutVertical) {
            final periodo = evento.fim.isEmpty
                ? evento.inicio
                : '${evento.inicio} – ${evento.fim}';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodo,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                categoria,
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    marcador,
                    const SizedBox(width: 12),
                    Expanded(child: informacoes),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              horario,
              marcador,
              const SizedBox(width: 12),
              Expanded(child: informacoes),
              categoria,
            ],
          );
        },
      ),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SigadIcon(
            SigadIcons.eventoConfirmado,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.calNenhumCompromisso,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LabOcupacao {
  const _LabOcupacao(
    this.nome,
    this.icone,
    this.ocupacao,
    this.horas,
    this.total,
  );

  final String nome;
  final IconData icone;
  final double ocupacao;
  final int horas;
  final int total;
}

class _OcupacaoLaboratorios extends StatelessWidget {
  const _OcupacaoLaboratorios({
    required this.reservas,
    required this.loading,
    required this.onVerTodos,
  });

  final List<ReservaLaboratorio> reservas;
  final bool loading;
  final VoidCallback onVerTodos;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final semana = ((hoje.day - 1) ~/ 7) + 1;
    final nomes =
        reservas.map((reserva) => reserva.laboratorio).toSet().toList()..sort();
    final indicadores = ReservaService.calcularOcupacaoLaboratorios(
      reservas: reservas,
      laboratorios: nomes,
      ano: hoje.year,
      mes: hoje.month,
      semanaDoMes: semana,
    );
    final laboratorios = indicadores.map(
      (indicador) => _LabOcupacao(
        indicador.laboratorio,
        SigadIcons.laboratorio,
        indicador.taxaOcupacao,
        indicador.slotsReservados,
        indicador.totalSlots,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final escalaTexto = MediaQuery.textScalerOf(context).scale(14) / 14;
            final usarLayoutVertical =
                constraints.maxWidth < 400 || escalaTexto >= 1.4;
            final titulo = Row(
              children: [
                const SigadIconAvatar(
                  icon: SigadIcons.graficoBarras,
                  tone: SigadColors.brand,
                  size: 34,
                  iconSize: 18,
                  borderRadius: 10,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.calOcupacaoHoje,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
            final acao = TextButton(
              onPressed: onVerTodos,
              child: Text(context.l10n.calVerTodos),
            );

            if (usarLayoutVertical) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [titulo, const SizedBox(height: 4), acao],
              );
            }
            return Row(
              children: [
                Expanded(child: titulo),
                acao,
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (nomes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text(context.l10n.calNenhumaReserva)),
          )
        else
          ...laboratorios.map(
            (lab) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SigadIcon(
                          lab.icone,
                          color: _corOcupacao(lab.ocupacao),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lab.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${(lab.ocupacao * 100).round()}%',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _corOcupacao(lab.ocupacao),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: lab.ocupacao,
                        minHeight: 8,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        color: SigadColors.brand,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.calHorariosReservados(lab.horas, lab.total),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
