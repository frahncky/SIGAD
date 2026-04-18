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
    final allContacts = chatProvider.contactsFor(currentUser);
    final allSummaries = _buildConversations(chatProvider, allContacts, currentUser.email);
    // Only show conversations that have at least one message
    final conversations = allSummaries
        .where((item) => item.lastMessage != null)
        .where((item) => _matchesConversationSearch(item, _conversationSearch))
        .toList();
    // Selected contact can be any contact (including one without messages)
    final selectedContact = _resolveSelectedContact(allContacts);

    if (allContacts.isEmpty) {
      return const Center(child: Text('Nenhum usuário disponível para conversa.'));
    }

    final messages = selectedContact == null
        ? <ChatMessage>[]
        : chatProvider.messagesBetween(currentUser.email, selectedContact.email);

    void openNewConversation() {
      _showNewConversationSheet(context, allContacts, (email) {
        setState(() {
          _selectedContactEmail = email;
          _mobileConversationOpen = true;
        });
      });
    }

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
                  selectedContactEmail: selectedContact?.email,
                  searchValue: _conversationSearch,
                  onSearchChanged: (value) => setState(() => _conversationSearch = value),
                  onSelect: (email) => setState(() => _selectedContactEmail = email),
                  onNewConversation: openNewConversation,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: selectedContact == null
                    ? _EmptyChatPlaceholder(onNewConversation: openNewConversation)
                    : _ChatPanel(
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

        if (!_mobileConversationOpen || selectedContact == null) {
          return _ConversationListPanel(
            conversations: conversations,
            selectedContactEmail: selectedContact?.email,
            searchValue: _conversationSearch,
            onSearchChanged: (value) => setState(() => _conversationSearch = value),
            onSelect: (email) {
              setState(() {
                _selectedContactEmail = email;
                _mobileConversationOpen = true;
              });
            },
            onNewConversation: openNewConversation,
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

  void _showNewConversationSheet(
    BuildContext context,
    List<ChatContact> contacts,
    ValueChanged<String> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NewConversationSheet(
        contacts: contacts,
        onSelect: (email) {
          Navigator.pop(context);
          onSelect(email);
        },
      ),
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

  ChatContact? _resolveSelectedContact(List<ChatContact> allContacts) {
    if (allContacts.isEmpty) return null;
    return allContacts.where((c) => c.email == _selectedContactEmail).firstOrNull;
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
    required this.onNewConversation,
  });

  final List<_ConversationSummary> conversations;
  final String? selectedContactEmail;
  final String searchValue;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSelect;
  final VoidCallback onNewConversation;

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
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Conversas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: onNewConversation,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Nova conversa',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined, size: 40, color: SigadColors.muted),
                          const SizedBox(height: 12),
                          Text(
                            searchValue.trim().isNotEmpty
                                ? 'Nenhuma conversa encontrada.'
                                : 'Nenhuma conversa ainda.\nToque em ✏️ para iniciar.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
                          ),
                        ],
                      ),
                    ),
                  )
                : _ConversationListView(
                    conversations: conversations,
                    selectedContactEmail: selectedContactEmail,
                    onSelect: onSelect,
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
    final hasMessages = lastMessage != null;

    return Material(
      color: selected ? SigadColors.brand.withValues(alpha: 0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: SigadColors.surfaceAlt,
                    child: Text(
                      _initials(conversation.contact.name),
                      style: const TextStyle(color: SigadColors.brandDark, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: SigadColors.brand,
                          shape: BoxShape.circle,
                          border: Border.all(color: SigadColors.surface, width: 2),
                        ),
                      ),
                    ),
                ],
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
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: selected ? SigadColors.brand : null,
                            ),
                          ),
                        ),
                        if (hasMessages)
                          Text(
                            _conversationTimeLabel(lastMessage.sentAt),
                            style: textTheme.labelSmall?.copyWith(color: SigadColors.muted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conversation.contact.role.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(color: SigadColors.brand.withValues(alpha: 0.75)),
                    ),
                    if (hasMessages) ...[
                      const SizedBox(height: 2),
                      Text(
                        lastMessage.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                      ),
                    ],
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
            padding: EdgeInsets.only(
              left: onBack != null ? 4 : 16,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SigadColors.divider)),
            ),
            child: Row(
              children: [
                if (onBack != null)
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                CircleAvatar(
                  backgroundColor: SigadColors.surfaceAlt,
                  child: Text(
                    _initials(selectedContact.name),
                    style: const TextStyle(color: SigadColors.brandDark, fontWeight: FontWeight.w700),
                  ),
                ),
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

// ─── Conversation list with sections ───────────────────────────────────────

class _ConversationListView extends StatelessWidget {
  const _ConversationListView({
    required this.conversations,
    required this.selectedContactEmail,
    required this.onSelect,
  });

  final List<_ConversationSummary> conversations;
  final String? selectedContactEmail;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = conversations
        .map<Widget>((c) => _ConversationTile(
              conversation: c,
              selected: c.contact.email == selectedContactEmail,
              onTap: () => onSelect(c.contact.email),
            ))
        .toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (_, i) => items[i],
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder({required this.onNewConversation});
  final VoidCallback onNewConversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 56, color: SigadColors.muted),
            const SizedBox(height: 16),
            Text(
              'Selecione uma conversa\nou inicie uma nova',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onNewConversation,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Nova conversa'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewConversationSheet extends StatefulWidget {
  const _NewConversationSheet({
    required this.contacts,
    required this.onSelect,
  });

  final List<ChatContact> contacts;
  final ValueChanged<String> onSelect;

  @override
  State<_NewConversationSheet> createState() => _NewConversationSheetState();
}

class _NewConversationSheetState extends State<_NewConversationSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.contacts.where((c) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.role.displayName.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: SigadColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Nova conversa',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome, e-mail ou cargo',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Nenhum contato encontrado.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final contact = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: SigadColors.surfaceAlt,
                            child: Text(
                              _initials(contact.name),
                              style: const TextStyle(color: SigadColors.brandDark, fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            contact.role.displayName,
                            style: TextStyle(color: SigadColors.brand.withValues(alpha: 0.8), fontSize: 12),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onTap: () => widget.onSelect(contact.email),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────

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
