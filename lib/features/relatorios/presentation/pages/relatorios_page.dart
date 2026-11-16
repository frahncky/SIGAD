import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../../../shared/widgets/sigad_sheet.dart';
import '../../../../shared/widgets/work_item_ui.dart';
import '../../data/relatorio_repository.dart';
import '../../domain/relatorio_models.dart';
import '../../domain/relatorios_service.dart';
import '../relatorios_l10n.dart';

/// Consulta dos relatórios disponíveis para o perfil.
///
/// A lista exibe somente o que o repositório retorna: sem dados, mostra o
/// estado vazio; com falha, o estado de erro com nova tentativa.
class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key, this.repository});

  /// Fonte dos relatórios. Padrão: [RelatorioRepository].
  final RelatorioRepository? repository;

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  String _busca = '';
  String _filtroStatus = 'Todos';
  bool _isLoading = true;
  bool _falhou = false;
  List<Relatorio> _relatorios = const [];

  late final RelatorioRepository _relatorioRepository =
      widget.repository ?? RelatorioRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _falhou = false;
    });
    try {
      final list = await _relatorioRepository.loadRelatorios();
      if (!mounted) return;
      setState(() {
        _relatorios = List<Relatorio>.unmodifiable(list);
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'relatorios_load_error',
        error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _relatorios = const [];
        _isLoading = false;
        _falhou = true;
      });
    }
  }

  Future<void> _copiarResumo(Relatorio relatorio) async {
    if (!_canAccessRelatorios()) return;
    final l10n = context.l10n;
    try {
      await Clipboard.setData(
        ClipboardData(text: RelatoriosService.resumoCompartilhavel(relatorio)),
      );
      if (!mounted) return;
      AppFeedbackService.success(context, l10n.relResumoCopiado);
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'relatorios_copy_error',
        error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      AppFeedbackService.error(context, l10n.relErroCopiar);
    }
  }

  Future<void> _enviarPorEmail(Relatorio relatorio) async {
    if (!_canAccessRelatorios()) return;
    final l10n = context.l10n;
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'SIGAD — ${relatorio.titulo}',
        'body': RelatoriosService.resumoCompartilhavel(relatorio),
      },
    );
    try {
      final abriuEmail = await launchUrl(uri);
      if (!mounted) return;
      if (abriuEmail) {
        AppFeedbackService.info(context, l10n.relEmailAberto);
      } else {
        AppFeedbackService.warning(context, l10n.relSemAppEmail);
      }
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'relatorios_email_error',
        error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      AppFeedbackService.error(context, l10n.relErroEmail);
    }
  }

  bool get _filtroAtivo => _busca.trim().isNotEmpty || _filtroStatus != 'Todos';

  @override
  Widget build(BuildContext context) {
    if (!_canAccessRelatorios(showFeedback: false)) {
      return const _RelatoriosAccessDenied();
    }

    final l10n = context.l10n;

    if (_isLoading) {
      return PageStatusView.loading(title: l10n.relCarregando);
    }
    if (_falhou) {
      return PageStatusView.error(
        title: l10n.relErroCarregar,
        actionLabel: l10n.tentarNovamente,
        onAction: _loadData,
      );
    }
    if (_relatorios.isEmpty) {
      return PageStatusView.empty(
        icon: SigadIcons.documento,
        title: l10n.relNenhumDisponivel,
        subtitle: l10n.relNenhumDisponivelDica,
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final filtrados = RelatoriosService.filtrarRelatorios(
      relatorios: _relatorios,
      busca: _busca,
      filtroStatus: _filtroStatus,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        SummaryKpiPanel(
          items: [
            SummaryKpi(label: l10n.relTotal, value: _relatorios.length),
            SummaryKpi(
              label: l10n.relPublicados,
              value: _relatorios.where((r) => r.status == 'Publicado').length,
              tone: SigadColors.success,
            ),
            SummaryKpi(
              label: l10n.relEmRevisao,
              value: _relatorios.where((r) => r.status == 'Em revisão').length,
              tone: SigadColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => _busca = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: l10n.relBuscarDica,
            prefixIcon: const SigadIcon(SigadIcons.buscar),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in RelatoriosService.statusDisponiveis)
              FilterChip(
                label: Text(l10n.opcaoRelatorio(status)),
                selected: _filtroStatus == status,
                onSelected: (_) => setState(() => _filtroStatus = status),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_filtroAtivo) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.relResultados(filtrados.length),
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (filtrados.isEmpty)
          PageStatusView.empty(
            icon: SigadIcons.buscarVazio,
            title: l10n.relNenhum,
            subtitle: l10n.relNenhumDica,
          )
        else
          for (var i = 0; i < filtrados.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _RelatorioCard(
              relatorio: filtrados[i],
              onCopiar: () => _copiarResumo(filtrados[i]),
              onEnviarEmail: () => _enviarPorEmail(filtrados[i]),
            ),
          ],
      ],
    );
  }

  bool _canAccessRelatorios({bool showFeedback = true}) {
    final role = context.read<UserContextProvider>().userRole;
    final allowed = AuthorizationPolicy.canAccessRelatorios(role);
    if (!allowed && showFeedback) {
      AppFeedbackService.warning(context, context.l10n.relSemPermissao);
    }
    return allowed;
  }
}

class _RelatoriosAccessDenied extends StatelessWidget {
  const _RelatoriosAccessDenied();

  @override
  Widget build(BuildContext context) {
    return PageStatusView(
      icon: SigadIcons.cadeado,
      title: context.l10n.relAcessoNegado,
    );
  }
}

/// Ícone que acompanha o texto do status (nunca só a cor).
IconData _iconeStatus(String status) => switch (status) {
  'Publicado' || 'Disponível' => SigadIcons.concluido,
  'Em revisão' => SigadIcons.pendente,
  'Agendado' => SigadIcons.calendario,
  _ => SigadIcons.info,
};

class _RelatorioCard extends StatelessWidget {
  const _RelatorioCard({
    required this.relatorio,
    required this.onCopiar,
    required this.onEnviarEmail,
  });

  final Relatorio relatorio;
  final VoidCallback onCopiar;
  final VoidCallback onEnviarEmail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final status = l10n.opcaoRelatorio(relatorio.status);

    return Semantics(
      button: true,
      label: l10n.relVer(relatorio.titulo),
      child: SigadSurfaceCard(
        onTap: () => _showDetalhes(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SigadIconAvatar(
                  icon: SigadIcons.documento,
                  tone: colors.primary,
                  size: 40,
                  iconSize: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relatorio.id,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // O título completo aparece nos detalhes.
                      Text(
                        relatorio.titulo,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: l10n.relMaisAcoes,
                  onSelected: (value) => _onMenuItemSelected(context, value),
                  itemBuilder: (context) => [
                    _menuItem('visualizar', SigadIcons.visivel, l10n.relVisualizar),
                    _menuItem(
                      'copiar',
                      SigadIcons.documentoResumo,
                      l10n.relCopiarResumo,
                    ),
                    _menuItem('email', SigadIcons.email, l10n.relEnviarEmail),
                  ],
                  icon: const SigadIcon(SigadIcons.maisOpcoes, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              relatorio.descricao,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ToneChip(
                  label: l10n.opcaoRelatorio(relatorio.tipo),
                  tone: SigadColors.brand,
                ),
                Semantics(
                  container: true,
                  label: l10n.relStatusRotulo(status),
                  excludeSemantics: true,
                  child: ToneChip(
                    label: status,
                    tone: RelatoriosService.statusColor(relatorio.status),
                    icon: _iconeStatus(relatorio.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                MetaLabel(icon: SigadIcons.calendario, text: relatorio.data),
                MetaLabel(icon: SigadIcons.pessoa, text: relatorio.autor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          SigadIcon(icon, size: 18),
          const SizedBox(width: 12),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }

  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'visualizar':
        _showDetalhes(context);
      case 'copiar':
        onCopiar();
      case 'email':
        onEnviarEmail();
    }
  }

  void _showDetalhes(BuildContext context) {
    final l10n = context.l10n;
    showSigadSheet<void>(
      context: context,
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        final colors = Theme.of(sheetContext).colorScheme;
        return SigadSheetFrame(
          title: relatorio.titulo,
          closeTooltip: l10n.relFecharDetalhes,
          onClose: () => Navigator.pop(sheetContext),
          leading: Text(
            relatorio.id,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DetailRow(label: l10n.demDescricao, value: relatorio.descricao),
              DetailRow(
                label: l10n.relTipo,
                value: l10n.opcaoRelatorio(relatorio.tipo),
              ),
              DetailRow(label: l10n.relAutor, value: relatorio.autor),
              DetailRow(label: l10n.atvData, value: relatorio.data),
              DetailRow(
                label: l10n.demStatus,
                value: l10n.opcaoRelatorio(relatorio.status),
              ),
            ],
          ),
          footer: SigadDualActions(
            // Lado a lado só em telas com 400 ou mais de largura (o sheet
            // tem 24 de margem de cada lado) e fonte até 130%.
            minSideBySideWidth: 352,
            secondaryLabel: l10n.relCopiarResumo,
            secondaryIcon: SigadIcons.documentoResumo,
            onSecondary: () {
              Navigator.pop(sheetContext);
              onCopiar();
            },
            primaryLabel: l10n.relEnviarEmail,
            primaryIcon: SigadIcons.email,
            onPrimary: () {
              Navigator.pop(sheetContext);
              onEnviarEmail();
            },
          ),
        );
      },
    );
  }
}
