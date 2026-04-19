import '../../../core/models/user.dart';
import '../../../core/services/chat_provider.dart';

class BatePapoRepository {
  const BatePapoRepository(this.chatProvider);

  final ChatProvider chatProvider;

  List<ChatContact> contactsFor(User currentUser) {
    return chatProvider.contactsFor(currentUser);
  }

  List<ChatMessage> messagesBetween(String emailA, String emailB) {
    return chatProvider.messagesBetween(emailA, emailB);
  }

  void markConversationAsRead({
    required String userEmail,
    required String contactEmail,
  }) {
    chatProvider.markConversationAsRead(
      userEmail: userEmail,
      contactEmail: contactEmail,
    );
  }

  void sendMessage({
    required User sender,
    required String recipientEmail,
    required String content,
  }) {
    chatProvider.sendMessage(
      sender: sender,
      recipientEmail: recipientEmail,
      content: content,
    );
  }
}
