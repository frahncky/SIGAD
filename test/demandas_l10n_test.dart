import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sigad/features/demandas/domain/demandas_service.dart';
import 'package:sigad/features/demandas/presentation/demandas_l10n.dart';
import 'package:sigad/l10n/l10n.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  test('toda mensagem de validação do serviço tem tradução', () {
    final erros = [
      DemandasService.validarDemanda(titulo: '', descricao: 'x'),
      DemandasService.validarDemanda(titulo: 'x', descricao: ''),
    ];
    for (final erro in erros) {
      expect(erro, isNotNull);
      expect(en.erroDemanda(erro!), isNot(erro));
    }
  });

  test('todo status, prioridade e ordenação tem tradução', () {
    for (final valor in [
      ...DemandasService.statusDisponiveis,
      ...DemandasService.prioridades,
      ...DemandasService.opcoesOrdenacao,
    ]) {
      expect(en.opcaoDemanda(valor), isNot(valor), reason: valor);
    }
  });
}
