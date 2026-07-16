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

  @override
  Widget build(BuildContext context) {
    if (!_intlReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 16, isWide ? 24 : 16, 28),
      children: [
        _PageHeader(diaSelecionado: _diaSelecionado),
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
          _AgendaDoDia(dia: _diaSelecionado),
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
          feriados: _feriados,
          onDiaSelecionado: _onDiaSelecionado,
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.diaSelecionado});

  final DateTime diaSelecionado;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = DateFormat(
      "EEEE, d 'de' MMMM",
      'pt_BR',
    ).format(diaSelecionado);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SigadColors.brandDeep, SigadColors.brand],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planejamento e reuniões',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label[0].toUpperCase() + label.substring(1),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Novo evento'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: SigadColors.brandDark,
            ),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Agenda do dia', style: textTheme.titleLarge),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat("d 'de' MMMM", 'pt_BR').format(dia),
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Ver tudo')),
              ],
            ),
            const SizedBox(height: 10),
            if (eventos.isEmpty)
              const _EmptyAgenda()
            else
              ...eventos.map((evento) => _EventoTile(evento: evento)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text('Próximos compromissos', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            const _MiniEvent(
              data: '18 JUL',
              titulo: 'Reunião departamental',
              subtitulo: '14:00 · Sala do DEE',
              status: 'Confirmada',
            ),
            const _MiniEvent(
              data: '20 JUL',
              titulo: 'Reunião com coordenadores',
              subtitulo: '09:00 · Sala de reuniões',
              status: 'Pendente',
            ),
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
      _Evento('09:00', '10:30', 'Reunião com coordenadores', 'Reunião'),
      _Evento('10:50', '11:40', 'Reserva do Lab. de Eletrônica', 'Laboratório'),
      _Evento('14:00', '15:00', 'Publicar comunicado no mural', 'Comunicação'),
      _Evento(
        '16:00',
        '17:00',
        'Fechamento da distribuição de carga',
        'Administrativo',
      ),
    ];
  }
}

class _Evento {
  const _Evento(this.inicio, this.fim, this.titulo, this.categoria);

  final String inicio;
  final String fim;
  final String titulo;
  final String categoria;
}

class _EventoTile extends StatelessWidget {
  const _EventoTile({required this.evento});

  final _Evento evento;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
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
          Container(width: 3, height: 42, color: SigadColors.brand),
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
                  evento.categoria,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _MiniEvent extends StatelessWidget {
  const _MiniEvent({
    required this.data,
    required this.titulo,
    required this.subtitulo,
    required this.status,
  });

  final String data;
  final String titulo;
  final String subtitulo;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SigadColors.brandLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          data,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: SigadColors.brandDark,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitulo),
      trailing: Text(status, style: const TextStyle(color: SigadColors.brand)),
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
