import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/chat_message_entity.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessageEntity? message;
  final bool isTyping;

  const ChatMessageItem({
    super.key,
    required this.message,
  }) : isTyping = false;

  const ChatMessageItem.typing({
    super.key,
  }) : message = null, isTyping = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isTyping) {
      return _buildMessage(
        context,
        isUser: false,
        child: _buildTypingIndicator(theme),
        timestamp: DateTime.now(),
      );
    }
    
    if (message == null) {
      return const SizedBox.shrink();
    }

    return _buildMessage(
      context,
      isUser: message!.isUser,
      child: message!.isUser 
          ? _buildUserMessage(context)
          : _buildAIMessage(context),
      timestamp: message!.timestamp,
    );
  }
  
  Widget _buildMessage(
    BuildContext context, {
    required bool isUser,
    required Widget child,
    required DateTime timestamp,
  }) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(0) : null,
                  bottomLeft: !isUser ? const Radius.circular(0) : null,
                ),
              ),
              child: child,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                timeFormat.format(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      message!.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          data: message!.content,
          styleSheet: MarkdownStyleSheet(
            p: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            h1: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            h2: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            h3: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            code: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
          ),
          selectable: true,
          onTapLink: (text, href, title) {
            // Handle link taps
            if (href != null) {
              // Implement URL launching logic
            }
          },
        ),
        if (message!.content.contains('```'))
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                // Extract code blocks
                final codeBlocks = _extractCodeBlocks(message!.content);
                if (codeBlocks.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: codeBlocks.join('\n\n')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard')),
                  );
                }
              },
              tooltip: 'Copy code',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
      ],
    );
  }
  
  List<String> _extractCodeBlocks(String content) {
    final codeBlockRegex = RegExp(r'```[\w]*\n([\s\S]*?)\n```', multiLine: true);
    final matches = codeBlockRegex.allMatches(content);
    
    return matches.map((match) => match.group(1) ?? '').toList();
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPulsingDot(theme, 0),
        const SizedBox(width: 4),
        _buildPulsingDot(theme, 300),
        const SizedBox(width: 4),
        _buildPulsingDot(theme, 600),
      ],
    );
  }
  
  Widget _buildPulsingDot(ThemeData theme, int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}