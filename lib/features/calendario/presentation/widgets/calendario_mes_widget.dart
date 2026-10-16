import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../l10n/l10n.dart';
import '../calendario_l10n.dart';

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

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = l10n.localeDatas;
    // 7/1/2024 foi um domingo: base para os nomes dos dias da semana.
    final semana = [for (var i = 0; i < 7; i++) DateTime(2024, 1, 7 + i)];
    final diasSemanaAbreviados = [
      for (final dia in semana)
        DateFormat.E(locale).format(dia).replaceAll('.', '').toUpperCase(),
    ];
    final diasSemanaCompactos = [
      for (final dia in semana) DateFormat('EEEEE', locale).format(dia),
    ];
    final diasSemanaCompletos = [
      for (final dia in semana) DateFormat.EEEE(locale).format(dia),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const espacamentoHorizontal = 2.0;
        final larguraCelula =
            (constraints.maxWidth - (espacamentoHorizontal * 6)) / 7;
        final diametroDia = larguraCelula < 34.0 ? larguraCelula : 34.0;
        final usarRotulosCompactos =
            MediaQuery.textScalerOf(context).scale(12) * 2.2 > larguraCelula;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.calMesAnterior,
                  icon: const SigadIcon(SigadIcons.chevronEsquerda),
                  onPressed: onDiaSelecionado == null
                      ? null
                      : () => onDiaSelecionado!(
                          DateTime(mesAtual.year, mesAtual.month - 1, 1),
                        ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    _capitalizar(DateFormat.yMMMM(locale).format(mesAtual)),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.calProximoMes,
                  icon: const SigadIcon(SigadIcons.chevronDireita),
                  onPressed: onDiaSelecionado == null
                      ? null
                      : () => onDiaSelecionado!(
                          DateTime(mesAtual.year, mesAtual.month + 1, 1),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(diasSemanaCompletos.length, (index) {
                return Expanded(
                  child: Semantics(
                    header: true,
                    label: diasSemanaCompletos[index],
                    excludeSemantics: true,
                    child: Center(
                      child: Text(
                        usarRotulosCompactos
                            ? diasSemanaCompactos[index]
                            : diasSemanaAbreviados[index],
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: espacamentoHorizontal,
                mainAxisExtent: 48,
              ),
              itemCount: dias.length,
              itemBuilder: (context, i) {
                final dia = dias[i];
                if (dia == null) {
                  return const SizedBox.shrink();
                }
                final isHoje = DateUtils.isSameDay(dia, hoje);
                final isSelecionado = DateUtils.isSameDay(dia, diaSelecionado);
                final feriado = _feriadoEm(dia);
                final pontos = marcadores.entries
                    .where((e) => DateUtils.isSameDay(e.key, dia))
                    .expand((e) => e.value)
                    .toList(growable: false);
                final quantidadeEventos = pontos.length;
                final descricaoSemantica = <String>[
                  _capitalizar(DateFormat.yMMMMEEEEd(locale).format(dia)),
                  if (isHoje) l10n.calHoje,
                  if (feriado != null) l10n.calFeriado(feriado),
                  l10n.calEventos(quantidadeEventos),
                ].join(', ');

                return Semantics(
                  button: onDiaSelecionado != null,
                  enabled: onDiaSelecionado != null,
                  selected: isSelecionado,
                  label: descricaoSemantica,
                  onTap: onDiaSelecionado == null
                      ? null
                      : () => onDiaSelecionado!(dia),
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onDiaSelecionado == null
                        ? null
                        : () => onDiaSelecionado!(dia),
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: diametroDia,
                          height: diametroDia,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelecionado ? SigadColors.brand : null,
                            shape: BoxShape.circle,
                            border: !isSelecionado && isHoje
                                ? Border.all(
                                    color: SigadColors.brand,
                                    width: 1.4,
                                  )
                                : null,
                          ),
                          child: Text(
                            '${dia.day}',
                            maxLines: 1,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: isSelecionado || isHoje
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isSelecionado
                                  ? Colors.white
                                  : feriado != null
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
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String? _feriadoEm(DateTime dia) {
    for (final entry in feriados.entries) {
      if (DateUtils.isSameDay(entry.key, dia)) return entry.value;
    }
    return null;
  }

  String _capitalizar(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
}
