import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/sigad_colors.dart';
import '../../app/theme/sigad_icon.dart';
import '../../app/theme/sigad_icons.dart';
import '../../l10n/l10n.dart';

/// Item exibido em um slide de lista do [WelcomeHero].
class WelcomeHeroItem {
  const WelcomeHeroItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color = SigadColors.mint,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

/// Topo do painel: boas-vindas e, em rotação, avisos e o resumo do
/// departamento. Sem avisos nem resumo, mostra apenas as boas-vindas.
class WelcomeHero extends StatefulWidget {
  const WelcomeHero({
    super.key,
    this.avisos = const [],
    this.frase,
    this.resumo = const [],
    this.paginaInicial = 0,
    this.rotacaoAutomatica = true,
  });

  /// Avisos do mural. Sem avisos, o slide de avisos não aparece.
  final List<WelcomeHeroItem> avisos;

  /// Frase motivacional do período. Nula usa uma frase padrão.
  final String? frase;

  /// Resumo do departamento exibido como um slide extra.
  final List<WelcomeHeroItem> resumo;

  /// Slide exibido primeiro (0 = boas-vindas). Usado na pré-visualização.
  final int paginaInicial;

  /// Desligue para manter o slide parado (pré-visualização).
  final bool rotacaoAutomatica;

  @override
  State<WelcomeHero> createState() => _WelcomeHeroState();
}

class _Slide {
  const _Slide(this.rotulo, this.card);

  final String rotulo;
  final Widget card;
}

class _WelcomeHeroState extends State<WelcomeHero> {
  static const _intervalo = Duration(seconds: 7);

  Timer? _timer;
  int _pagina = 0;
  int _total = 1;

  @override
  void initState() {
    super.initState();
    _pagina = widget.paginaInicial;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reiniciarRotacao();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reiniciarRotacao() {
    _timer?.cancel();
    final animacoesDesativadas = MediaQuery.disableAnimationsOf(context);
    if (_total < 2 || animacoesDesativadas || !widget.rotacaoAutomatica) {
      return;
    }
    _timer = Timer.periodic(_intervalo, (_) => _irPara(_pagina + 1));
  }

  void _irPara(int pagina) {
    if (!mounted) return;
    setState(() => _pagina = pagina % _total);
  }

  void _selecionar(int pagina) {
    _irPara(pagina);
    _reiniciarRotacao();
  }

  @override
  Widget build(BuildContext context) {
    final avisos = widget.avisos;

    final slides = [
      _Slide(
        context.l10n.boasVindas,
        _WelcomeCard(
          key: const ValueKey('hero-boas-vindas'),
          agora: DateTime.now(),
          frase: widget.frase,
        ),
      ),
      if (avisos.isNotEmpty)
        _Slide(
          context.l10n.avisos,
          _ListaHeroCard(
            key: const ValueKey('hero-avisos'),
            icone: SigadIcons.aviso,
            titulo: context.l10n.quantidadeAvisos(avisos.length),
            tituloDialogo: context.l10n.avisos,
            botao: context.l10n.verTodosAvisos,
            itens: avisos,
          ),
        ),
      if (widget.resumo.isNotEmpty)
        _Slide(
          context.l10n.resumoDepartamento,
          _ListaHeroCard(
            key: const ValueKey('hero-resumo'),
            icone: SigadIcons.predio,
            titulo: context.l10n.resumoDepartamento,
            tituloDialogo: context.l10n.resumoDepartamento,
            botao: context.l10n.verTudo,
            maxVisiveis: 3,
            itens: widget.resumo,
            tipografiaCompacta: true,
          ),
        ),
    ];

    if (slides.length != _total) {
      _total = slides.length;
      if (_pagina >= _total) _pagina = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reiniciarRotacao();
      });
    }
    final temRotacao = slides.length > 1;

    return Container(
      key: const Key('welcome-hero'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6F2),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A004D40),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: temRotacao
            ? (details) {
                final velocidade = details.primaryVelocity ?? 0;
                if (velocidade < -150) _selecionar(_pagina + 1);
                if (velocidade > 150) _selecionar(_pagina - 1 + _total);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previous, ?current],
                  ),
                  child: slides[_pagina].card,
                ),
              ),
              if (temRotacao) ...[
                const SizedBox(height: 10),
                Center(
                  child: _HeroDots(
                    rotulos: [for (final slide in slides) slide.rotulo],
                    atual: _pagina,
                    onSelect: _selecionar,
                  ),
                ),
              ] else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({super.key, required this.agora, required this.frase});

  final DateTime agora;
  final String? frase;

  @override
  Widget build(BuildContext context) {
    final hora = agora.hour;
    final icone = hora >= 5 && hora < 12
        ? SigadIcons.sol
        : hora >= 12 && hora < 18
        ? SigadIcons.entardecer
        : SigadIcons.lua;
    final frase = this.frase ?? context.l10n.fraseSemCadastro;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: frase,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF426F5A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SigadIcon(icone, color: const Color(0xFF426F5A), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frase,
                  style: textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF3D5146),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.departamentoCampus,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF3D5146),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaHeroCard extends StatelessWidget {
  const _ListaHeroCard({
    super.key,
    required this.icone,
    required this.titulo,
    required this.tituloDialogo,
    required this.botao,
    required this.itens,
    this.maxVisiveis = 2,
    this.tipografiaCompacta = false,
  });

  final IconData icone;
  final String titulo;
  final String tituloDialogo;
  final String botao;
  final List<WelcomeHeroItem> itens;
  final int maxVisiveis;
  final bool tipografiaCompacta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visiveis = itens.take(maxVisiveis).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SigadIcon(icone, color: const Color(0xFF426F5A)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                style: textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF243B30),
                  fontSize: tipografiaCompacta ? 16 : null,
                  fontWeight: tipografiaCompacta
                      ? FontWeight.w700
                      : FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in visiveis)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF426F5A).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SigadIcon(
                    item.icon,
                    color: _tomEscuro(item.color),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF243B30),
                          fontSize: tipografiaCompacta ? 14 : null,
                          fontWeight: tipografiaCompacta
                              ? FontWeight.w600
                              : FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: tipografiaCompacta ? 13 : null,
                          color: const Color(0xFF506359),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _mostrarTodos(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF426F5A),
              minimumSize: const Size(48, 48),
            ),
            child: Text(botao, style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  void _mostrarTodos(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(tituloDialogo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in itens)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SigadIcon(item.icon, color: SigadColors.brand),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
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
}

class _HeroDots extends StatelessWidget {
  const _HeroDots({
    required this.rotulos,
    required this.atual,
    required this.onSelect,
  });

  final List<String> rotulos;
  final int atual;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rotulos.length; i++)
          Semantics(
            button: true,
            selected: i == atual,
            label: context.l10n.mostrarSlide(rotulos[i]),
            excludeSemantics: true,
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => onSelect(i),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: i == atual ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF426F5A,
                      ).withValues(alpha: i == atual ? 1 : 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Escurece o tom para manter contraste sobre o fundo verde claro do card.
Color _tomEscuro(Color tom) => Color.lerp(tom, const Color(0xFF243B30), 0.72)!;
