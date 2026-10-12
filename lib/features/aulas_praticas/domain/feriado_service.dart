import 'feriado_models.dart';

/// Feriados legais exibidos como informação no calendário de reservas.
///
/// O calendário acadêmico da instituição, recessos e pontos facultativos não fazem
/// parte desta fonte. A presença de um feriado não altera disponibilidade,
/// criação ou exclusão de reservas.
///
/// Feriados estaduais, municipais e a Paixão de Cristo de 2026 seguem o
/// Decreto Municipal de São Luís nº 62.168/2025.
abstract final class FeriadoService {
  static const avisoEscopo =
      'Calendário acadêmico da instituição, recessos e pontos facultativos não estão incluídos. Feriados locais validados para 2026.';

  static List<Feriado> feriadosDoAno(int ano) {
    final feriados = <Feriado>[
      _nacional(ano, 1, 1, 'Confraternização Universal'),
      _nacional(ano, 4, 21, 'Tiradentes'),
      _nacional(ano, 5, 1, 'Dia Mundial do Trabalho'),
      _nacional(ano, 9, 7, 'Independência do Brasil'),
      _nacional(ano, 10, 12, 'Nossa Senhora Aparecida'),
      _nacional(ano, 11, 2, 'Finados'),
      _nacional(ano, 11, 15, 'Proclamação da República'),
      _nacional(ano, 12, 25, 'Natal'),
      if (ano >= 2024)
        _nacional(ano, 11, 20, 'Dia Nacional de Zumbi e da Consciência Negra'),
      if (ano == 2026) ...[
        Feriado(
          data: _domingoDePascoa(ano).subtract(const Duration(days: 2)),
          nome: 'Paixão de Cristo',
          abrangencia: AbrangenciaFeriado.nacional,
        ),
        _municipal(ano, 6, 29, 'São Pedro'),
        _estadual(ano, 7, 28, 'Adesão do Maranhão à Independência'),
        _municipal(ano, 9, 8, 'Aniversário de São Luís'),
        _municipal(ano, 12, 8, 'Nossa Senhora da Conceição'),
      ],
    ]..sort((a, b) => a.data.compareTo(b.data));
    return List.unmodifiable(feriados);
  }

  static Feriado? feriadoEm(DateTime data) {
    for (final feriado in feriadosDoAno(data.year)) {
      if (feriado.data.month == data.month && feriado.data.day == data.day) {
        return feriado;
      }
    }
    return null;
  }

  static Feriado _nacional(int ano, int mes, int dia, String nome) => Feriado(
    data: DateTime(ano, mes, dia),
    nome: nome,
    abrangencia: AbrangenciaFeriado.nacional,
  );

  static Feriado _estadual(int ano, int mes, int dia, String nome) => Feriado(
    data: DateTime(ano, mes, dia),
    nome: nome,
    abrangencia: AbrangenciaFeriado.estadual,
  );

  static Feriado _municipal(int ano, int mes, int dia, String nome) => Feriado(
    data: DateTime(ano, mes, dia),
    nome: nome,
    abrangencia: AbrangenciaFeriado.municipal,
  );

  // Algoritmo gregoriano de Meeus/Jones/Butcher.
  static DateTime _domingoDePascoa(int ano) {
    final a = ano % 19;
    final b = ano ~/ 100;
    final c = ano % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final mes = (h + l - 7 * m + 114) ~/ 31;
    final dia = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(ano, mes, dia);
  }
}
