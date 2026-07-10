import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarioMesWidget extends StatelessWidget {
  final DateTime mesAtual;
  final Map<DateTime, String> feriados;
  final void Function(DateTime)? onDiaSelecionado;

  const CalendarioMesWidget({
    super.key,
    required this.mesAtual,
    this.feriados = const {},
    this.onDiaSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    final primeiroDia = DateTime(mesAtual.year, mesAtual.month, 1);
    final ultimoDia = DateTime(mesAtual.year, mesAtual.month + 1, 0);
    final diasNoMes = ultimoDia.day;
    final inicioSemana = primeiroDia.weekday % 7; // 0: domingo, 6: sábado
    final totalCelulas = ((diasNoMes + inicioSemana) / 7).ceil() * 7;
    final dias = List<DateTime?>.generate(totalCelulas, (i) {
      final dia = i - inicioSemana + 1;
      if (dia < 1 || dia > diasNoMes) return null;
      return DateTime(mesAtual.year, mesAtual.month, dia);
    });
    final hoje = DateTime.now();

    // Filtra feriados do mês atual
    final feriadosDoMes =
        feriados.entries
            .where(
              (e) =>
                  e.key.year == mesAtual.year && e.key.month == mesAtual.month,
            )
            .toList()
          ..sort((a, b) => a.key.day.compareTo(b.key.day));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onDiaSelecionado?.call(
                DateTime(mesAtual.year, mesAtual.month - 1, 1),
              ),
            ),
            Text(
              DateFormat.yMMMM('pt_BR').format(mesAtual),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onDiaSelecionado?.call(
                DateTime(mesAtual.year, mesAtual.month + 1, 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            'D',
            'S',
            'T',
            'Q',
            'Q',
            'S',
            'S',
          ].map((d) => Expanded(child: Center(child: Text(d)))).toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1.2,
          ),
          itemCount: dias.length,
          itemBuilder: (context, i) {
            final dia = dias[i];
            if (dia == null) {
              return const SizedBox.shrink();
            }
            final isHoje =
                dia.year == hoje.year &&
                dia.month == hoje.month &&
                dia.day == hoje.day;
            final isFeriado = feriados.keys.any(
              (f) =>
                  f.year == dia.year &&
                  f.month == dia.month &&
                  f.day == dia.day,
            );
            return GestureDetector(
              onTap: () => onDiaSelecionado?.call(dia),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isHoje
                      ? Colors.blue.shade100
                      : isFeriado
                      ? Colors.red.shade100
                      : null,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isHoje
                        ? Colors.blue
                        : isFeriado
                        ? Colors.red
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${dia.day}',
                    style: TextStyle(
                      fontWeight: isHoje ? FontWeight.bold : FontWeight.normal,
                      color: isFeriado ? Colors.red : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (feriadosDoMes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Feriados do mês',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.teal.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...feriadosDoMes.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Text(
                    '${e.key.day.toString().padLeft(2, '0')}/${e.key.month.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: Colors.teal.shade900,
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
