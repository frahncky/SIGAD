import 'conversation_summary.dart';

abstract final class BatePapoService {
  static List<ConversationSummary> buildConversations(
    List<ConversationSummary> items,
  ) {
    final sorted = List<ConversationSummary>.from(items);

    sorted.sort((a, b) {
      final lastA = a.lastMessage?.sentAt;
      final lastB = b.lastMessage?.sentAt;
      if (lastA != null && lastB != null) {
        return lastB.compareTo(lastA);
      }
      if (lastA != null) return -1;
      if (lastB != null) return 1;
      return a.contact.name.toLowerCase().compareTo(b.contact.name.toLowerCase());
    });

    return sorted;
  }

  static bool matchesConversationSearch(ConversationSummary item, String query) {
    final search = query.trim().toLowerCase();
    if (search.isEmpty) return true;

    return item.contact.name.toLowerCase().contains(search) ||
        item.contact.email.toLowerCase().contains(search) ||
        item.contact.role.displayName.toLowerCase().contains(search);
  }
}
