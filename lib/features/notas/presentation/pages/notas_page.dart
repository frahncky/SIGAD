import 'package:flutter/material.dart';

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

    final savedId = (map['id'] as String?)?.trim();
    return Nota(
      id: savedId == null || savedId.isEmpty
          ? 'nota_${data.microsecondsSinceEpoch}_${texto.length}'
          : savedId,
      texto: texto,
      data: data,
    );
  }
}

class _NotasPageState extends State<NotasPage> {
  static const _storageKey = 'sigad_notas';

  final List<Nota> _notas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarNotas();
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
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarNotas() {
    return LocalStorageService.saveList(
      _storageKey,
      _notas.map((nota) => nota.toMap()).toList(growable: false),
    );
  }

  String _novoId() => 'nota_${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _criarOuEditarNota({Nota? nota}) async {
    var textoEditado = nota?.texto ?? '';
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nota == null ? 'Nova anotação' : 'Editar anotação'),
        content: TextFormField(
          initialValue: textoEditado,
          onChanged: (value) => textoEditado = value,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Digite sua anotação...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
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
                Navigator.pop(context, texto);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (!mounted || resultado == null || resultado.isEmpty) return;

    final agora = DateTime.now();
    setState(() {
      if (nota != null) {
        final index = _notas.indexWhere((item) => item.id == nota.id);
        if (index >= 0) {
          _notas[index] = Nota(id: nota.id, texto: resultado, data: agora);
        }
      } else {
        _notas.insert(0, Nota(id: _novoId(), texto: resultado, data: agora));
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
            child: Text(
              'Excluir',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Anotações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notas.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma anotação. Toque em "+" para criar.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : ListView.separated(
                itemCount: _notas.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final nota = _notas[index];
                  return Dismissible(
                    key: ValueKey(nota.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      color: colors.errorContainer,
                      child: Icon(
                        Icons.delete,
                        color: colors.onErrorContainer,
                        size: 28,
                      ),
                    ),
                    confirmDismiss: (_) async {
                      await _excluirNota(nota);
                      return false;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    nota.texto,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_note,
                                    color: colors.primary,
                                    size: 26,
                                  ),
                                  tooltip: 'Editar anotação',
                                  onPressed: () =>
                                      _criarOuEditarNota(nota: nota),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: colors.error,
                                    size: 24,
                                  ),
                                  tooltip: 'Excluir anotação',
                                  onPressed: () => _excluirNota(nota),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 15,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${nota.data.day.toString().padLeft(2, '0')}/${nota.data.month.toString().padLeft(2, '0')} ${nota.data.hour.toString().padLeft(2, '0')}:${nota.data.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _criarOuEditarNota(),
        tooltip: 'Nova anotação',
        child: const Icon(Icons.add),
      ),
    );
  }
}
