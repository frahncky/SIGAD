import 'package:flutter/material.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/local_storage_service.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class Nota {
  const Nota({required this.id, required this.texto, required this.data});

  final String id;
  final String texto;
  final DateTime data;

  Map<String, dynamic> toMap() => {
        'id': id,
        'texto': texto,
        'data': data.toIso8601String(),
      };

  static Nota? fromMap(Map<String, dynamic> map) {
    final texto = map['texto'] as String?;
    final data = DateTime.tryParse(map['data'] as String? ?? '');
    if (texto == null || texto.trim().isEmpty || data == null) return null;
    return Nota(
      id: (map['id'] as String?)?.trim().isNotEmpty == true
          ? map['id'] as String
          : 'nota_${data.microsecondsSinceEpoch}',
      texto: texto,
      data: data,
    );
  }
}

class _NotasPageState extends State<NotasPage> {
  static const _storageKey = 'sigad_notas';
  final List<Nota> _notas = [];
  bool _isLoading = true;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  List<Nota> get _notasFiltradas {
    final query = _busca.trim().toLowerCase();
    if (query.isEmpty) return _notas;
    return _notas
        .where((nota) => nota.texto.toLowerCase().contains(query))
        .toList(growable: false);
  }

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
    var textoEditado = nota?.texto ?? '';
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nota == null ? 'Nova anotação' : 'Editar anotação'),
        content: TextField(
          controller: TextEditingController(text: textoEditado),
          onChanged: (value) => textoEditado = value,
          minLines: 5,
          maxLines: 10,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Registre uma ideia, encaminhamento ou lembrete...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final texto = textoEditado.trim();
              if (texto.isNotEmpty) Navigator.pop(context, texto);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (!mounted || resultado == null || resultado.isEmpty) return;
    final agora = DateTime.now();
    setState(() {
      if (nota == null) {
        _notas.insert(
          0,
          Nota(
            id: 'nota_${agora.microsecondsSinceEpoch}',
            texto: resultado,
            data: agora,
          ),
        );
      } else {
        final index = _notas.indexWhere((item) => item.id == nota.id);
        if (index >= 0) {
          _notas[index] = Nota(id: nota.id, texto: resultado, data: agora);
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final notas = _notasFiltradas;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nova anotação',
        onPressed: () => _criarOuEditarNota(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova anotação'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SigadColors.brandDeep, SigadColors.brand],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.sticky_note_2_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anotações',
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_notas.length} registro(s) salvo(s) neste dispositivo',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _busca = value),
            decoration: const InputDecoration(
              hintText: 'Buscar anotações',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 16),
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
                  Icon(Icons.search_off_rounded, size: 48, color: colors.outline),
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
                ),
              ),
            ),
        ],
      ),
    );
  }
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
            child: const Icon(
              Icons.note_add_outlined,
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
            icon: const Icon(Icons.add_rounded),
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
  });

  final Nota nota;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SigadColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nota.texto,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Opções da anotação',
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar anotação')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir anotação')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 16, color: colors.onSurfaceVariant),
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
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Excluir anotação',
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: colors.error),
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
