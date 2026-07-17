import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../widgets/calendario_mes_widget.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime _mesAtual = DateTime.now();
  DateTime _diaSelecionado = DateTime.now();
  bool _intlReady = false;

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
    initializeDateFormatting('pt_BR', null).then((_) {
      if (!mounted) return;
      setState(() => _intlReady = true);
    });
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
    return {
      DateTime(ano, mes, 7): [SigadColors.accent],
      DateTime(ano, mes, 9): [SigadColors.info],
      DateTime(ano, mes, 14): [SigadColors.success],
      DateTime(ano, mes, 22): [SigadColors.success],
      DateTime(ano, mes, 27): [SigadColors.accent, SigadColors.risk],
      DateTime(ano, mes, 30): [SigadColors.info],
    };
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
        const _ResumoDaSemana(),
        const SizedBox(height: 16),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _calendarCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _AgendaDoDia(dia: _diaSelecionado)),
            ],
          )
        else ...[
          _calendarCard(),
          const SizedBox(height: 16),
          _FiltrosCalendario(
            departamento: _departamento,
            tipoItem: _tipoItem,
            laboratorio: _laboratorio,
            onDepartamentoChanged: (value) =>
                setState(() => _departamento = value),
            onTipoItemChanged: (value) => setState(() => _tipoItem = value),
            onLaboratorioChanged: (value) =>
                setState(() => _laboratorio = value),
          ),
          const SizedBox(height: 16),
          const _ProximosCompromissos(),
          const SizedBox(height: 16),
          _AgendaDoDia(dia: _diaSelecionado),
          const SizedBox(height: 16),
          const _OcupacaoLaboratorios(),
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
  const _ResumoDaSemana();

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final inicioSemana = hoje.subtract(Duration(days: hoje.weekday % 7));
    final fimSemana = inicioSemana.add(const Duration(days: 6));
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
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
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
                onPressed: () {},
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
          const Row(
            children: [
              _ResumoStat(
                icon: Icons.event_note_outlined,
                value: '5',
                label: 'Eventos agendados',
              ),
              _ResumoStat(
                icon: Icons.science_outlined,
                value: '2',
                label: 'Reservas de laboratório',
              ),
              _ResumoStat(
                icon: Icons.groups_outlined,
                value: '1',
                label: 'Reunião marcada',
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
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: SigadColors.brandLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: SigadColors.brand, size: 15),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
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
    required this.onDepartamentoChanged,
    required this.onTipoItemChanged,
    required this.onLaboratorioChanged,
  });

  final String departamento;
  final String tipoItem;
  final String laboratorio;
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
            options: const [
              'Todos',
              'Lab. de Medidas Elétricas',
              'Lab. de Eletrônica',
              'Lab. de Sinais e Sistemas',
            ],
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
                      ? const Icon(Icons.check_rounded, color: SigadColors.brand)
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

class _ProximosCompromissos extends StatelessWidget {
  const _ProximosCompromissos();

  @override
  Widget build(BuildContext context) {
    const compromissos = [
      _Compromisso(
        'Reunião departamental',
        'Pauta: projetos, avaliações e demandas',
        'Reunião',
        'Hoje • 15:00',
        Icons.groups_outlined,
      ),
      _Compromisso(
        'Reserva: Lab. de Medidas Elétricas',
        'Aula prática – Circuitos Elétricos I',
        'Laboratório',
        'Amanhã • 08:00',
        Icons.science_outlined,
      ),
      _Compromisso(
        'Envio de notícias',
        'Publicação no portal e redes do IFMA',
        'Comunicação',
        '17/07 • 10:00',
        Icons.campaign_outlined,
      ),
    ];

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
                TextButton(onPressed: () {}, child: const Text('Ver todos')),
              ],
            ),
            const SizedBox(height: 6),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
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
  const _AgendaDoDia({required this.dia});

  final DateTime dia;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final eventos = _eventosPara(dia);

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
                  onPressed: () {},
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

  List<_Evento> _eventosPara(DateTime data) {
    if (data.weekday == DateTime.saturday || data.weekday == DateTime.sunday) {
      return const [];
    }
    return const [
      _Evento(
        '08:00',
        '10:00',
        'Aula prática – Circuitos Elétricos I',
        'Lab. de Medidas Elétricas',
        'Laboratório',
      ),
      _Evento(
        '14:00',
        '15:00',
        'Orientação de TCC',
        'Sala 203 – Prédio Principal',
        'Reunião',
      ),
      _Evento(
        '15:00',
        '16:30',
        'Reunião departamental',
        'Sala 205 – Prédio Principal',
        'Reunião',
      ),
    ];
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
              Container(width: 2, height: 34, color: cor.withValues(alpha: 0.25)),
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
  const _LabOcupacao(this.nome, this.icone, this.ocupacao, this.horas, this.total);

  final String nome;
  final IconData icone;
  final double ocupacao;
  final int horas;
  final int total;
}

class _OcupacaoLaboratorios extends StatelessWidget {
  const _OcupacaoLaboratorios();

  @override
  Widget build(BuildContext context) {
    const laboratorios = [
      _LabOcupacao('Lab. de Medidas Elétricas', Icons.science_outlined, 0.75, 12, 16),
      _LabOcupacao('Lab. de Eletrônica', Icons.memory_outlined, 0.40, 6, 15),
      _LabOcupacao('Lab. de Sinais e Sistemas', Icons.graphic_eq_rounded, 0.20, 3, 15),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart_rounded, color: SigadColors.brand),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ocupação dos laboratórios (hoje)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Ver todos')),
          ],
        ),
        const SizedBox(height: 10),
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
                      Icon(lab.icone, color: SigadColors.brand, size: 18),
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
                        style: const TextStyle(fontWeight: FontWeight.w800),
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
                    '${lab.horas}h de ${lab.total}h reservadas',
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
