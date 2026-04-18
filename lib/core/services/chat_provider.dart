import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/user_role.dart';
import 'local_storage_service.dart';

class ChatContact {
  const ChatContact({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final UserRole role;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderEmail,
    required this.recipientEmail,
    required this.content,
    required this.sentAt,
  });

  final String id;
  final String senderEmail;
  final String recipientEmail;
  final String content;
  final DateTime sentAt;
}

class ChatProvider extends ChangeNotifier {
  ChatProvider() {
    _loadData();
  }

  final List<ChatContact> _baseContacts = const [
    ChatContact(
      name: 'João Silva',
      email: 'joao.silva@univ.br',
      role: UserRole.professor,
    ),
    ChatContact(
      name: 'Maria Santos',
      email: 'maria.santos@univ.br',
      role: UserRole.coordenador,
    ),
    ChatContact(
      name: 'Carlos Oliveira',
      email: 'carlos.oliveira@univ.br',
      role: UserRole.servidorAdministrativo,
    ),
    ChatContact(
      name: 'Ana Pereira',
      email: 'ana.pereira@univ.br',
      role: UserRole.chefeDepartamento,
    ),
  ];

  final Map<String, List<ChatMessage>> _messagesByConversation = {};

  List<ChatContact> contactsFor(User currentUser) {
    final currentEmail = _normalizeEmail(currentUser.email);
    final contacts = List<ChatContact>.from(_baseContacts);

    final known = contacts.any((contact) => _normalizeEmail(contact.email) == currentEmail);
    if (!known) {
      contacts.add(
        ChatContact(
          name: currentUser.name,
          email: currentUser.email,
          role: currentUser.role,
        ),
      );
    }

    return contacts
        .where((contact) => _normalizeEmail(contact.email) != currentEmail)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<ChatMessage> messagesBetween(String emailA, String emailB) {
    final key = _conversationKey(emailA, emailB);
    final messages = List<ChatMessage>.from(_messagesByConversation[key] ?? const []);
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  void sendMessage({
    required User sender,
    required String recipientEmail,
    required String content,
  }) {
    final text = content.trim();
    if (text.isEmpty) {
      return;
    }

    final message = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      senderEmail: sender.email,
      recipientEmail: recipientEmail,
      content: text,
      sentAt: DateTime.now(),
    );

    final key = _conversationKey(sender.email, recipientEmail);
    _messagesByConversation.putIfAbsent(key, () => <ChatMessage>[]).add(message);
    notifyListeners();
    _saveData();
  }

  static const String _kKey = 'sigad_chat_messages';

  Future<void> _loadData() async {
    final list = await LocalStorageService.loadList(_kKey);
    if (list.isEmpty) {
      _seedMessages();
      return;
    }
    for (final json in list) {
      final senderEmail = json['senderEmail'] as String;
      final recipientEmail = json['recipientEmail'] as String;
      final key = _conversationKey(senderEmail, recipientEmail);
      _messagesByConversation.putIfAbsent(key, () => <ChatMessage>[]).add(
        ChatMessage(
          id: json['id'] as String,
          senderEmail: senderEmail,
          recipientEmail: recipientEmail,
          content: json['content'] as String,
          sentAt: DateTime.parse(json['sentAt'] as String),
        ),
      );
    }
    notifyListeners();
  }

  void _saveData() {
    final allMessages = <Map<String, dynamic>>[];
    for (final messages in _messagesByConversation.values) {
      for (final msg in messages) {
        allMessages.add({
          'id': msg.id,
          'senderEmail': msg.senderEmail,
          'recipientEmail': msg.recipientEmail,
          'content': msg.content,
          'sentAt': msg.sentAt.toIso8601String(),
        });
      }
    }
    LocalStorageService.saveList(_kKey, allMessages);
  }

  void _seedMessages() {
    _addSeedMessage(
      senderEmail: 'maria.santos@univ.br',
      recipientEmail: 'joao.silva@univ.br',
      content: 'João, conseguiu fechar o relatório da turma de laboratório?',
      sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
    );
    _addSeedMessage(
      senderEmail: 'joao.silva@univ.br',
      recipientEmail: 'maria.santos@univ.br',
      content: 'Sim, envio em 20 minutos com os ajustes finais.',
      sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 58)),
    );
    _addSeedMessage(
      senderEmail: 'ana.pereira@univ.br',
      recipientEmail: 'carlos.oliveira@univ.br',
      content: 'Carlos, precisamos validar os protocolos até 16h.',
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 42)),
    );
    _addSeedMessage(
      senderEmail: 'carlos.oliveira@univ.br',
      recipientEmail: 'ana.pereira@univ.br',
      content: 'Perfeito. Já estou finalizando a conferência.',
      sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    );
  }

  void _addSeedMessage({
    required String senderEmail,
    required String recipientEmail,
    required String content,
    required DateTime sentAt,
  }) {
    final key = _conversationKey(senderEmail, recipientEmail);
    final list = _messagesByConversation.putIfAbsent(key, () => <ChatMessage>[]);
    list.add(
      ChatMessage(
        id: 'seed_${list.length}_${sentAt.microsecondsSinceEpoch}',
        senderEmail: senderEmail,
        recipientEmail: recipientEmail,
        content: content,
        sentAt: sentAt,
      ),
    );
  }

  String _conversationKey(String emailA, String emailB) {
    final normalized = [_normalizeEmail(emailA), _normalizeEmail(emailB)]..sort();
    return '${normalized.first}|${normalized.last}';
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}
