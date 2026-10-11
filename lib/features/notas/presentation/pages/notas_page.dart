import 'package:flutter/material.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../../../core/services/local_storage_service.dart';

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
  bool _isLoading = true;
  bool _dialogOpen = false;
  String _busca = '';
  String _categoriaFiltro = 'Todas';
  bool _maisRecentesPrimeiro = true;

  @override
  void initState() {
    super.initState();
    _carregarNotas();
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
    try {
      final data = await LocalStorageService.loadList(_storageKey);
      final notas = data.map(Nota.fromMap).whereType<Nota>().toList()
        ..sort((a, b) => b.data.compareTo(a.data));
      if (!mounted) return;
      setState(() {
        _notas
          ..clear()
          ..addAll(notas);
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarNotas() => LocalStorageService.saveList(
    _storageKey,
    _notas.map((nota) => nota.toMap()).toList(growable: false),
  );

  Future<void> _criarOuEditarNota({Nota? nota}) async {
    setState(() => _dialogOpen = true);
    var textoEditado = nota?.texto ?? '';
    var categoriaEditada = nota?.categoria ?? 'Geral';
    final resultado = await showDialog<_NotaFormResult>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(nota == null ? 'Nova anotação' : 'Editar anotação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: TextEditingController(text: textoEditado),
                onChanged: (value) => textoEditado = value,
                minLines: 5,
                maxLines: 10,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Registre uma ideia, encaminhamento ou lembrete...',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: categoriaEditada,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: kCategoriasAnotacao
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => categoriaEditada = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final texto = textoEditado.trim();
                if (texto.isNotEmpty) {
                  Navigator.pop(
                    context,
                    _NotaFormResult(texto: texto, categoria: categoriaEditada),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (mounted) setState(() => _dialogOpen = false);
    if (!mounted || resultado == null) return;
    final agora = DateTime.now();
    setState(() {
      if (nota == null) {
        _notas.insert(
          0,
          Nota(
            id: 'nota_${agora.microsecondsSinceEpoch}',
            texto: resultado.texto,
            data: agora,
            categoria: resultado.categoria,
          ),
        );
      } else {
        final index = _notas.indexWhere((item) => item.id == nota.id);
        if (index >= 0) {
          _notas[index] = nota.copyWith(
            texto: resultado.texto,
            data: agora,
            categoria: resultado.categoria,
          );
        }
      }
    });
    await _salvarNotas();
  }

  Future<void> _excluirNota(Nota nota) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir anotação'),
        content: const Text('Tem certeza que deseja excluir esta anotação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    setState(() => _notas.removeWhere((item) => item.id == nota.id));
    await _salvarNotas();
  }

  Future<void> _alternarFixada(Nota nota) async {
    setState(() {
      final index = _notas.indexWhere((item) => item.id == nota.id);
      if (index >= 0) {
        _notas[index] = nota.copyWith(fixada: !nota.fixada);
      }
    });
    await _salvarNotas();
  }

  void _gerenciarFixadas() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gerenciar fixadas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (_notas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Nenhuma anotação criada ainda.'),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
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
                            subtitle: Text(nota.categoria),
                            value: nota.fixada,
                            onChanged: (_) async {
                              await _alternarFixada(nota);
                              setModalState(() {});
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final notas = _notasFiltradas;
    final fixadas = _notasFixadas;
    final chips = ['Todas', 'Reuniões', 'Laboratórios', 'Planejamento', 'Mais'];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nova anotação',
        onPressed: () => _criarOuEditarNota(),
        icon: const SigadIcon(SigadIcons.adicionar),
        label: const Text('Nova anotação'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (!_dialogOpen)
            TextField(
              onChanged: (value) => setState(() => _busca = value),
              decoration: InputDecoration(
                hintText: 'Buscar anotações, reuniões, temas...',
                prefixIcon: const SigadIcon(SigadIcons.buscar),
                suffixIcon: const SigadIcon(SigadIcons.ajustes),
                filled: true,
                fillColor: colors.surface,
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
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
                  label: Text(chip),
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
            Row(
              children: [
                const SigadIcon(SigadIcons.fixar, color: SigadColors.brand),
                const SizedBox(width: 8),
                Text(
                  'Fixadas',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _gerenciarFixadas,
                  child: const Text('Gerenciar fixadas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...fixadas.map(
              (nota) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NoteCard(
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
          Row(
            children: [
              const SigadIcon(SigadIcons.editarNota, color: SigadColors.brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Todas as anotações',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              PopupMenuButton<bool>(
                initialValue: _maisRecentesPrimeiro,
                onSelected: (value) =>
                    setState(() => _maisRecentesPrimeiro = value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: true, child: Text('Mais recentes')),
                  PopupMenuItem(value: false, child: Text('Mais antigas')),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ordenar por: ${_maisRecentesPrimeiro ? 'Mais recentes' : 'Mais antigas'}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SigadIcon(SigadIcons.chevronBaixo, size: 18),
                  ],
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
            _EmptyNotes(onCreate: () => _criarOuEditarNota())
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
                  const Text('Nenhuma anotação encontrada.'),
                ],
              ),
            )
          else
            ...notas.map(
              (nota) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NoteCard(
                  nota: nota,
                  onEdit: () => _criarOuEditarNota(nota: nota),
                  onDelete: () => _excluirNota(nota),
                  onTogglePin: () => _alternarFixada(nota),
                ),
              ),
            ),
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
                  title: Text(categoria),
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

class _NotaFormResult {
  const _NotaFormResult({required this.texto, required this.categoria});

  final String texto;
  final String categoria;
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onCreate});

  final VoidCallback onCreate;

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
            'Nenhuma anotação. Toque em "+" para criar.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Use este espaço para registrar encaminhamentos, ideias e lembretes rápidos.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onCreate,
            icon: const SigadIcon(SigadIcons.adicionar),
            label: const Text('Criar primeira anotação'),
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
  });

  final Nota nota;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final bool destacada;

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
                        nota.categoria.toUpperCase(),
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
                  tooltip: nota.fixada ? 'Desafixar' : 'Fixar anotação',
                  onPressed: onTogglePin,
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
            Row(
              children: [
                SigadIcon(
                  SigadIcons.relogio,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(nota.data),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Editar anotação',
                  onPressed: onEdit,
                  icon: const SigadIcon(SigadIcons.editar),
                ),
                IconButton(
                  tooltip: 'Excluir anotação',
                  onPressed: onDelete,
                  icon: SigadIcon(SigadIcons.excluir, color: colors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m às $h:$min';
  }
}
