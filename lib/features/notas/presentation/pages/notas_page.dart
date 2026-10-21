import 'package:flutter/material.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../l10n/l10n.dart';
import '../notas_l10n.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

const List<String> kCategoriasAnotacao = [
  'Geral',
  'Reuniões',
  'Laboratórios',
  'Planejamento',
  'Carga horária',
  'Eventos',
];

IconData _iconeCategoria(String categoria) {
  switch (categoria) {
    case 'Reuniões':
      return SigadIcons.grupo;
    case 'Laboratórios':
      return SigadIcons.laboratorio;
    case 'Planejamento':
      return SigadIcons.calendario;
    case 'Carga horária':
      return SigadIcons.documento;
    case 'Eventos':
      return SigadIcons.aviso;
    default:
      return SigadIcons.nota;
  }
}

Color _corCategoria(String categoria) {
  switch (categoria) {
    case 'Reuniões':
      return SigadColors.info;
    case 'Laboratórios':
      return SigadColors.warning;
    case 'Planejamento':
      return SigadColors.brand;
    case 'Carga horária':
      return SigadColors.success;
    case 'Eventos':
      return SigadColors.violet;
    default:
      return SigadColors.muted;
  }
}

class Nota {
  const Nota({
    required this.id,
    required this.texto,
    required this.data,
    this.categoria = 'Geral',
    this.fixada = false,
    this.status,
  });

  final String id;
  final String texto;
  final DateTime data;
  final String categoria;
  final bool fixada;
  final String? status;

  Nota copyWith({
    String? texto,
    DateTime? data,
    String? categoria,
    bool? fixada,
  }) => Nota(
    id: id,
    texto: texto ?? this.texto,
    data: data ?? this.data,
    categoria: categoria ?? this.categoria,
    fixada: fixada ?? this.fixada,
    status: status,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'texto': texto,
    'data': data.toIso8601String(),
    'categoria': categoria,
    'fixada': fixada,
    'status': status,
  };

  static Nota? fromMap(Map<String, dynamic> map) {
    final texto = map['texto'] as String?;
    final data = DateTime.tryParse(map['data'] as String? ?? '');
    if (texto == null || texto.trim().isEmpty || data == null) return null;
    final categoria = map['categoria'] as String?;
    return Nota(
      id: (map['id'] as String?)?.trim().isNotEmpty == true
          ? map['id'] as String
          : 'nota_${data.microsecondsSinceEpoch}',
      texto: texto,
      data: data,
      categoria: kCategoriasAnotacao.contains(categoria) ? categoria! : 'Geral',
      fixada: map['fixada'] as bool? ?? false,
      status: map['status'] as String?,
    );
  }
}

class _NotasPageState extends State<NotasPage> {
  static const _storageKey = 'sigad_notas';
  final List<Nota> _notas = [];
  final _buscaController = TextEditingController();
  bool _isLoading = true;
  bool _dialogOpen = false;
  bool _isSaving = false;
  bool _loadFailed = false;

  bool get _canChange => !_isLoading && !_loadFailed && !_isSaving;
  String _busca = '';
  String _categoriaFiltro = 'Todas';
  bool _maisRecentesPrimeiro = true;

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Nota> get _notasOrdenadas {
    final copia = List<Nota>.of(_notas)
      ..sort(
        (a, b) => _maisRecentesPrimeiro
            ? b.data.compareTo(a.data)
            : a.data.compareTo(b.data),
      );
    return copia;
  }

  List<Nota> get _notasFiltradas {
    final query = _busca.trim().toLowerCase();
    return _notasOrdenadas
        .where((nota) {
          final matchesQuery =
              query.isEmpty || nota.texto.toLowerCase().contains(query);
          final matchesCategoria =
              _categoriaFiltro == 'Todas' || nota.categoria == _categoriaFiltro;
          return matchesQuery && matchesCategoria;
        })
        .toList(growable: false);
  }

  List<Nota> get _notasFixadas =>
      _notasOrdenadas.where((nota) => nota.fixada).toList(growable: false);

  Future<void> _carregarNotas() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final data = await LocalStorageService.loadList(
        _storageKey,
        strict: true,
      );
      final notas = data.map((map) {
        final nota = Nota.fromMap(map);
        if (nota == null) throw const FormatException('Invalid note');
        return nota;
      }).toList()..sort((a, b) => b.data.compareTo(a.data));
      if (!mounted) return;
      setState(() {
        _notas
          ..clear()
          ..addAll(notas);
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  /// Descarta, após confirmação, os registros que impedem a carga estrita,
  /// mantendo as anotações que ainda podem ser lidas.
  Future<void> _descartarInvalidas() async {
    if (_isLoading || !_loadFailed || _dialogOpen) return;
    _marcarDialogoAberto();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(context.l10n.notaDescartarInvalidas),
        content: Text(context.l10n.notaDescartarInvalidasMensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.notaDescartar),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _dialogOpen = false);
    if (confirmar != true) return;
    setState(() => _isLoading = true);
    final validas = <Nota>[];
    try {
      try {
        for (final map in await LocalStorageService.loadList(_storageKey)) {
          try {
            final nota = Nota.fromMap(map);
            if (nota != null) validas.add(nota);
          } on TypeError {
            // Registro com campo de tipo inesperado: descartado.
          }
        }
      } on FormatException {
        // JSON ilegível: não há registro recuperável.
      } on TypeError {
        // Conteúdo não é uma lista: não há registro recuperável.
      }
      // Qualquer outra falha (ex.: leitura indisponível) interrompe o
      // descarte sem gravar, para não apagar dados que ainda existem.
      await LocalStorageService.saveList(
        _storageKey,
        validas.map((nota) => nota.toMap()).toList(growable: false),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.erroSalvar)));
      return;
    }
    await _carregarNotas();
  }

  Future<bool> _salvarNotas(
    List<Nota> candidatas, {
    bool showFeedback = true,
  }) async {
    if (!_canChange) return false;
    setState(() => _isSaving = true);
    try {
      await LocalStorageService.saveList(
        _storageKey,
        candidatas.map((nota) => nota.toMap()).toList(growable: false),
      );
      if (!mounted) return false;
      setState(() {
        _notas
          ..clear()
          ..addAll(candidatas);
      });
      return true;
    } catch (_) {
      if (mounted && showFeedback && !_dialogOpen) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.erroSalvar)));
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _criarOuEditarNota({Nota? nota}) async {
    if (!_canChange || _dialogOpen) return;
    _marcarDialogoAberto();
    var textoEditado = nota?.texto ?? '';
    var categoria = nota?.categoria ?? 'Geral';
    var saving = false;
    var failed = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => PopScope(
          canPop: !saving,
          child: AlertDialog(
            scrollable: true,
            title: Text(
              nota == null ? context.l10n.notaNova : context.l10n.notaEditar,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: textoEditado,
                  onChanged: (value) => textoEditado = value,
                  enabled: !saving,
                  minLines: 3,
                  maxLines: 10,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.notaTexto,
                    hintText: context.l10n.notaDica,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: categoria,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.notaCategoria,
                  ),
                  items: kCategoriasAnotacao
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(context.l10n.categoriaNota(item)),
                        ),
                      )
                      .toList(),
                  onChanged: saving
                      ? null
                      : (value) {
                          if (value != null) update(() => categoria = value);
                        },
                ),
                if (failed)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(context.l10n.erroSalvar),
                    ),
                  ),
                if (saving) const LinearProgressIndicator(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: Text(context.l10n.cancelar),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final texto = textoEditado.trim();
                        if (texto.isEmpty) return;
                        update(() {
                          saving = true;
                          failed = false;
                        });
                        final agora = DateTime.now();
                        final candidatas = List<Nota>.of(_notas);
                        if (nota == null) {
                          candidatas.insert(
                            0,
                            Nota(
                              id: 'nota_${agora.microsecondsSinceEpoch}',
                              texto: texto,
                              data: agora,
                              categoria: categoria,
                            ),
                          );
                        } else {
                          final index = candidatas.indexWhere(
                            (item) => item.id == nota.id,
                          );
                          if (index >= 0) {
                            candidatas[index] = nota.copyWith(
                              texto: texto,
                              data: agora,
                              categoria: categoria,
                            );
                          }
                        }
                        final saved = await _salvarNotas(candidatas);
                        if (!context.mounted) return;
                        update(() {
                          saving = false;
                          failed = !saved;
                        });
                        if (saved) Navigator.pop(dialogContext);
                      },
                child: Text(context.l10n.salvar),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() => _dialogOpen = false);
  }

  Future<void> _excluirNota(Nota nota) async {
    if (!_canChange || _dialogOpen) return;
    _marcarDialogoAberto();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.notaExcluir),
        content: Text(context.l10n.notaExcluirMensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.excluir),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _dialogOpen = false);
    if (confirmar != true || !_canChange) return;
    await _salvarNotas(_notas.where((item) => item.id != nota.id).toList());
  }

  Future<bool> _alternarFixada(Nota nota, {bool showFeedback = true}) async {
    if (!_canChange || _dialogOpen) return false;
    return _salvarNotas(
      _notas
          .map(
            (item) =>
                item.id == nota.id ? item.copyWith(fixada: !item.fixada) : item,
          )
          .toList(),
      showFeedback: showFeedback,
    );
  }

  /// Tira o foco da busca antes de abrir um diálogo, para que o teclado não
  /// reabra quando o diálogo fechar.
  void _marcarDialogoAberto() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _dialogOpen = true);
  }

  void _gerenciarFixadas() {
    if (!_canChange) return;
    FocusManager.instance.primaryFocus?.unfocus();
    var failed = false;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.notaGerenciarFixadas,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (failed)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        context.l10n.erroSalvar,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (_notas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(context.l10n.notaNenhumaCriada),
                    )
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: _notas
                            .map(
                              (nota) => SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  nota.texto,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  context.l10n.categoriaNota(nota.categoria),
                                ),
                                value: nota.fixada,
                                onChanged: !_canChange
                                    ? null
                                    : (_) async {
                                        if (!_canChange) return;
                                        final operation = _alternarFixada(
                                          nota,
                                          showFeedback: false,
                                        );
                                        setModalState(() => failed = false);
                                        final saved = await operation;
                                        if (context.mounted) {
                                          setModalState(() => failed = !saved);
                                        }
                                      },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final notas = _notasFiltradas;
    final fixadas = _notasFixadas;
    final l10n = context.l10n;
    final chips = ['Todas', 'Reuniões', 'Laboratórios', 'Planejamento', 'Mais'];
    final canCreate = _canChange && !_dialogOpen;
    // Em altura reduzida (paisagem), o FAB compacto cobre menos conteúdo.
    final compactHeight = MediaQuery.sizeOf(context).height < 400;
    // Com fonte ampliada, o rótulo do FAB estendido não cabe em retrato.
    final compactFab =
        compactHeight || MediaQuery.textScalerOf(context).scale(14) / 14 > 1.2;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        tooltip: l10n.notaNova,
        onPressed: canCreate ? () => _criarOuEditarNota() : null,
        isExtended: !compactFab,
        backgroundColor: canCreate ? null : colors.surfaceContainerHighest,
        foregroundColor: canCreate
            ? null
            : colors.onSurface.withValues(alpha: 0.38),
        elevation: canCreate ? null : 0,
        icon: const SigadIcon(SigadIcons.adicionar),
        label: Text(l10n.notaNova),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          SizedBox(
            height: 4,
            child: _isSaving
                ? LinearProgressIndicator(semanticsLabel: l10n.notaSalvando)
                : null,
          ),
          if (_loadFailed)
            _LoadError(
              onRetry: _carregarNotas,
              onDiscard: _dialogOpen ? null : _descartarInvalidas,
            )
          else ...[
            TextField(
              controller: _buscaController,
              onChanged: (value) => setState(() => _busca = value),
              decoration: InputDecoration(
                hintText: l10n.notaBuscar,
                prefixIcon: const SigadIcon(SigadIcons.buscar),
                suffixIcon: const SigadIcon(SigadIcons.ajustes),
                filled: true,
                fillColor: colors.surface,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48 * MediaQuery.textScalerOf(context).scale(14) / 14,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = chips[index];
                  final selected = chip == 'Mais'
                      ? !chips.take(4).contains(_categoriaFiltro) &&
                            _categoriaFiltro != 'Todas'
                      : _categoriaFiltro == chip;
                  final tone = sigadToneForIndex(index);
                  return ChoiceChip(
                    label: Text(l10n.categoriaNota(chip)),
                    selected: selected,
                    selectedColor: tone,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) {
                      if (chip == 'Mais') {
                        _abrirMaisCategorias();
                      } else {
                        setState(() => _categoriaFiltro = chip);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (fixadas.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SigadIcon(
                        SigadIcons.fixar,
                        color: SigadColors.brand,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.notaFixadas,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    // Reserva a faixa do FAB compacto em telas baixas.
                    padding: EdgeInsets.only(right: compactFab ? 64 : 0),
                    child: TextButton(
                      onPressed: _canChange ? _gerenciarFixadas : null,
                      child: Text(context.l10n.notaGerenciarFixadas),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...fixadas.map(
                (nota) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NoteCard(
                    enabled: _canChange && !_dialogOpen,
                    nota: nota,
                    destacada: true,
                    onEdit: () => _criarOuEditarNota(nota: nota),
                    onDelete: () => _excluirNota(nota),
                    onTogglePin: () => _alternarFixada(nota),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SigadIcon(
                      SigadIcons.editarNota,
                      color: SigadColors.brand,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.notaTodasAnotacoes,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<bool>(
                  initialValue: _maisRecentesPrimeiro,
                  onSelected: (value) =>
                      setState(() => _maisRecentesPrimeiro = value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: true,
                      child: Text(l10n.notaMaisRecentes),
                    ),
                    PopupMenuItem(
                      value: false,
                      child: Text(l10n.notaMaisAntigas),
                    ),
                  ],
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.notaOrdenarPor(
                              _maisRecentesPrimeiro
                                  ? l10n.notaMaisRecentes
                                  : l10n.notaMaisAntigas,
                            ),
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SigadIcon(SigadIcons.chevronBaixo, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_notas.isEmpty)
              _EmptyNotes(
                onCreate: canCreate ? () => _criarOuEditarNota() : null,
              )
            else if (notas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 56),
                child: Column(
                  children: [
                    SigadIcon(
                      SigadIcons.buscarVazio,
                      size: 48,
                      color: colors.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.notaNenhumaEncontrada),
                  ],
                ),
              )
            else
              ...notas.map(
                (nota) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NoteCard(
                    enabled: _canChange && !_dialogOpen,
                    nota: nota,
                    onEdit: () => _criarOuEditarNota(nota: nota),
                    onDelete: () => _excluirNota(nota),
                    onTogglePin: () => _alternarFixada(nota),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _abrirMaisCategorias() {
    final outras = kCategoriasAnotacao
        .where(
          (item) =>
              !['Reuniões', 'Laboratórios', 'Planejamento'].contains(item),
        )
        .toList();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: outras
              .map(
                (categoria) => ListTile(
                  leading: SigadIcon(
                    _iconeCategoria(categoria),
                    color: _corCategoria(categoria),
                  ),
                  title: Text(context.l10n.categoriaNota(categoria)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _categoriaFiltro = categoria);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry, required this.onDiscard});

  final VoidCallback onRetry;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          SigadIcon(SigadIcons.aviso, size: 48, color: colors.error),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              context.l10n.notaErroCarregar,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: onRetry,
                child: Text(context.l10n.tentarNovamente),
              ),
              OutlinedButton(
                onPressed: onDiscard,
                child: Text(context.l10n.notaDescartarInvalidas),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: SigadColors.brandLight,
              shape: BoxShape.circle,
            ),
            child: const SigadIcon(
              SigadIcons.documentoAdicionar,
              size: 42,
              color: SigadColors.brand,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.notaVazio,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.notaVazioDica,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onCreate,
            icon: const SigadIcon(SigadIcons.adicionar),
            label: Text(context.l10n.notaCriarPrimeira),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.nota,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
    this.destacada = false,
    this.enabled = true,
  });

  final Nota nota;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final bool destacada;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cor = _corCategoria(nota.categoria);
    return Container(
      decoration: BoxDecoration(
        color: destacada ? SigadColors.brandLight : colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: destacada
              ? SigadColors.brand.withValues(alpha: 0.3)
              : colors.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SigadIcon(_iconeCategoria(nota.categoria), color: cor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n
                            .categoriaNota(nota.categoria)
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        nota.texto,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: nota.fixada
                      ? context.l10n.notaDesafixar
                      : context.l10n.notaFixar,
                  onPressed: enabled ? onTogglePin : null,
                  icon: SigadIcon(
                    nota.fixada
                        ? SigadIcons.marcadorPreenchido
                        : SigadIcons.marcador,
                    color: nota.fixada
                        ? SigadColors.brand
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                SigadIcon(
                  SigadIcons.relogio,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(context.l10n, nota.data),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.notaEditar,
                  onPressed: enabled ? onEdit : null,
                  icon: const SigadIcon(SigadIcons.editar),
                ),
                IconButton(
                  tooltip: context.l10n.notaExcluir,
                  onPressed: enabled ? onDelete : null,
                  icon: SigadIcon(SigadIcons.excluir, color: colors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return l10n.notaDataHora(d, m, '$h:$min');
  }
}
