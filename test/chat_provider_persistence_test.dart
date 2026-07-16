import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/core/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('lista de mensagens salva vazia não recria fixtures', () async {
    SharedPreferences.setMockInitialValues({'sigad_chat_messages': '[]'});
    final provider = ChatProvider();
    addTearDown(provider.dispose);

    await provider.ready;

    expect(
      provider.messagesBetween('maria.santos@univ.br', 'joao.silva@univ.br'),
      isEmpty,
    );
  });

  test('fila persiste mensagens na ordem de envio', () async {
    SharedPreferences.setMockInitialValues({'sigad_chat_messages': '[]'});
    final provider = ChatProvider();
    addTearDown(provider.dispose);
    await provider.ready;

    final sender = User(
      id: 'user-1',
      name: 'Professor Teste',
      email: 'professor@teste.br',
      role: UserRole.professor,
      createdAt: DateTime(2026),
    );
    provider.sendMessage(
      sender: sender,
      recipientEmail: 'coordenacao@teste.br',
      content: 'Primeira mensagem',
    );
    provider.sendMessage(
      sender: sender,
      recipientEmail: 'coordenacao@teste.br',
      content: 'Segunda mensagem',
    );

    await provider.pendingPersistence;
    final persisted = await LocalStorageService.loadList('sigad_chat_messages');

    expect(persisted.map((item) => item['content']), [
      'Primeira mensagem',
      'Segunda mensagem',
    ]);
  });
}
