import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/horizontal_scroll_hint.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../data/relatorio_repository.dart';
import '../../domain/relatorio_models.dart';
import '../../domain/relatorios_service.dart';
import '../relatorios_l10n.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  String _busca = '';
  String _filtroStatus = 'Todos';
  bool _isLoading = true;
  bool _usandoDadosDemonstracao = true;
  String? _loadError;

  final RelatorioRepository _relatorioRepository = RelatorioRepository();
  final List<Relatorio> _relatorios = List<Relatorio>.of(
    RelatoriosService.defaultRelatorios(),
    growable: true,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final list = await _relatorioRepository.loadRelatorios();
      if (!mounted) return;
      setState(() {
        if (list.isNotEmpty) {
          _relatorios
            ..clear()
            ..addAll(list);
          _usandoDadosDemonstracao = false;
        }
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
        _isLoading = false;
        _loadError = context.l10n.relErroCarregar;
      });
    }
  }

  Future<void> _baixarRelatorio(Relatorio relatorio) async {
    if (!_canAccessRelatorios()) return;
    try {
      await Clipboard.setData(
        ClipboardData(text: RelatoriosService.resumoCompartilhavel(relatorio)),
      );
      if (!mounted) return;
      AppFeedbackService.success(
        context,
        'Resumo copiado. Não foi gerado um arquivo PDF.',
      );
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'relatorios_copy_error',
        error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      AppFeedbackService.error(context, 'Não foi possível copiar o resumo.');
    }
  }

  Future<void> _compartilharRelatorio(Relatorio relatorio) async {
    if (!_canAccessRelatorios()) return;
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
        AppFeedbackService.info(
          context,
          'Rascunho aberto no aplicativo de e-mail. Confirme o envio nele.',
        );
      } else {
        AppFeedbackService.warning(
          context,
          'Nenhum aplicativo de e-mail está disponível.',
        );
      }
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'relatorios_email_error',
        error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      AppFeedbackService.error(context, 'Não foi possível abrir o e-mail.');
    }
  }

  List<Relatorio> get _relatoriosFiltrados =>
      RelatoriosService.filtrarRelatorios(
        relatorios: _relatorios,
        busca: _busca,
        filtroStatus: _filtroStatus,
      );

  @override
  Widget build(BuildContext context) {
    if (!_canAccessRelatorios(showFeedback: false)) {
      return const _RelatoriosAccessDenied();
    }

    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final relatoriosFiltrados = _relatoriosFiltrados;
    final shouldShowScrollHint = MediaQuery.of(context).size.width < 640;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _RelatoriosSummaryBanner(
            totalRelatorios: _relatorios.length,
            publicados: _relatorios
                .where((r) => r.status == 'Publicado')
                .length,
            emRevisao: _relatorios
                .where((r) => r.status.toLowerCase().contains('revis'))
                .length,
          ),
          if (_usandoDadosDemonstracao) ...[
            const SizedBox(height: 12),
            Text(
              Localizations.localeOf(context).languageCode == 'en'
                  ? 'Demonstration records: these are not institutional documents or downloadable PDF files.'
                  : 'Registros demonstrativos: não são documentos institucionais nem arquivos PDF disponíveis para download.',
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _busca = value),
            decoration: InputDecoration(
              hintText: l10n.relBuscarDica,
              prefixIcon: const SigadIcon(SigadIcons.buscar),
            ),
          ),
          const SizedBox(height: 12),
          if (shouldShowScrollHint) ...[
            HorizontalScrollHint(message: l10n.relArrasteDica),
            const SizedBox(height: 10),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: RelatoriosService.statusDisponiveis
                  .map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(l10n.opcaoRelatorio(status)),
                        selected: _filtroStatus == status,
                        onSelected: (_) =>
                            setState(() => _filtroStatus = status),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SigadColors.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SigadColors.brand.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const SigadIcon(SigadIcons.info, color: SigadColors.brand),
                const SizedBox(width: 12),
                Text(
                  '${relatoriosFiltrados.length}',
                  style: textTheme.titleLarge?.copyWith(
                    color: SigadColors.brand,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.relDisponiveisConsulta,
                    style: textTheme.bodySmall?.copyWith(
                      color: SigadColors.brand,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            SizedBox(
              height: 320,
              child: PageStatusView.loading(title: l10n.relCarregando),
            )
          else if (_loadError != null)
            SizedBox(
              height: 320,
              child: PageStatusView.error(
                title: l10n.demErroCarregarTitulo,
                subtitle: _loadError,
                actionLabel: l10n.tentarNovamente,
                onAction: _loadData,
              ),
            )
          else if (relatoriosFiltrados.isEmpty)
            SizedBox(
              height: 320,
              child: PageStatusView.empty(
                icon: SigadIcons.documento,
                title: l10n.relNenhum,
                subtitle: l10n.relNenhumDica,
              ),
            )
          else
            ...relatoriosFiltrados.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < relatoriosFiltrados.length - 1 ? 12 : 0,
                ),
                child: _RelatorioCard(
                  relatorio: entry.value,
                  index: entry.key,
                  onBaixar: () => _baixarRelatorio(entry.value),
                  onCompartilhar: () => _compartilharRelatorio(entry.value),
                ),
              ),
            ),
        ],
      ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SigadIcon(SigadIcons.cadeado, size: 56),
            const SizedBox(height: 12),
            Text(
              context.l10n.relAcessoNegado,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatoriosSummaryBanner extends StatelessWidget {
  const _RelatoriosSummaryBanner({
    required this.totalRelatorios,
    required this.publicados,
    required this.emRevisao,
  });

  final int totalRelatorios;
  final int publicados;
  final int emRevisao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SigadIconAvatar(
                icon: SigadIcons.documentoResumo,
                tone: SigadColors.brand,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.relCentral,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RelatoriosKpi(
                label: context.l10n.relDisponiveis,
                value: '$totalRelatorios',
                tone: SigadColors.brand,
              ),
              const SizedBox(width: 8),
              _RelatoriosKpi(
                label: context.l10n.relPublicados,
                value: '$publicados',
                tone: SigadColors.success,
              ),
              const SizedBox(width: 8),
              _RelatoriosKpi(
                label: context.l10n.relEmRevisao,
                value: '$emRevisao',
                tone: SigadColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelatoriosKpi extends StatelessWidget {
  const _RelatoriosKpi({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SigadColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatorioCard extends StatelessWidget {
  const _RelatorioCard({
    required this.relatorio,
    required this.index,
    required this.onBaixar,
    required this.onCompartilhar,
  });

  final Relatorio relatorio;
  final int index;
  final VoidCallback onBaixar;
  final VoidCallback onCompartilhar;

  Color _toneParaTipo(String tipo) {
    switch (tipo) {
      case 'Análise Geral':
        return SigadColors.brand;
      case 'Recursos Humanos':
        return SigadColors.warning;
      case 'Desempenho':
        return SigadColors.success;
      case 'Infraestrutura':
        return SigadColors.info;
      case 'Conformidade':
        return SigadColors.risk;
      default:
        return sigadToneForIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: context.l10n.relVer(relatorio.titulo),
      child: GestureDetector(
        onTap: () => _showDetalhes(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SigadColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SigadColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SigadIconAvatar(
                    icon: SigadIcons.documento,
                    tone: _toneParaTipo(relatorio.tipo),
                    size: 40,
                    iconSize: 20,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          relatorio.id,
                          style: textTheme.labelSmall?.copyWith(
                            color: SigadColors.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          relatorio.titulo,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                relatorio.descricao,
                style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Tipo e status quebram linha quando não cabem lado a lado;
                  // o tipo completo também aparece nos detalhes.
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: SigadColors.brand.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.opcaoRelatorio(relatorio.tipo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: SigadColors.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: RelatoriosService.statusColor(
                              relatorio.status,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.opcaoRelatorio(relatorio.status),
                            style: textTheme.labelSmall?.copyWith(
                              color: RelatoriosService.statusColor(
                                relatorio.status,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: context.l10n.relMaisAcoes,
                    onSelected: (value) => _onMenuItemSelected(context, value),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'visualizar',
                        child: Row(
                          children: [
                            const SigadIcon(SigadIcons.visivel, size: 18),
                            const SizedBox(width: 8),
                            Text(context.l10n.relVisualizar),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'baixar',
                        child: Row(
                          children: [
                            const SigadIcon(SigadIcons.baixar, size: 18),
                            const SizedBox(width: 8),
                            Text(Localizations.localeOf(context).languageCode == 'en' ? 'Copy summary' : 'Copiar resumo'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'compartilhar',
                        child: Row(
                          children: [
                            const SigadIcon(SigadIcons.compartilhar, size: 18),
                            const SizedBox(width: 8),
                            Text(Localizations.localeOf(context).languageCode == 'en' ? 'Send by email' : 'Enviar por e-mail'),
                          ],
                        ),
                      ),
                    ],
                    icon: const SigadIcon(SigadIcons.maisOpcoes, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: _InfoChip(
                      icon: SigadIcons.calendario,
                      label: relatorio.data,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _InfoChip(
                      icon: SigadIcons.pessoa,
                      label: relatorio.autor,
                    ),
                  ),
                ],
              ),
              if (relatorio.ultimaAcao != null) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.opcaoRelatorio(relatorio.ultimaAcao!),
                  style: textTheme.labelSmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'visualizar':
        _showDetalhes(context);
        break;
      case 'baixar':
        onBaixar();
        break;
      case 'compartilhar':
        onCompartilhar();
        break;
    }
  }

  void _showDetalhes(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          relatorio.id,
                          style: textTheme.labelSmall?.copyWith(
                            color: SigadColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width:
                              260, // valor fixo ou ajuste conforme necessário
                          child: Text(
                            relatorio.titulo,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.relFecharDetalhes,
                    onPressed: () => Navigator.pop(context),
                    icon: const SigadIcon(SigadIcons.fechar),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(
                label: context.l10n.demDescricao,
                value: relatorio.descricao,
              ),
              _DetailSection(
                label: context.l10n.relTipo,
                value: context.l10n.opcaoRelatorio(relatorio.tipo),
              ),
              _DetailSection(
                label: context.l10n.relAutor,
                value: relatorio.autor,
              ),
              _DetailSection(
                label: context.l10n.atvData,
                value: relatorio.data,
              ),
              _DetailSection(
                label: context.l10n.demStatus,
                value: context.l10n.opcaoRelatorio(relatorio.status),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onBaixar();
                      },
                      icon: const SigadIcon(SigadIcons.baixar),
                      label: Text(Localizations.localeOf(context).languageCode == 'en' ? 'Copy summary' : 'Copiar resumo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onCompartilhar();
                      },
                      icon: const SigadIcon(SigadIcons.compartilhar),
                      label: Text(Localizations.localeOf(context).languageCode == 'en' ? 'Send by email' : 'Enviar por e-mail'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SigadIcon(icon, size: 14, color: SigadColors.muted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: SigadColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
