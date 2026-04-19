import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/configuracoes/data/configuracoes_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfiguracoesRepository', () {
    test('carrega com fallback quando faltam campos', () async {
      SharedPreferences.setMockInitialValues({
        'test_configuracoes': jsonEncode({
          'nomePerfil': 'Maria',
          'emailUsuario': 'maria@uni.edu.br',
        }),
      });

      final repo = ConfiguracoesRepository(storageKey: 'test_configuracoes');
      final data = await repo.load();

      expect(data, isNotNull);
      expect(data!.nomePerfil, 'Maria');
      expect(data.emailUsuario, 'maria@uni.edu.br');
      expect(data.modoDark, isFalse);
      expect(data.notificarAntesDaDisciplina, isTrue);
      expect(data.antecedenciaNotificacaoMinutos, 15);
      expect(data.agendaCompromissos, isEmpty);
    });
  });
}
