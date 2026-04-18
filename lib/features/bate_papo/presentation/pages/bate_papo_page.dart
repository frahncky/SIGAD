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
    final selectedContact = _resolveSelectedContact(contacts);

    if (contacts.isEmpty || selectedContact == null) {
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
                child: _ContactsPanel(
                  contacts: contacts,
                  selectedContactEmail: selectedContact.email,
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
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _MobileContactSelector(
              contacts: contacts,
              selectedContactEmail: selectedContact.email,
              onChanged: (email) => setState(() => _selectedContactEmail = email),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _ChatPanel(
                currentUserEmail: currentUser.email,
                selectedContact: selectedContact,
                messages: messages,
                controller: _messageController,
                onSend: () => _sendMessage(currentUser, selectedContact.email),
              ),
            ),
          ],
        );
      },
    );
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

class _ContactsPanel extends StatelessWidget {
  const _ContactsPanel({
    required this.contacts,
    required this.selectedContactEmail,
    required this.onSelect,
  });

  final List<ChatContact> contacts;
  final String selectedContactEmail;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: contacts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final selected = contact.email == selectedContactEmail;
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: selected ? SigadColors.brand.withValues(alpha: 0.08) : null,
            leading: CircleAvatar(
              backgroundColor: SigadColors.surfaceAlt,
              child: Text(
                _initials(contact.name),
                style: const TextStyle(color: SigadColors.brandDark, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(contact.name),
            subtitle: Text(contact.role.displayName),
            onTap: () => onSelect(contact.email),
          );
        },
      ),
    );
  }
}

class _MobileContactSelector extends StatelessWidget {
  const _MobileContactSelector({
    required this.contacts,
    required this.selectedContactEmail,
    required this.onChanged,
  });

  final List<ChatContact> contacts;
  final String selectedContactEmail;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SigadColors.divider),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedContactEmail,
        decoration: const InputDecoration(
          labelText: 'Conversar com',
          border: InputBorder.none,
        ),
        items: contacts
            .map(
              (contact) => DropdownMenuItem(
                value: contact.email,
                child: Text('${contact.name} • ${contact.role.abbreviation}'),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
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
  });

  final String currentUserEmail;
  final ChatContact selectedContact;
  final List<ChatMessage> messages;
  final TextEditingController controller;
  final VoidCallback onSend;

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

String _normalizeEmail(String email) => email.trim().toLowerCase();
