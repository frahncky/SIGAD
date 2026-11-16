import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../atividades/data/atividade_repository.dart';
import '../../../atividades/domain/atividade_models.dart';
import '../../../aulas_praticas/data/laboratorio_repository.dart';
import '../../../aulas_praticas/domain/laboratorio_models.dart';
import '../../../demandas/data/demanda_repository.dart';
import '../../../demandas/domain/demanda_models.dart';
import '../../../home/presentation/pages/home_shell_page.dart';
import '../../../kanban/data/kanban_repository.dart';
import '../../../kanban/domain/kanban_models.dart';
import '../../../mural/presentation/mural_visual.dart';
import '../../../mural/presentation/state/mural_controller.dart';
import '../../domain/dashboard_summary.dart';
import '../widgets/overview_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.agora});

  /// Instante opcional para manter as boas-vindas determinísticas.
  final DateTime? agora;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadDashboardData();
  }

  Future<_DashboardData> _loadDashboardData() async {
    // Demandas só são consultadas por quem pode gerenciá-las; assim uma
    // recusa do servidor para outros perfis não derruba a Visão geral.
    final role = context.read<UserContextProvider>().userRole;
    final results = await Future.wait<Object>([
      AuthorizationPolicy.canManageDemandas(role)
          ? DemandaRepository().loadDemandas()
          : Future.value(const <Demanda>[]),
      KanbanRepository().loadCards(),
      AtividadeRepository().loadAtividades(),
      LaboratorioRepository().load(),
    ]);

    return _DashboardData(
      demandas: results[0] as List<Demanda>,
      cards: results[1] as List<KanbanCardModel>,
      atividades: results[2] as List<Atividade>,
      laboratorios: results[3] as List<Laboratorio>,
    );
  }

  /// Topo fixo só quando sobra espaço útil para rolar os cards.
  static const _fracaoMaximaDoTopo = 0.55;
  final _chaveTopo = GlobalKey();

  /// Altura medida do topo; nula até o primeiro quadro, que sempre rola
  /// junto para nunca estourar a tela antes da medição.
  double? _alturaTopo;

  bool _topoCabeFixo(double alturaDisponivel) {
    final altura = _alturaTopo;
    return altura != null &&
        alturaDisponivel.isFinite &&
        altura <= alturaDisponivel * _fracaoMaximaDoTopo;
  }

  void _medirTopo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final caixa = _chaveTopo.currentContext?.findRenderObject();
      if (caixa is! RenderBox || !caixa.hasSize) return;
      final altura = caixa.size.height;
      final anterior = _alturaTopo;
      if (anterior == null || (anterior - altura).abs() > 0.5) {
        setState(() => _alturaTopo = altura);
      }
    });
  }

  Future<void> _refresh() async {
    final next = _loadDashboardData();
    setState(() => _dashboardData = next);
    try {
      await next;
    } catch (_) {
      // O FutureBuilder já mostra o estado de erro com "Tentar novamente".
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserContextProvider>().userRole;
    final mural = _maybeMural(context);
    final avisos = mural?.avisosVisiveis(role) ?? const [];
    final agora = widget.agora ?? DateTime.now();
    final fundo = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerLowest
        : SigadColors.canvas;
    const sobreposicao = 20.0;

    return FutureBuilder<_DashboardData>(
      future: _dashboardData,
      builder: (context, snapshot) {
        final carregando = snapshot.connectionState != ConnectionState.done;
        final data = carregando || snapshot.hasError ? null : snapshot.data;
        final resumo = data == null
            ? null
            : DashboardSummary.calcular(
                demandas: data.demandas,
                cards: data.cards,
                atividades: data.atividades,
                laboratorios: data.laboratorios,
                agora: agora,
              );

        final conteudo = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Indicadores(role: role, resumo: resumo, carregando: carregando),
            const SizedBox(height: 22),
            _CustomizableIndicators(role: role),
            if (carregando) ...[
              const SizedBox(height: 22),
              const _DashboardLoading(),
            ] else if (snapshot.hasError) ...[
              const SizedBox(height: 22),
              _DashboardInlineError(onRetry: _refresh),
            ],
            const SizedBox(height: 16),
          ],
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            _medirTopo();
            final topoFixo = _topoCabeFixo(constraints.maxHeight);
            final cabecalho = KeyedSubtree(
              key: _chaveTopo,
              child: OverviewHeader(
                agora: agora,
                frase: mural?.fraseAtual?.texto,
                onNotificacoes: () => mostrarNotificacoes(context),
                onPerfil: () => mostrarMenuPerfil(context),
                avisos: [
                  for (final aviso in avisos)
                    AvisoNoTopo(
                      icone: aviso.modelo.icone,
                      titulo: aviso.titulo,
                      conteudo: aviso.conteudo,
                    ),
                ],
                bottomInset: sobreposicao,
              ),
            );
            const cantoDoPainel = BorderRadius.vertical(
              top: Radius.circular(28),
            );

            if (topoFixo) {
              // O topo fica parado; só o painel dos cards rola por baixo
              // da borda arredondada, que faz parte do topo.
              return ColoredBox(
                color: fundo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        cabecalho,
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: sobreposicao,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: fundo,
                              borderRadius: cantoDoPainel,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: SingleChildScrollView(
                          key: const Key('dashboard-rolagem'),
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
                          child: conteudo,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Tela baixa ou fonte muito grande: o topo fixo tomaria quase
            // toda a altura, então ele rola junto com o conteúdo.
            return RefreshIndicator(
              onRefresh: _refresh,
              // O topo fica sob a barra de status.
              edgeOffset: MediaQuery.paddingOf(context).top,
              child: ColoredBox(
                color: fundo,
                child: SingleChildScrollView(
                  key: const Key('dashboard-rolagem'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      cabecalho,
                      Transform.translate(
                        offset: const Offset(0, -sobreposicao),
                        child: Container(
                          decoration: BoxDecoration(
                            color: fundo,
                            borderRadius: cantoDoPainel,
                          ),
                          padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
                          child: conteudo,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.demandas,
    required this.cards,
    required this.atividades,
    required this.laboratorios,
  });

  final List<Demanda> demandas;
  final List<KanbanCardModel> cards;
  final List<Atividade> atividades;
  final List<Laboratorio> laboratorios;
}

bool _rotaDisponivel(UserRole? role, String route) {
  if (role == null) return true;
  for (final item in kNavigationItems) {
    if (item.route == route) return item.isAvailableFor(role);
  }
  return false;
}

/// Ajusta o tom para manter contraste no tema claro e no escuro.
Color _tomLegivel(BuildContext context, Color tom) {
  final escuro = Theme.of(context).brightness == Brightness.dark;
  return escuro
      ? Color.lerp(tom, Colors.white, 0.45)!
      : Color.lerp(tom, Colors.black, 0.26)!;
}

// ---------------------------------------------------------------------------
// Indicadores
// ---------------------------------------------------------------------------

class _IndicadorDef {
  const _IndicadorDef({
    required this.id,
    required this.titulo,
    required this.icone,
    required this.tom,
    required this.valor,
    required this.detalhe,
    required this.route,
  });

  final String id;
  final String titulo;
  final IconData icone;
  final Color tom;
  final int? valor;
  final String detalhe;
  final String route;
}

class _Indicadores extends StatelessWidget {
  const _Indicadores({
    required this.role,
    required this.resumo,
    required this.carregando,
  });

  final UserRole? role;
  final DashboardSummary? resumo;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resumo = this.resumo;
    String detalhe(String Function(DashboardSummary r) texto) => resumo == null
        ? (carregando ? l10n.atualizandoInformacoes : l10n.dadosIndisponiveis)
        : texto(resumo);

    final indicadores = [
      if (AuthorizationPolicy.canManageDemandas(role))
        _IndicadorDef(
          id: 'demandas',
          titulo: l10n.navDemandas,
          icone: SigadIcons.demanda,
          tom: SigadColors.success,
          valor: resumo?.demandasAbertas,
          detalhe: detalhe((r) => l10n.vgPrioritarias(r.demandasPrioritarias)),
          route: AppRoutes.demandas,
        ),
      _IndicadorDef(
        id: 'tarefas',
        titulo: l10n.navTarefas,
        icone: SigadIcons.concluido,
        tom: SigadColors.info,
        valor: resumo?.tarefasAbertas,
        detalhe: detalhe((r) => l10n.vgEmAndamento(r.tarefasEmAndamento)),
        route: AppRoutes.kanban,
      ),
      _IndicadorDef(
        id: 'atividades',
        titulo: l10n.navAtividades,
        icone: SigadIcons.calendario,
        tom: SigadColors.violet,
        valor: resumo?.atividadesAbertas,
        detalhe: detalhe((r) => l10n.vgEstaSemana(r.atividadesSemana)),
        route: AppRoutes.atividades,
      ),
      if (_rotaDisponivel(role, AppRoutes.aulasPraticas))
        _IndicadorDef(
          id: 'laboratorios',
          titulo: l10n.navLaboratorios,
          icone: SigadIcons.laboratorio,
          tom: SigadColors.warning,
          valor: resumo?.laboratorios,
          detalhe: detalhe(
            (r) => l10n.vgLabsManutencao(r.laboratoriosManutencao),
          ),
          route: AppRoutes.aulasPraticas,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const espaco = 8.0;
        final medidas = _MedidasIndicador(context);
        final colunas = colunasIndicadores(
          larguraDisponivel: constraints.maxWidth,
          larguraMinimaCard: medidas.larguraMinima(indicadores),
          quantidade: indicadores.length,
          espaco: espaco,
        );
        final larguraCard =
            (constraints.maxWidth - (colunas - 1) * espaco) / colunas;
        final linhas = [
          for (var i = 0; i < indicadores.length; i += colunas)
            indicadores.skip(i).take(colunas).toList(growable: false),
        ];
        return Column(
          children: [
            for (final linha in linhas) ...[
              if (linha != linhas.first) const SizedBox(height: espaco),
              // Cards da mesma linha ficam com a mesma altura.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < colunas; i++) ...[
                      if (i > 0) const SizedBox(width: espaco),
                      Expanded(
                        child: i < linha.length
                            ? _IndicadorCard(
                                item: linha[i],
                                nomeAoLado: medidas.nomeCabeAoLado(
                                  linha[i],
                                  larguraCard,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Mede os textos dos indicadores com a fonte e a escala atuais.
class _MedidasIndicador {
  _MedidasIndicador(this.context) : estilos = _IndicadorCard.estilos(context);

  final BuildContext context;
  final _EstilosIndicador estilos;

  double medir(String texto, TextStyle? estilo) {
    final painter = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final largura = painter.width;
    painter.dispose();
    return largura;
  }

  double _valor(_IndicadorDef item) =>
      medir(item.valor?.toString() ?? '—', estilos.valor);

  /// Área útil do card, descontadas a margem interna e a borda.
  static double _interna(double larguraCard) =>
      larguraCard - _IndicadorCard.padding * 2 - 2;

  /// Número e nome cabem lado a lado na primeira linha do card?
  bool nomeCabeAoLado(_IndicadorDef item, double larguraCard) =>
      _valor(item) +
          _IndicadorCard.espacoNome +
          medir(item.titulo, estilos.titulo) <=
      _interna(larguraCard) - 1;

  /// Menor largura em que nenhum texto do card é partido no meio da palavra.
  /// Considera o nome abaixo do número, a forma mais estreita do card.
  double larguraMinima(List<_IndicadorDef> indicadores) {
    var necessaria = 0.0;
    for (final item in indicadores) {
      var maiorPalavra = 0.0;
      for (final palavra in item.detalhe.split(RegExp(r'\s+'))) {
        final largura = medir(palavra, estilos.detalhe);
        if (largura > maiorPalavra) maiorPalavra = largura;
      }
      final candidatos = [
        medir(item.titulo, estilos.titulo),
        _valor(item),
        _IndicadorCard.seloPadding * 2 +
            _IndicadorCard.iconeSelo +
            _IndicadorCard.espacoIconeSelo +
            maiorPalavra,
      ];
      for (final largura in candidatos) {
        if (largura > necessaria) necessaria = largura;
      }
    }
    // Margem interna, borda e folga para arredondamentos de layout.
    return necessaria + _IndicadorCard.padding * 2 + 4;
  }
}

/// Quantos indicadores cabem por linha sem quebrar palavras.
///
/// Prefere todos na mesma linha. Quando não cabem, evita deixar um card
/// sozinho: quatro viram duas linhas de dois e três viram uma coluna.
@visibleForTesting
int colunasIndicadores({
  required double larguraDisponivel,
  required double larguraMinimaCard,
  required int quantidade,
  double espaco = 8,
}) {
  if (quantidade <= 1) return 1;
  bool cabe(int colunas) =>
      (larguraDisponivel - (colunas - 1) * espaco) / colunas >=
      larguraMinimaCard;
  for (var colunas = quantidade; colunas > 1; colunas--) {
    if (quantidade == 4 && colunas == 3) continue;
    if (quantidade == 3 && colunas == 2) continue;
    if (cabe(colunas)) return colunas;
  }
  return 1;
}

class _EstilosIndicador {
  const _EstilosIndicador({
    required this.titulo,
    required this.valor,
    required this.detalhe,
  });

  final TextStyle? titulo;
  final TextStyle? valor;
  final TextStyle? detalhe;
}

class _IndicadorCard extends StatelessWidget {
  const _IndicadorCard({required this.item, required this.nomeAoLado});

  final _IndicadorDef item;

  /// Número e nome na mesma linha; falso coloca o nome abaixo do número.
  final bool nomeAoLado;

  static const padding = 10.0;
  static const espacoNome = 6.0;
  static const seloPadding = 8.0;
  static const iconeSelo = 14.0;
  static const espacoIconeSelo = 4.0;

  static _EstilosIndicador estilos(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return _EstilosIndicador(
      titulo: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      valor: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: colors.onSurface,
        height: 1.1,
      ),
      detalhe: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final estilos = _IndicadorCard.estilos(context);
    final tom = _tomLegivel(context, item.tom);
    final valor = item.valor?.toString() ?? '—';
    final fundo = Color.alphaBlend(
      item.tom.withValues(alpha: 0.09),
      colors.surface,
    );
    // Zero fica mais discreto para destacar os números que pedem atenção;
    // o detalhe por escrito continua igual.
    final numero = Text(
      valor,
      style: item.valor == 0
          ? estilos.valor?.copyWith(color: colors.onSurfaceVariant)
          : estilos.valor,
    );
    final nome = Text(item.titulo, style: estilos.titulo);

    void abrir() => Navigator.of(context).pushReplacementNamed(item.route);

    return Semantics(
      button: true,
      // Sem valor ainda, não lê o travessão: só o nome e o "atualizando".
      label: item.valor == null
          ? '${item.titulo}. ${item.detalhe}'
          : context.l10n.vgIndicadorSemantica(item.titulo, valor, item.detalhe),
      onTap: abrir,
      excludeSemantics: true,
      child: Material(
        key: ValueKey('indicador-${item.id}'),
        color: fundo,
        borderRadius: BorderRadius.circular(16),
        elevation: 1.5,
        shadowColor: item.tom.withValues(alpha: 0.25),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: abrir,
          child: Container(
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.tom.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nomeAoLado)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      numero,
                      const SizedBox(width: espacoNome),
                      Expanded(child: nome),
                    ],
                  )
                else ...[
                  numero,
                  const SizedBox(height: 2),
                  nome,
                ],
                const SizedBox(height: 8),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: seloPadding,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: item.tom.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SigadIcon(item.icone, color: tom, size: iconeSelo),
                      const SizedBox(width: espacoIconeSelo),
                      Flexible(
                        child: Text(
                          item.detalhe,
                          textAlign: TextAlign.center,
                          style: estilos.detalhe?.copyWith(color: tom),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Flexible(child: Text(context.l10n.atualizandoVisao)),
        ],
      ),
    ),
  );
}

class _DashboardInlineError extends StatelessWidget {
  const _DashboardInlineError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          const SigadIcon(
            SigadIcons.sincronizacaoErro,
            color: SigadColors.risk,
          ),
          Text(context.l10n.erroIndicadores),
          TextButton.icon(
            onPressed: onRetry,
            icon: const SigadIcon(SigadIcons.atualizar),
            label: Text(context.l10n.tentarNovamente),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Acesso rápido
// ---------------------------------------------------------------------------

/// Atalhos compactos e personalizáveis para os itens mais importantes do
/// menu lateral: o usuário escolhe, pelo botão Personalizar, quais aparecem
/// na Visão geral.
class _CustomizableIndicators extends StatefulWidget {
  const _CustomizableIndicators({required this.role});

  final UserRole? role;

  @override
  State<_CustomizableIndicators> createState() =>
      _CustomizableIndicatorsState();
}

class _CustomizableIndicatorsState extends State<_CustomizableIndicators> {
  static const _prefsKey = 'sigad_dashboard_atalhos_visiveis';

  late Set<String> _visiveis;

  List<NavigationItem> get _todosAtalhos => kNavigationItems
      .where((item) => item.route != AppRoutes.dashboard)
      .where((item) => widget.role == null || item.isAvailableFor(widget.role!))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _visiveis = _todosAtalhos.map((item) => item.route).toSet();
    _carregarPreferencia();
  }

  Future<void> _carregarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    final salvos = prefs.getStringList(_prefsKey);
    if (salvos != null && mounted) {
      final disponiveis = _todosAtalhos.map((item) => item.route).toSet();
      setState(() => _visiveis = salvos.toSet().intersection(disponiveis));
    }
  }

  Future<void> _salvarPreferencia() {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList(_prefsKey, _visiveis.toList()),
    );
  }

  void _abrirSeletorDeAtalhos() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  context.l10n.acessoRapido,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.escolhaAtalhos,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                for (final item in _todosAtalhos)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _visiveis.contains(item.route),
                    title: Text(item.rotuloEm(context.l10n)),
                    secondary: SigadIcon(item.icon, color: SigadColors.brand),
                    onChanged: (selecionado) {
                      setModalState(() {
                        if (selecionado ?? false) {
                          _visiveis.add(item.route);
                        } else {
                          _visiveis.remove(item.route);
                        }
                      });
                      setState(() {});
                      _salvarPreferencia();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final atalhosVisiveis = _todosAtalhos
        .where((item) => _visiveis.contains(item.route))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SigadIcon(
                  SigadIcons.raio,
                  color: _tomLegivel(context, SigadColors.accent),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    context.l10n.acessoRapido,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            Tooltip(
              message: context.l10n.personalizarAtalhos,
              child: TextButton.icon(
                onPressed: _abrirSeletorDeAtalhos,
                icon: const SigadIcon(SigadIcons.configuracoes, size: 18),
                label: Text(context.l10n.vgPersonalizar),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (atalhosVisiveis.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: [
                SigadIcon(
                  SigadIcons.painelPersonalizar,
                  size: 26,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.nenhumAtalho,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final colunas = colunasAtalhos(
                larguraDisponivel: constraints.maxWidth,
                larguraMinimaCard: _AtalhoCard.larguraMinima(
                  context,
                  atalhosVisiveis.map((item) => item.rotuloEm(context.l10n)),
                ),
              );
              final largura =
                  ((constraints.maxWidth - ((colunas - 1) * 10)) / colunas)
                      .clamp(0.0, double.infinity);
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final item in atalhosVisiveis)
                    SizedBox(
                      width: largura,
                      child: _AtalhoCard(item: item),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Colunas do Acesso rápido: o máximo que cabe sem quebrar palavras.
@visibleForTesting
int colunasAtalhos({
  required double larguraDisponivel,
  required double larguraMinimaCard,
  double espaco = 10,
}) {
  final maximo = larguraDisponivel >= 640 ? 5 : 3;
  for (var colunas = maximo; colunas > 1; colunas--) {
    final largura = (larguraDisponivel - (colunas - 1) * espaco) / colunas;
    if (largura >= larguraMinimaCard) return colunas;
  }
  return 1;
}

class _AtalhoCard extends StatelessWidget {
  const _AtalhoCard({required this.item});

  final NavigationItem item;

  static const _paddingHorizontal = 8.0;

  static TextStyle? estiloRotulo(BuildContext context) => Theme.of(
    context,
  ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700);

  /// Largura em que a maior palavra dos rótulos cabe sem ser partida.
  static double larguraMinima(BuildContext context, Iterable<String> rotulos) {
    final estilo = estiloRotulo(context);
    var maior = 0.0;
    for (final rotulo in rotulos) {
      for (final palavra in rotulo.split(RegExp(r'\s+'))) {
        final painter = TextPainter(
          text: TextSpan(text: palavra, style: estilo),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        if (painter.width > maior) maior = painter.width;
        painter.dispose();
      }
    }
    // Margem interna, borda e folga para arredondamentos.
    return maior + _paddingHorizontal * 2 + 4;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: _paddingHorizontal,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SigadIcon(item.icon, color: SigadColors.brand, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    item.rotuloEm(context.l10n),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: estiloRotulo(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

MuralController? _maybeMural(BuildContext context) {
  try {
    return Provider.of<MuralController>(context);
  } on ProviderNotFoundException {
    return null;
  }
}
