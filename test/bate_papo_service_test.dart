import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/features/bate_papo/domain/bate_papo_service.dart';
import 'package:sigad/features/bate_papo/domain/conversation_summary.dart';

void main() {
  group('BatePapoService', () {
    test('ordena conversas por data da ultima mensagem', () {
      final contatoA = const ChatContact(
        name: 'Ana',
        email: 'ana@u.br',
        role: UserRole.professor,
      );
      final contatoB = const ChatContact(
        name: 'Bruno',
        email: 'bruno@u.br',
        role: UserRole.coordenador,
      );

      final conversaAntiga = ConversationSummary(
        contact: contatoA,
        messages: [
          ChatMessage(
            id: '1',
            senderEmail: 'ana@u.br',
            recipientEmail: 'b@u.br',
            content: 'Oi',
            sentAt: DateTime(2026, 4, 10, 10),
          ),
        ],
      );

      final conversaNova = ConversationSummary(
        contact: contatoB,
        messages: [
          ChatMessage(
            id: '2',
            senderEmail: 'bruno@u.br',
            recipientEmail: 'b@u.br',
            content: 'Tudo bem?',
            sentAt: DateTime(2026, 4, 11, 10),
          ),
        ],
      );

      final ordenadas = BatePapoService.buildConversations([
        conversaAntiga,
        conversaNova,
      ]);
      expect(ordenadas.first.contact.email, 'bruno@u.br');
    });

    test('aplica filtro de busca por nome/email/cargo', () {
      final conversa = ConversationSummary(
        contact: const ChatContact(
          name: 'Maria Santos',
          email: 'maria@u.br',
          role: UserRole.coordenador,
        ),
        messages: const [],
      );

      expect(
        BatePapoService.matchesConversationSearch(conversa, 'maria'),
        isTrue,
      );
      expect(
        BatePapoService.matchesConversationSearch(conversa, 'coordenador'),
        isTrue,
      );
      expect(
        BatePapoService.matchesConversationSearch(conversa, 'xyz'),
        isFalse,
      );
    });
  });
}
