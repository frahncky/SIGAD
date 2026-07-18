import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../aulas_praticas/data/reserva_repository.dart';
import '../../../aulas_praticas/domain/reserva_models.dart';
import '../../../aulas_praticas/domain/reserva_service.dart';
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
    initializeDateFormatting('pt_BR', null).then((_) {
      if (!mounted) return;
      setState(() => _intlReady = true);
    });
  }

  Future<void> _carregarReservas() async {
    final armazenadas = await _reservaRepository.loadReservas();
    final reservas = armazenadas.isEmpty
        ? ReservaService.defaultReservas(DateTime.now().month)
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
    for (final reserva in _reservasFiltradas.where((r) => r.mes == mes)) {
      final data = _dataDaReserva(reserva, ano);
      if (data != null) {
        marcadores.putIfAbsent(data, () => []).add(SigadColors.success);
      }
    }
    return marcadores;
  }

  DateTime? _dataDaReserva(ReservaLaboratorio reserva, int ano) {
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
                ? 'Aula prática – ${reserva.disciplina}'
                : 'Reserva de laboratório',
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
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agenda completa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (eventos.isEmpty)
                const _EmptyAgenda()
              else
                ...eventos.map((evento) => _EventoTile(evento: evento)),
            ],
          ),
        ),
      ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
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
      if (reserva.mes != hoje.month) return false;
      final semanaAtual = ((hoje.day - 1) ~/ 7) + 1;
      return reserva.semanaDoMes == semanaAtual;
    }).length;
    final periodo =
        '${DateFormat('d', 'pt_BR').format(inicioSemana)} a '
        "${DateFormat("d 'de' MMMM", 'pt_BR').format(fimSemana)}";
    final colors = Theme.of(context).colorScheme;

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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: SigadColors.brandLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: SigadColors.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo da semana',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      periodo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onVerAgenda,
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: const Text('Ver agenda'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SigadColors.brand,
                  side: const BorderSide(color: SigadColors.brand),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const _ResumoStat(
                icon: Icons.event_note_outlined,
                value: '—',
                label: 'Eventos agendados',
                tone: SigadColors.accent,
              ),
              _ResumoStat(
                icon: Icons.science_outlined,
                value: '$reservasNaSemana',
                label: 'Reservas de laboratório',
                tone: SigadColors.success,
              ),
              const _ResumoStat(
                icon: Icons.groups_outlined,
                value: '—',
                label: 'Reunião marcada',
                tone: SigadColors.info,
              ),
            ],
          ),
        ],
      ),
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
    return Expanded(
      child: Column(
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
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
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
    return Row(
      children: [
        Expanded(
          child: _FiltroChip(
            icon: Icons.groups_2_outlined,
            label: 'Departamento',
            value: departamento,
            options: const [
              'Eletroeletrônica (DEE)',
              'Informática',
              'Mecânica',
            ],
            onChanged: onDepartamentoChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FiltroChip(
            icon: Icons.sell_outlined,
            label: 'Tipo de item',
            value: tipoItem,
            options: const ['Todos', 'Reunião', 'Laboratório', 'Comunicação'],
            onChanged: onTipoItemChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FiltroChip(
            icon: Icons.science_outlined,
            label: 'Laboratórios',
            value: laboratorio,
            options: laboratorios,
            onChanged: onLaboratorioChanged,
          ),
        ),
      ],
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
    final colors = Theme.of(context).colorScheme;
    return InkWell(
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
              children: [
                Icon(icon, size: 15, color: SigadColors.brand),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.expand_more_rounded, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _abrirSelecao(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (option) => ListTile(
                  title: Text(option),
                  trailing: option == value
                      ? const Icon(
                          Icons.check_rounded,
                          color: SigadColors.brand,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onChanged(option);
                  },
                ),
              )
              .toList(),
        ),
      ),
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
      return SigadColors.accent;
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
    final agora = DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day);
    final agendadas =
        reservas
            .map(
              (reserva) =>
                  (reserva: reserva, data: dataDaReserva(reserva, agora.year)),
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
            'Reserva: ${reserva.laboratorio}',
            reserva.disciplina ?? 'Responsável: ${reserva.professor}',
            'Laboratório',
            '${DateFormat('dd/MM').format(item.data!)} • $horario',
            Icons.science_outlined,
          );
        })
        .toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: SigadColors.brand,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Próximos compromissos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onVerTodos,
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (compromissos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text('Nenhuma reserva futura encontrada.'),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icone, color: cor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titulo,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.categoria,
                  style: TextStyle(
                    color: cor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(item.quando, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
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
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today_outlined, color: SigadColors.brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agenda do dia',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(dia),
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onVerCompleta,
                  child: const Text('Ver agenda completa'),
                ),
              ],
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
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
          ),
          Column(
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              evento.categoria,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
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
          Icon(
            Icons.event_available_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          const Text(
            'Nenhum compromisso neste dia.',
            style: TextStyle(fontWeight: FontWeight.w700),
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
      mes: hoje.month,
      semanaDoMes: semana,
    );
    final laboratorios = indicadores.map(
      (indicador) => _LabOcupacao(
        indicador.laboratorio,
        Icons.science_outlined,
        indicador.taxaOcupacao,
        indicador.slotsReservados,
        indicador.totalSlots,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SigadIconAvatar(
              icon: Icons.bar_chart_rounded,
              tone: SigadColors.brand,
              size: 34,
              iconSize: 18,
              borderRadius: 10,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ocupação dos laboratórios (hoje)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(onPressed: onVerTodos, child: const Text('Ver todos')),
          ],
        ),
        const SizedBox(height: 10),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (nomes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('Nenhuma reserva cadastrada.')),
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
                        Icon(
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
                      '${lab.horas} de ${lab.total} horários reservados na semana',
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
