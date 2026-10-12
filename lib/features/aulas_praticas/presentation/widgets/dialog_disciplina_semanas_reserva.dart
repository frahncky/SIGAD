import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../laboratorio_l10n.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../domain/reserva_models.dart';

/// Formulário "Reservar horário": mostra o que está sendo reservado e pede a
/// disciplina, a repetição semanal e, opcionalmente, outros horários do dia.
class DialogDisciplinaSemanasReserva extends StatefulWidget {
  const DialogDisciplinaSemanasReserva({
    super.key,
    required this.diaSemanaCompleto,
    required this.laboratorio,
    required this.horarioInicial,
    required this.ultimoDiaDoMes,
    required this.maxSemanas,
    required this.horarios,
    required this.turnoInicial,
    required this.periodoInicial,
    required this.isOcupado,
  });

  /// Data por extenso, ex.: "segunda-feira, 12/10/2026".
  final String diaSemanaCompleto;
  final String laboratorio;
  final String horarioInicial;

  /// Último dia do mês (dd/mm): a repetição não passa dele.
  final String ultimoDiaDoMes;

  /// Quantas semanas cabem até o fim do mês, contando a atual.
  final int maxSemanas;
  final List<HorarioGridRow> horarios;
  final Turno turnoInicial;
  final int periodoInicial;
  final bool Function(Turno turno, int periodo) isOcupado;

  @override
  State<DialogDisciplinaSemanasReserva> createState() =>
      DialogDisciplinaSemanasReservaState();
}

class DialogDisciplinaSemanasReservaState
    extends State<DialogDisciplinaSemanasReserva> {
  final TextEditingController _disciplinaController = TextEditingController();
  int _totalSemanas = 1;
  late final Set<String> _periodosSelecionados;

  @override
  void initState() {
    super.initState();
    _periodosSelecionados = {
      _chave(widget.turnoInicial, widget.periodoInicial),
    };
  }

  @override
  void dispose() {
    _disciplinaController.dispose();
    super.dispose();
  }

  String _chave(Turno turno, int periodo) => '${turno.name}|$periodo';

  void _alternarPeriodo(Turno turno, int periodo) {
    final chave = _chave(turno, periodo);
    setState(() {
      if (_periodosSelecionados.contains(chave)) {
        if (_periodosSelecionados.length > 1) {
          _periodosSelecionados.remove(chave);
        }
      } else {
        _periodosSelecionados.add(chave);
      }
    });
  }

  String _rotuloSemanas(int total) => total == 1
      ? context.l10n.labSoEstaSemana
      : context.l10n.labEstaEMais(total - 1);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final maxSemanas = widget.maxSemanas.clamp(1, 6);
    final extras = _periodosSelecionados.length - 1;

    Widget info(IconData icone, String texto) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SigadIcon(icone, size: 18, color: SigadColors.brand),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: textTheme.bodyMedium)),
        ],
      ),
    );

    return TelaFormularioReserva(
      titulo: context.l10n.labReservarHorario,
      acaoLabel: context.l10n.reservar,
      acaoIcone: SigadIcons.eventoConfirmado,
      onAcao: _confirmar,
      children: [
        info(SigadIcons.laboratorio, widget.laboratorio),
        info(SigadIcons.calendario, widget.diaSemanaCompleto),
        info(
          SigadIcons.relogio,
          extras == 0
              ? widget.horarioInicial
              : context.l10n.labHorarioEMais(widget.horarioInicial, extras),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _disciplinaController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: context.l10n.labDisciplinaOpcional,
          ),
        ),
        const SizedBox(height: 16),
        Text(context.l10n.labRepetir, style: textTheme.labelLarge),
        DropdownButton<int>(
          isExpanded: true,
          value: _totalSemanas.clamp(1, maxSemanas),
          items: [
            for (var total = 1; total <= maxSemanas; total++)
              DropdownMenuItem(
                value: total,
                child: Text(_rotuloSemanas(total)),
              ),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _totalSemanas = v);
          },
        ),
        Text(
          context.l10n.labRepeticaoAte(widget.ultimoDiaDoMes),
          style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Text(
              context.l10n.labOutrosHorarios,
              style: textTheme.labelLarge,
            ),
            children: [
              for (final turno in Turno.values) ...[
                Text(
                  context.l10n.turno(turno),
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: turno.chipTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final linha in widget.horarios.where(
                      (item) => item.turno == turno,
                    ))
                      _PeriodoChip(
                        label: linha.horario.split('-').first,
                        selecionado: _periodosSelecionados.contains(
                          _chave(turno, linha.periodo),
                        ),
                        ocupado: widget.isOcupado(turno, linha.periodo),
                        onTap: () => _alternarPeriodo(turno, linha.periodo),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _confirmar() {
    Navigator.of(context).pop({
      'disciplina': _disciplinaController.text.trim().isEmpty
          ? null
          : _disciplinaController.text.trim(),
      'totalSemanas': _totalSemanas.clamp(1, widget.maxSemanas.clamp(1, 6)),
      'periodos': _periodosSelecionados
          .map((chave) {
            final partes = chave.split('|');
            return {'turno': partes[0], 'periodo': int.parse(partes[1])};
          })
          .toList(growable: false),
    });
  }
}

class _PeriodoChip extends StatelessWidget {
  const _PeriodoChip({
    required this.label,
    required this.selecionado,
    required this.ocupado,
    required this.onTap,
  });

  final String label;
  final bool selecionado;
  final bool ocupado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: ocupado
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      selected: selecionado,
      onSelected: ocupado ? null : (_) => onTap(),
      tooltip: ocupado ? context.l10n.labHorarioJaOcupado : null,
    );
  }
}

/// Tela inteira usada pelos formulários e detalhes de reserva: título com
/// botão de fechar, conteúdo com rolagem e a ação principal fixa embaixo.
class TelaFormularioReserva extends StatelessWidget {
  const TelaFormularioReserva({
    super.key,
    required this.titulo,
    required this.children,
    this.acaoLabel,
    this.acaoIcone,
    this.onAcao,
    this.acaoSecundaria,
  });

  final String titulo;
  final List<Widget> children;
  final String? acaoLabel;
  final IconData? acaoIcone;
  final VoidCallback? onAcao;
  final Widget? acaoSecundaria;

  @override
  Widget build(BuildContext context) {
    final acaoLabel = this.acaoLabel;
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: children,
      ),
      bottomNavigationBar: acaoLabel == null && acaoSecundaria == null
          ? null
          : SafeArea(
              child: Padding(
                // Sobe junto com o teclado para o botão continuar visível.
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  12 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (acaoLabel != null)
                      FilledButton.icon(
                        onPressed: onAcao,
                        icon: SigadIcon(acaoIcone ?? SigadIcons.confirmar),
                        label: Text(acaoLabel),
                      ),
                    if (acaoSecundaria != null) ...[
                      const SizedBox(height: 8),
                      acaoSecundaria!,
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
