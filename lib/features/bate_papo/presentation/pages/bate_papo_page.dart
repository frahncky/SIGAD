import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/chat_provider.dart';
import '../../../../core/services/user_context_provider.dart';

class BatePapoPage extends StatefulWidget {
  const BatePapoPage({super.key});

  @override
  State<BatePapoPage> createState() => _BatePapoPageState();
}

class _BatePapoPageState extends State<BatePapoPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedContactEmail;
  bool _mobileConversationOpen = false;
  String _conversationSearch = '';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final currentUser = userContext.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Faça login para acessar o bate-papo.'));
    }

    final chatProvider = context.watch<ChatProvider>();
    final contacts = chatProvider.contactsFor(currentUser);
    final conversations = _buildConversations(chatProvider, contacts, currentUser.email)
        .where((item) => _matchesConversationSearch(item, _conversationSearch))
        .toList();
    final selectedContact = _resolveSelectedContact(conversations.map((item) => item.contact).toList());

    if (contacts.isEmpty || selectedContact == null) {
      if (_conversationSearch.trim().isNotEmpty) {
        return const Center(child: Text('Nenhuma conversa encontrada para a busca.'));
      }
      return const Center(child: Text('Nenhum usuário disponível para conversa.'));
    }

    final messages = chatProvider.messagesBetween(currentUser.email, selectedContact.email);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        if (isWide) {
          return Row(
            children: [
              SizedBox(
                width: 320,
                child: _ConversationListPanel(
                  conversations: conversations,
                  selectedContactEmail: selectedContact.email,
                  searchValue: _conversationSearch,
                  onSearchChanged: (value) => setState(() => _conversationSearch = value),
                  onSelect: (email) => setState(() => _selectedContactEmail = email),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ChatPanel(
                  currentUserEmail: currentUser.email,
                  selectedContact: selectedContact,
                  messages: messages,
                  controller: _messageController,
                  onSend: () => _sendMessage(currentUser, selectedContact.email),
                  onBack: null,
                ),
              ),
            ],
          );
        }

        if (!_mobileConversationOpen) {
          return _ConversationListPanel(
            conversations: conversations,
            selectedContactEmail: selectedContact.email,
            searchValue: _conversationSearch,
            onSearchChanged: (value) => setState(() => _conversationSearch = value),
            onSelect: (email) {
              setState(() {
                _selectedContactEmail = email;
                _mobileConversationOpen = true;
              });
            },
          );
        }

        return _ChatPanel(
          currentUserEmail: currentUser.email,
          selectedContact: selectedContact,
          messages: messages,
          controller: _messageController,
          onSend: () => _sendMessage(currentUser, selectedContact.email),
          onBack: () {
            setState(() => _mobileConversationOpen = false);
          },
        );
      },
    );
  }

  List<_ConversationSummary> _buildConversations(
    ChatProvider chatProvider,
    List<ChatContact> contacts,
    String currentUserEmail,
  ) {
    final items = contacts
        .map(
          (contact) => _ConversationSummary(
            contact: contact,
            messages: chatProvider.messagesBetween(currentUserEmail, contact.email),
          ),
        )
        .toList();

    items.sort((a, b) {
      final lastA = a.lastMessage?.sentAt;
      final lastB = b.lastMessage?.sentAt;
      if (lastA != null && lastB != null) {
        return lastB.compareTo(lastA);
      }
      if (lastA != null) return -1;
      if (lastB != null) return 1;
      return a.contact.name.toLowerCase().compareTo(b.contact.name.toLowerCase());
    });

    return items;
  }

  bool _matchesConversationSearch(_ConversationSummary item, String query) {
    final search = query.trim().toLowerCase();
    if (search.isEmpty) return true;

    return item.contact.name.toLowerCase().contains(search) ||
        item.contact.email.toLowerCase().contains(search) ||
        item.contact.role.displayName.toLowerCase().contains(search);
  }

  ChatContact? _resolveSelectedContact(List<ChatContact> contacts) {
    if (contacts.isEmpty) {
      _selectedContactEmail = null;
      return null;
    }

    final selected = contacts.where((item) => item.email == _selectedContactEmail).firstOrNull;
    if (selected != null) {
      return selected;
    }

    _selectedContactEmail = contacts.first.email;
    return contacts.first;
  }

  void _sendMessage(currentUser, String recipientEmail) {
    final content = _messageController.text.trim();
    if (content.isEmpty) {
      return;
    }

    context.read<ChatProvider>().sendMessage(
          sender: currentUser,
          recipientEmail: recipientEmail,
          content: content,
        );

    _messageController.clear();
  }
}

class _ConversationListPanel extends StatelessWidget {
  const _ConversationListPanel({
    required this.conversations,
    required this.selectedContactEmail,
    required this.searchValue,
    required this.onSearchChanged,
    required this.onSelect,
  });

  final List<_ConversationSummary> conversations;
  final String selectedContactEmail;
  final String searchValue;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar conversa',
                    suffixIcon: searchValue.trim().isNotEmpty
                        ? IconButton(
                            onPressed: () => onSearchChanged(''),
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Nenhuma conversa encontrada.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final contact = conversation.contact;
                      final selected = contact.email == selectedContactEmail;
                      return _ConversationTile(
                        conversation: conversation,
                        selected: selected,
                        onTap: () => onSelect(contact.email),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.selected,
    required this.onTap,
  });

  final _ConversationSummary conversation;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lastMessage = conversation.lastMessage;
    final preview = lastMessage?.content ?? conversation.contact.role.displayName;

    return Material(
      color: selected ? SigadColors.brand.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: SigadColors.surfaceAlt,
                child: Text(
                  _initials(conversation.contact.name),
                  style: const TextStyle(color: SigadColors.brandDark, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.contact.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (lastMessage != null)
                          Text(
                            _conversationTimeLabel(lastMessage.sentAt),
                            style: textTheme.labelSmall?.copyWith(color: SigadColors.muted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.currentUserEmail,
    required this.selectedContact,
    required this.messages,
    required this.controller,
    required this.onSend,
    required this.onBack,
  });

  final String currentUserEmail;
  final ChatContact selectedContact;
  final List<ChatMessage> messages;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SigadColors.divider)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: SigadColors.surfaceAlt,
                  child: Text(
                    _initials(selectedContact.name),
                    style: const TextStyle(color: SigadColors.brandDark, fontWeight: FontWeight.w700),
                  ),
                ),
                if (onBack != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedContact.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        selectedContact.role.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma mensagem ainda.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final ownMessage = _normalizeEmail(message.senderEmail) == _normalizeEmail(currentUserEmail);
                      return Align(
                        alignment: ownMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 540),
                          decoration: BoxDecoration(
                            color: ownMessage ? SigadColors.brand.withValues(alpha: 0.14) : SigadColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message.content),
                              const SizedBox(height: 4),
                              Text(
                                _timeLabel(message.sentAt),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: SigadColors.muted),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SigadColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem',
                      prefixIcon: Icon(Icons.chat_bubble_outline),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationSummary {
  const _ConversationSummary({
    required this.contact,
    required this.messages,
  });

  final ChatContact contact;
  final List<ChatMessage> messages;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}

String _initials(String name) {
  final parts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
}

String _timeLabel(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _conversationTimeLabel(DateTime dateTime) {
  final now = DateTime.now();
  final isSameDay = now.year == dateTime.year && now.month == dateTime.month && now.day == dateTime.day;
  if (isSameDay) {
    return _timeLabel(dateTime);
  }

  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  return '$day/$month';
}

String _normalizeEmail(String email) => email.trim().toLowerCase();
