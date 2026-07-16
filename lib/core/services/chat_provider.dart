import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/user_role.dart';
import 'app_event_logger.dart';
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
    _initialization = _loadData();
    _persistenceQueue = _initialization;
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
  final Map<String, DateTime> _lastReadByUserConversation = {};
  late final Future<void> _initialization;
  late Future<void> _persistenceQueue;

  Future<void> get ready => _initialization;

  @visibleForTesting
  Future<void> get pendingPersistence => _persistenceQueue;

  List<ChatContact> contactsFor(User currentUser) {
    final currentEmail = _normalizeEmail(currentUser.email);
    final contacts = List<ChatContact>.from(_baseContacts);

    final known = contacts.any(
      (contact) => _normalizeEmail(contact.email) == currentEmail,
    );
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
    final messages = List<ChatMessage>.from(
      _messagesByConversation[key] ?? const [],
    );
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  int unreadCountForUser(String userEmail) {
    final normalizedUser = _normalizeEmail(userEmail);
    var total = 0;

    for (final entry in _messagesByConversation.entries) {
      final conversationKey = entry.key;
      final messages = entry.value;
      final readKey = _userConversationReadKey(normalizedUser, conversationKey);
      final lastReadAt = _lastReadByUserConversation[readKey];

      for (final message in messages) {
        final isRecipient =
            _normalizeEmail(message.recipientEmail) == normalizedUser;
        if (!isRecipient) continue;
        if (lastReadAt == null || message.sentAt.isAfter(lastReadAt)) {
          total++;
        }
      }
    }

    return total;
  }

  void markConversationAsRead({
    required String userEmail,
    required String contactEmail,
  }) {
    final normalizedUser = _normalizeEmail(userEmail);
    final conversationKey = _conversationKey(userEmail, contactEmail);
    final messages =
        _messagesByConversation[conversationKey] ?? const <ChatMessage>[];
    if (messages.isEmpty) {
      return;
    }

    DateTime? latestIncomingAt;
    for (final message in messages) {
      if (_normalizeEmail(message.recipientEmail) != normalizedUser) continue;
      if (latestIncomingAt == null ||
          message.sentAt.isAfter(latestIncomingAt)) {
        latestIncomingAt = message.sentAt;
      }
    }

    if (latestIncomingAt == null) {
      return;
    }

    final readKey = _userConversationReadKey(normalizedUser, conversationKey);
    final current = _lastReadByUserConversation[readKey];
    if (current != null && !latestIncomingAt.isAfter(current)) {
      return;
    }

    _lastReadByUserConversation[readKey] = latestIncomingAt;
    notifyListeners();
    _enqueuePersistence(
      eventName: 'chat_read_state_save_error',
      operation: _saveReadStateNow,
    );
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
    _messagesByConversation
        .putIfAbsent(key, () => <ChatMessage>[])
        .add(message);
    notifyListeners();
    _enqueuePersistence(
      eventName: 'chat_messages_save_error',
      operation: _saveDataNow,
    );
  }

  static const String _kKey = 'sigad_chat_messages';
  static const String _kReadKey = 'sigad_chat_read_state';

  Future<void> _loadData() async {
    try {
      final list = await LocalStorageService.loadListOrNull(_kKey);
      final shouldSeed = list == null;
      if (shouldSeed) {
        _seedMessages();
      } else {
        for (final json in list) {
          final senderEmail = json['senderEmail'] as String;
          final recipientEmail = json['recipientEmail'] as String;
          final key = _conversationKey(senderEmail, recipientEmail);
          _messagesByConversation
              .putIfAbsent(key, () => <ChatMessage>[])
              .add(
                ChatMessage(
                  id: json['id'] as String,
                  senderEmail: senderEmail,
                  recipientEmail: recipientEmail,
                  content: json['content'] as String,
                  sentAt: DateTime.parse(json['sentAt'] as String),
                ),
              );
        }
      }

      await _loadReadState();
      if (shouldSeed) {
        await _runPersistence(
          eventName: 'chat_seed_messages_save_error',
          operation: _saveDataNow,
        );
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppEventLogger.error('chat_load_error', error, stackTrace: stackTrace);
    }
  }

  Future<void> _saveDataNow() {
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
    return LocalStorageService.saveList(_kKey, allMessages);
  }

  Future<void> _loadReadState() async {
    final list = await LocalStorageService.loadList(_kReadKey);
    _lastReadByUserConversation.clear();
    for (final json in list) {
      final userEmail = json['userEmail'] as String?;
      final conversationKey = json['conversationKey'] as String?;
      final readAtRaw = json['readAt'] as String?;
      if (userEmail == null || conversationKey == null || readAtRaw == null) {
        continue;
      }
      final readAt = DateTime.tryParse(readAtRaw);
      if (readAt == null) continue;
      final key = _userConversationReadKey(userEmail, conversationKey);
      _lastReadByUserConversation[key] = readAt;
    }
  }

  Future<void> _saveReadStateNow() {
    final data = <Map<String, dynamic>>[];
    for (final entry in _lastReadByUserConversation.entries) {
      final parts = entry.key.split('|');
      if (parts.length < 3) continue;
      final userEmail = parts.first;
      final conversationKey = '${parts[1]}|${parts[2]}';
      data.add({
        'userEmail': userEmail,
        'conversationKey': conversationKey,
        'readAt': entry.value.toIso8601String(),
      });
    }
    return LocalStorageService.saveList(_kReadKey, data);
  }

  void _enqueuePersistence({
    required String eventName,
    required Future<void> Function() operation,
  }) {
    _persistenceQueue = _persistenceQueue.then(
      (_) => _runPersistence(eventName: eventName, operation: operation),
    );
  }

  Future<void> _runPersistence({
    required String eventName,
    required Future<void> Function() operation,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      AppEventLogger.error(eventName, error, stackTrace: stackTrace);
    }
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
    final list = _messagesByConversation.putIfAbsent(
      key,
      () => <ChatMessage>[],
    );
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
    final normalized = [_normalizeEmail(emailA), _normalizeEmail(emailB)]
      ..sort();
    return '${normalized.first}|${normalized.last}';
  }

  String _userConversationReadKey(String userEmail, String conversationKey) {
    final normalizedUser = _normalizeEmail(userEmail);
    return '$normalizedUser|$conversationKey';
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}
