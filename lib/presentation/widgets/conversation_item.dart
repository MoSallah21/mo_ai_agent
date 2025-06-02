import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/conversation_entity.dart';

class ConversationItem extends StatelessWidget {
  final ConversationEntity conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, h:mm a');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: isSelected ? 2 : 1,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(
          conversation.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          dateFormat.format(conversation.createdAt),
          style: theme.textTheme.bodySmall,
        ),
        leading: CircleAvatar(
          backgroundColor: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.secondary,
          child: const Icon(
            Icons.chat_outlined,
            color: Colors.white,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}