import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/config/institutional_context.dart';
import '../../../../core/services/notificacoes_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/greeting_title.dart';

/// Aviso do mural exibido no topo da Visão geral.
class AvisoNoTopo {
  const AvisoNoTopo({
    required this.icone,
    required this.titulo,
    required this.conteudo,
  });

  final IconData icone;
  final String titulo;
  final String conteudo;
}

/// Topo compacto da Visão geral: identificação do departamento, saudação e
/// card rotativo com os avisos do mural (ou a frase do período, sem avisos).
class OverviewHeader extends StatefulWidget {
  const OverviewHeader({
    super.key,
    required this.agora,
    required this.frase,
    required this.onNotificacoes,
    required this.onPerfil,
    this.avisos = const [],
    this.bottomInset = 0,
  });

  final DateTime agora;
  final String? frase;
  final VoidCallback onNotificacoes;
  final VoidCallback onPerfil;

  /// Avisos vigentes do mural para o perfil; vazio oculta a faixa.
  final List<AvisoNoTopo> avisos;

  /// Espaço extra no rodapé, coberto pelo cartão do conteúdo.
  final double bottomInset;

  @override
  State<OverviewHeader> createState() => _OverviewHeaderState();
}

class _OverviewHeaderState extends State<OverviewHeader> {
  Future<List<NotificacaoModel>>? _notificacoes;
  Object? _chaveNotificacoes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final usuario = context.watch<UserContextProvider>();
    final chave = (usuario.userRole, usuario.currentUser?.name);
    if (chave != _chaveNotificacoes) {
      _chaveNotificacoes = chave;
      _notificacoes = NotificacoesService.carregar(
        usuario.userRole,
        userName: usuario.currentUser?.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final escuro = theme.brightness == Brightness.dark;
    final topo = MediaQuery.paddingOf(context).top;
    final textTheme = theme.textTheme;
    final usuario = context.watch<UserContextProvider>().currentUser;
    final frase = widget.frase ?? context.l10n.fraseSemCadastro;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: escuro ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        key: const Key('overview-header'),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF138C76), SigadColors.brandDeep],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 12 + widget.bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPaint(
                painter: _FaixaInstitucionalPainter(
                  cor: theme.colorScheme.surface,
                  destaque: SigadColors.accent,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, topo + 4, 10, 16),
                  child: Row(
                    children: [
                      Expanded(child: _Instituicao(escuro: escuro)),
                      const SizedBox(width: 4),
                      FutureBuilder<List<NotificacaoModel>>(
                        future: _notificacoes,
                        builder: (context, snapshot) {
                          final total = snapshot.data?.length ?? 0;
                          return _BotaoCircular(
                            tooltip: context.l10n.notificacoes,
                            semantica: context.l10n.vgNotificacoesNovas(total),
                            onPressed: widget.onNotificacoes,
                            child: Badge(
                              isLabelVisible: total > 0,
                              label: Text(total > 99 ? '99+' : '$total'),
                              backgroundColor: Colors.white,
                              textColor: SigadColors.brandDeep,
                              child: const SigadIcon(
                                SigadIcons.notificacao,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      _BotaoCircular(
                        tooltip: context.l10n.perfil,
                        onPressed: widget.onPerfil,
                        child: _Inicial(nome: usuario?.name ?? ''),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: GreetingTitle(
                  text: greetingText(context, now: widget.agora),
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // Aviso tem prioridade; a frase do período só aparece quando
                // o mural está vazio, como uma linha simples.
                child: widget.avisos.isEmpty
                    ? _ConteudoFrase(
                        key: const ValueKey('slide-frase'),
                        frase: frase,
                        agora: widget.agora,
                      )
                    : _CarrosselAvisos(avisos: widget.avisos),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Instituicao extends StatelessWidget {
  const _Instituicao({required this.escuro});

  final bool escuro;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tinta = escuro ? Colors.white : SigadColors.ink;
    final suave = escuro ? Colors.white70 : SigadColors.muted;
    return Row(
      children: [
        _BotaoMenu(),
        const SizedBox(width: 4),
        Flexible(
          child: Semantics(
            container: true,
            header: true,
            label:
                '${InstitutionalContext.departmentAcronym}, '
                '${context.l10n.departamentoCampus}. '
                '${InstitutionalContext.institution}. '
                '${InstitutionalContext.campus}',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${InstitutionalContext.departmentAcronym} · '
                  '${InstitutionalContext.institutionAcronym}',
                  style: textTheme.titleSmall?.copyWith(
                    color: escuro ? Colors.white : SigadColors.brandDeep,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    height: 1.1,
                  ),
                ),
                Text(
                  context.l10n.departamentoCampus,
                  style: textTheme.labelMedium?.copyWith(
                    color: tinta,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                Text(
                  InstitutionalContext.campus,
                  style: textTheme.labelSmall?.copyWith(
                    color: suave,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ícone do aplicativo; quando a tela tem menu lateral, também o abre.
class _BotaoMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final icone = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/images/app_icon.png',
        width: 36,
        height: 36,
        errorBuilder: (_, _, _) => const SizedBox(width: 36, height: 36),
      ),
    );
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold == null || !scaffold.hasDrawer) {
      return ExcludeSemantics(child: icone);
    }
    final rotulo = MaterialLocalizations.of(context).openAppDrawerTooltip;
    return Tooltip(
      message: rotulo,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: rotulo,
        onTap: scaffold.openDrawer,
        excludeSemantics: true,
        child: InkWell(
          key: const Key('overview-menu'),
          borderRadius: BorderRadius.circular(12),
          onTap: scaffold.openDrawer,
          child: SizedBox(width: 48, height: 48, child: Center(child: icone)),
        ),
      ),
    );
  }
}

/// Inicial do usuário no botão de perfil.
class _Inicial extends StatelessWidget {
  const _Inicial({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) {
    final limpo = nome.trim();
    if (limpo.isEmpty) {
      return const SigadIcon(SigadIcons.pessoa, color: Colors.white, size: 22);
    }
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: Text(
        limpo[0].toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Card rotativo com os avisos do mural. A moldura fica parada e só o
/// conteúdo desliza. Troca sozinho, aceita deslizar e, no leitor de tela,
/// avança com os gestos de ajuste.
class _CarrosselAvisos extends StatefulWidget {
  const _CarrosselAvisos({required this.avisos});

  final List<AvisoNoTopo> avisos;

  @override
  State<_CarrosselAvisos> createState() => _CarrosselAvisosState();
}

class _CarrosselAvisosState extends State<_CarrosselAvisos> {
  static const _intervalo = Duration(seconds: 7);

  Timer? _timer;
  int _pagina = 0;

  int get _total => widget.avisos.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reiniciarRotacao();
  }

  @override
  void didUpdateWidget(_CarrosselAvisos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avisos.length != widget.avisos.length) {
      if (_pagina >= _total) _pagina = 0;
      _reiniciarRotacao();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reiniciarRotacao() {
    _timer?.cancel();
    // Não gira sozinho com animações reduzidas, com leitor de tela (o foco
    // saltaria a cada troca) nem com a tela coberta por outra rota.
    if (_total < 2 ||
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }
    _timer = Timer.periodic(_intervalo, (_) => _irPara(_pagina + 1));
  }

  void _irPara(int pagina) {
    if (!mounted || _total == 0) return;
    setState(() => _pagina = pagina % _total);
  }

  void _selecionar(int pagina) {
    _irPara(pagina);
    _reiniciarRotacao();
  }

  @override
  Widget build(BuildContext context) {
    final semAnimacao = MediaQuery.disableAnimationsOf(context);
    final duracao = semAnimacao
        ? Duration.zero
        : const Duration(milliseconds: 350);

    Widget slide(int indice) {
      final visivel = indice == _pagina;
      // Slides fora de vista esperam à direita (próximos) ou à esquerda.
      final deslocamento = visivel
          ? Offset.zero
          : Offset(indice < _pagina ? -0.25 : 0.25, 0);
      return IgnorePointer(
        ignoring: !visivel,
        child: ExcludeSemantics(
          excluding: !visivel,
          child: AnimatedSlide(
            offset: deslocamento,
            duration: duracao,
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: visivel ? 1 : 0,
              duration: duracao,
              child: _ConteudoAviso(
                key: visivel ? const Key('dashboard-avisos') : null,
                avisos: widget.avisos,
                indice: indice,
                onProximo: () => _selecionar(_pagina + 1),
                onAnterior: () => _selecionar(_pagina - 1 + _total),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: _total < 2
          ? null
          : (details) {
              final velocidade = details.primaryVelocity ?? 0;
              if (velocidade < -150) _selecionar(_pagina + 1);
              if (velocidade > 150) _selecionar(_pagina - 1 + _total);
            },
      // A moldura não muda: tem a altura do maior slide e só o conteúdo
      // desliza por dentro.
      child: Container(
        key: const Key('overview-carrossel'),
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SigadColors.accent.withValues(alpha: 0.75)),
        ),
        child: ClipRect(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [for (var i = 0; i < _total; i++) slide(i)],
          ),
        ),
      ),
    );
  }
}

class _ConteudoFrase extends StatelessWidget {
  const _ConteudoFrase({super.key, required this.frase, required this.agora});

  final String frase;
  final DateTime agora;

  @override
  Widget build(BuildContext context) {
    final hora = agora.hour;
    final icone = hora >= 5 && hora < 12
        ? SigadIcons.sol
        : hora >= 12 && hora < 18
        ? SigadIcons.entardecer
        : SigadIcons.lua;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SigadIcon(icone, color: const Color(0xFFFFD2A8), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              frase,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConteudoAviso extends StatelessWidget {
  const _ConteudoAviso({
    super.key,
    required this.avisos,
    required this.indice,
    required this.onProximo,
    required this.onAnterior,
  });

  final List<AvisoNoTopo> avisos;
  final int indice;
  final VoidCallback onProximo;
  final VoidCallback onAnterior;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final aviso = avisos[indice];
    final total = avisos.length;
    final varios = total > 1;
    String posicao(int i) => '${i + 1}/$total';
    void abrir() => _mostrarAvisos(context, avisos);

    // O slide inteiro abre a lista completa. No leitor de tela, os gestos
    // de ajuste trocam de aviso, já que ele não gira sozinho nesse modo.
    return Semantics(
      container: true,
      button: true,
      label:
          '${l10n.quantidadeAvisos(total)}. ${aviso.titulo}. '
          '${aviso.conteudo}. ${l10n.verTodosAvisos}',
      value: varios ? posicao(indice) : null,
      increasedValue: varios ? posicao((indice + 1) % total) : null,
      decreasedValue: varios ? posicao((indice - 1 + total) % total) : null,
      onIncrease: varios ? onProximo : null,
      onDecrease: varios ? onAnterior : null,
      onTap: abrir,
      excludeSemantics: true,
      child: Material(
        // O toque precisa ser desenhado acima do degradê do topo.
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: abrir,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                SigadIcon(aviso.icone, color: SigadColors.accent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              aviso.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (varios) ...[
                            const SizedBox(width: 8),
                            _Pontos(total: total, atual: indice),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        aviso.conteudo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SigadIcon(
                  SigadIcons.chevronDireita,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador visual da posição no carrossel; a troca é por deslize, pela
/// rotação automática ou pela lista completa.
class _Pontos extends StatelessWidget {
  const _Pontos({required this.total, required this.atual});

  final int total;
  final int atual;

  @override
  Widget build(BuildContext context) {
    // Com muitos avisos os pontos tomariam a largura do título.
    if (total > 5) {
      return ExcludeSemantics(
        child: Text(
          '${atual + 1}/$total',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: i == atual ? 14 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: i == atual ? 1 : 0.45),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}

void _mostrarAvisos(BuildContext context, List<AvisoNoTopo> avisos) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Text(context.l10n.avisos),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final aviso in avisos)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SigadIcon(aviso.icone, color: SigadColors.brand),
              title: Text(aviso.titulo),
              subtitle: Text(aviso.conteudo),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.fechar),
        ),
      ],
    ),
  );
}

class _BotaoCircular extends StatelessWidget {
  const _BotaoCircular({
    required this.tooltip,
    required this.onPressed,
    required this.child,
    this.semantica,
  });

  final String tooltip;

  /// Rótulo lido pelo leitor de tela; usa [tooltip] quando nulo.
  final String? semantica;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: semantica ?? tooltip,
        onTap: onPressed,
        excludeSemantics: true,
        child: Material(
          color: SigadColors.brand,
          shape: const CircleBorder(
            side: BorderSide(color: Colors.white, width: 2),
          ),
          elevation: 2,
          shadowColor: const Color(0x33000000),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(width: 48, height: 48, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}

/// Faixa clara do topo com borda ondulada e traço laranja, no lugar da
/// fotografia do campus.
class _FaixaInstitucionalPainter extends CustomPainter {
  const _FaixaInstitucionalPainter({required this.cor, required this.destaque});

  final Color cor;
  final Color destaque;

  Path _borda(Size size, double deslocamento) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, h - 4 + deslocamento)
      ..cubicTo(
        w * 0.30,
        h - 1 + deslocamento,
        w * 0.48,
        h - 18 + deslocamento,
        w * 0.70,
        h - 18 + deslocamento,
      )
      ..cubicTo(
        w * 0.86,
        h - 18 + deslocamento,
        w * 0.94,
        h - 13 + deslocamento,
        w,
        h - 11 + deslocamento,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final preenchimento = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - 11)
      ..cubicTo(w * 0.94, h - 13, w * 0.86, h - 18, w * 0.70, h - 18)
      ..cubicTo(w * 0.48, h - 18, w * 0.30, h - 1, 0, h - 4)
      ..close();
    canvas.drawPath(preenchimento, Paint()..color = cor);

    canvas.drawPath(
      _borda(size, 4),
      Paint()
        ..color = destaque
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FaixaInstitucionalPainter oldDelegate) =>
      oldDelegate.cor != cor || oldDelegate.destaque != destaque;
}
