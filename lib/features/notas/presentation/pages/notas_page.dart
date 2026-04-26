import 'package:flutter/material.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({Key? key}) : super(key: key);

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class Nota {
  String texto;
  DateTime data;
  Nota({required this.texto, required this.data});
}

class _NotasPageState extends State<NotasPage> {
  final List<Nota> _notas = [];

  void _criarOuEditarNota({Nota? nota, int? index}) async {
    final controller = TextEditingController(text: nota?.texto ?? "");
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nota == null ? 'Nova anotação' : 'Editar anotação'),
        content: TextField(
          controller: controller,
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
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (resultado != null && resultado.isNotEmpty) {
      setState(() {
        if (nota != null && index != null) {
          _notas[index] = Nota(texto: resultado, data: DateTime.now());
        } else {
          _notas.insert(0, Nota(texto: resultado, data: DateTime.now()));
        }
      });
    }
  }

  void _excluirNota(int index) async {
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
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      setState(() {
        _notas.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anotações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _notas.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma anotação. Toque em "+" para criar.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : ListView.separated(
                itemCount: _notas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final nota = _notas[index];
                  return Dismissible(
                    key: ValueKey(nota.data.toIso8601String() + nota.texto),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      color: Colors.red.shade100,
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    confirmDismiss: (_) async {
                      _excluirNota(index);
                      return false;
                    },
                    child: GestureDetector(
                      onTap: () => _criarOuEditarNota(nota: nota, index: index),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nota.texto,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Editável',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${nota.data.day.toString().padLeft(2, '0')}/${nota.data.month.toString().padLeft(2, '0')} ${nota.data.hour.toString().padLeft(2, '0')}:${nota.data.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _criarOuEditarNota(),
        tooltip: 'Nova anotação',
        child: const Icon(Icons.add),
      ),
    );
  }
}
