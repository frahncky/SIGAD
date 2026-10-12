import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/sigad_colors.dart';
import '../../app/theme/sigad_icon.dart';
import '../../app/theme/sigad_icons.dart';
import '../../core/services/user_context_provider.dart';

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
    final userContext = _maybeUserContext(context);
    final avisos = widget.avisos;

    final slides = [
      _Slide(
        'Boas-vindas',
        _WelcomeCard(
          key: const ValueKey('hero-boas-vindas'),
          nome: userContext?.currentUser?.name,
          agora: DateTime.now(),
          frase: widget.frase,
        ),
      ),
      if (avisos.isNotEmpty)
        _Slide(
          'Avisos',
          _ListaHeroCard(
            key: const ValueKey('hero-avisos'),
            icone: SigadIcons.aviso,
            titulo: avisos.length == 1 ? '1 aviso' : '${avisos.length} avisos',
            tituloDialogo: 'Avisos',
            botao: 'Ver todos os avisos',
            itens: avisos,
          ),
        ),
      if (widget.resumo.isNotEmpty)
        _Slide(
          'Resumo do departamento',
          _ListaHeroCard(
            key: const ValueKey('hero-resumo'),
            icone: SigadIcons.predio,
            titulo: 'Resumo do departamento',
            tituloDialogo: 'Resumo do departamento',
            botao: 'Ver tudo',
            maxVisiveis: 3,
            itens: widget.resumo,
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SigadColors.brand, SigadColors.brandDeep],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33004D40),
            blurRadius: 24,
            offset: Offset(0, 10),
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

UserContextProvider? _maybeUserContext(BuildContext context) {
  try {
    return Provider.of<UserContextProvider>(context);
  } on ProviderNotFoundException {
    return null;
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    super.key,
    required this.nome,
    required this.agora,
    required this.frase,
  });

  final String? nome;
  final DateTime agora;
  final String? frase;

  static const _fraseSemCadastro =
      'Cada pequena entrega de hoje constrói o departamento de amanhã.';

  @override
  Widget build(BuildContext context) {
    final hora = agora.hour;
    final (saudacao, icone) = hora >= 5 && hora < 12
        ? ('Bom dia', SigadIcons.sol)
        : hora >= 12 && hora < 18
        ? ('Boa tarde', SigadIcons.entardecer)
        : ('Boa noite', SigadIcons.lua);
    final primeiroNome = nome?.trim().split(RegExp(r'\s+')).first ?? '';
    final titulo = primeiroNome.isEmpty
        ? '$saudacao!'
        : '$saudacao, $primeiroNome!';
    final frase = this.frase ?? _fraseSemCadastro;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: '$titulo $frase',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SigadColors.accent.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SigadIcon(icone, color: SigadColors.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  frase,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Departamento de Eletroeletrônica',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.66),
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
  });

  final IconData icone;
  final String titulo;
  final String tituloDialogo;
  final String botao;
  final List<WelcomeHeroItem> itens;
  final int maxVisiveis;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visiveis = itens.take(maxVisiveis).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SigadIcon(icone, color: SigadColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
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
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SigadIcon(
                    item.icon,
                    color: _tomClaro(item.color),
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
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.76),
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
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
            ),
            child: Text(botao, style: const TextStyle(fontSize: 16)),
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
            child: const Text('Fechar'),
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
            label: 'Mostrar ${rotulos[i]}',
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
                      color: Colors.white.withValues(
                        alpha: i == atual ? 0.95 : 0.4,
                      ),
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

/// Clareia o tom para manter contraste sobre o fundo verde escuro do card.
Color _tomClaro(Color tom) => Color.lerp(tom, Colors.white, 0.72)!;
