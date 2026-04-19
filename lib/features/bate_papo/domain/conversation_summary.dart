import '../../../core/services/chat_provider.dart';

class ConversationSummary {
  const ConversationSummary({
    required this.contact,
    required this.messages,
  });

  final ChatContact contact;
  final List<ChatMessage> messages;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}
