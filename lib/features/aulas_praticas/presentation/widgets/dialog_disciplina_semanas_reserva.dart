import 'package:flutter/material.dart';

class DialogDisciplinaSemanasReserva extends StatefulWidget {
  const DialogDisciplinaSemanasReserva({super.key});

  @override
  State<DialogDisciplinaSemanasReserva> createState() => DialogDisciplinaSemanasReservaState();
}

class DialogDisciplinaSemanasReservaState extends State<DialogDisciplinaSemanasReserva> {
  final TextEditingController _disciplinaController = TextEditingController();
  int _totalSemanas = 1;

  @override
  void dispose() {
    _disciplinaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Reserva'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _disciplinaController,
            decoration: const InputDecoration(labelText: 'Disciplina (opcional)'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Total de semanas:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _totalSemanas,
                items: List.generate(6, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('${i + 1}'),
                )),
                onChanged: (v) {
                  if (v != null) setState(() => _totalSemanas = v);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'disciplina': _disciplinaController.text.trim().isEmpty ? null : _disciplinaController.text.trim(),
              'totalSemanas': _totalSemanas,
            });
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
