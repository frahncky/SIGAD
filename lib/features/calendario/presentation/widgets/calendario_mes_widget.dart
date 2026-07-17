import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/sigad_colors.dart';

class CalendarioMesWidget extends StatelessWidget {
  final DateTime mesAtual;
  final DateTime? diaSelecionado;
  final Map<DateTime, String> feriados;
  final Map<DateTime, List<Color>> marcadores;
  final void Function(DateTime)? onDiaSelecionado;

  const CalendarioMesWidget({
    super.key,
    required this.mesAtual,
    this.diaSelecionado,
    this.feriados = const {},
    this.marcadores = const {},
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => onDiaSelecionado?.call(
                DateTime(mesAtual.year, mesAtual.month - 1, 1),
              ),
            ),
            Text(
              _capitalizar(DateFormat.yMMMM('pt_BR').format(mesAtual)),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => onDiaSelecionado?.call(
                DateTime(mesAtual.year, mesAtual.month + 1, 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 2,
            childAspectRatio: 1.05,
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
            final isSelecionado =
                diaSelecionado != null &&
                dia.year == diaSelecionado!.year &&
                dia.month == diaSelecionado!.month &&
                dia.day == diaSelecionado!.day;
            final isFeriado = feriados.keys.any(
              (f) =>
                  f.year == dia.year &&
                  f.month == dia.month &&
                  f.day == dia.day,
            );
            final pontos = marcadores.entries
                .where(
                  (e) =>
                      e.key.year == dia.year &&
                      e.key.month == dia.month &&
                      e.key.day == dia.day,
                )
                .expand((e) => e.value)
                .toList();

            return GestureDetector(
              onTap: () => onDiaSelecionado?.call(dia),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelecionado ? SigadColors.brand : null,
                      shape: BoxShape.circle,
                      border: !isSelecionado && isHoje
                          ? Border.all(color: SigadColors.brand, width: 1.4)
                          : null,
                    ),
                    child: Text(
                      '${dia.day}',
                      style: TextStyle(
                        fontWeight: isSelecionado || isHoje
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isSelecionado
                            ? Colors.white
                            : isFeriado
                            ? SigadColors.risk
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 6,
                    child: pontos.isEmpty
                        ? null
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: pontos
                                .take(3)
                                .map(
                                  (cor) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _capitalizar(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
}
