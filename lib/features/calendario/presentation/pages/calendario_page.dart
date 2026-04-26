import 'package:flutter/material.dart';
import '../widgets/calendario_mes_widget.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime _mesAtual = DateTime.now();
  bool _intlReady = false;

  // Exemplo de feriados nacionais (adicione mais conforme necessário)
  final Map<DateTime, String> _feriados = {
    DateTime(2026, 1, 1): 'Confraternização Universal',
    DateTime(2026, 2, 16): 'Carnaval',
    DateTime(2026, 2, 17): 'Carnaval',
    DateTime(2026, 4, 3): 'Sexta-feira Santa',
    DateTime(2026, 4, 21): 'Tiradentes',
    DateTime(2026, 5, 1): 'Dia do Trabalho',
    DateTime(2026, 9, 7): 'Independência do Brasil',
    DateTime(2026, 10, 12): 'Nossa Senhora Aparecida',
    DateTime(2026, 11, 2): 'Finados',
    DateTime(2026, 11, 15): 'Proclamação da República',
    DateTime(2026, 12, 25): 'Natal',
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null).then((_) {
      setState(() {
        _intlReady = true;
      });
    });
  }

  void _onMesChange(DateTime novoMes) {
    setState(() {
      _mesAtual = DateTime(novoMes.year, novoMes.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_intlReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Calendário Acadêmico')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CalendarioMesWidget(
          mesAtual: _mesAtual,
          feriados: _feriados,
          onDiaSelecionado: (dia) {
            if (dia.month != _mesAtual.month) {
              _onMesChange(dia);
            }
            // Aqui pode abrir detalhes do dia, se desejar
          },
        ),
      ),
    );
  }
}
