import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../blocs/chat/chat_cubit.dart';
import '../widgets/chat_message_item.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();
  bool _showScrollToBottom = false;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.offset;
          final shouldShow = currentScroll < maxScroll - 100;

          if (_showScrollToBottom != shouldShow) {
            setState(() {
              _showScrollToBottom = shouldShow;
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _focusNode.requestFocus();

    await context.read<ChatCubit>().sendMessage(message);

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (previous, current) =>
          previous.currentConversationId != current.currentConversationId ||
              previous.conversations.length != current.conversations.length,
          builder: (context, state) {
            try {
              final currentConversation = state.conversations.firstWhere(
                    (c) => c.id == state.currentConversationId,
                orElse: () => throw StateError('No conversation selected'),
              );
              return Text(currentConversation.title);
            } catch (e) {
              return const Text('Chat');
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listenWhen: (previous, current) =>
              previous.messages.length != current.messages.length,
              listener: (context, state) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              },
              buildWhen: (previous, current) =>
              previous.status != current.status ||
                  previous.messages.length != current.messages.length ||
                  previous.isTyping != current.isTyping,
              builder: (context, state) {
                if (state.status == ChatStatus.loading && state.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'How can I assist you today?',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            AppConstants.welcomeMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                      // Add cacheExtent for better scrolling performance
                      cacheExtent: 1000,
                      itemBuilder: (context, index) {
                        if (index == state.messages.length && state.isTyping) {
                          return const ChatMessageItem.typing();
                        }
                        final message = state.messages[index];
                        return ChatMessageItem(
                          key: ValueKey(message.id),
                          message: message,
                        );
                      },
                    ),
                    if (_showScrollToBottom)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: _scrollToBottom,
                          child: const Icon(Icons.arrow_downward),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              if (state.status != ChatStatus.failure) return const SizedBox.shrink();
              return Container(
                color: Theme.of(context).colorScheme.errorContainer,
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage ?? 'An error occurred',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        context.read<ChatCubit>().emit(
                          state.copyWith(
                            status: ChatStatus.success,
                            errorMessage: null,
                          ),
                        );
                      },
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<ChatCubit, ChatState>(
                  buildWhen: (previous, current) => previous.isTyping != current.isTyping,
                  builder: (context, state) {
                    return IconButton(
                      onPressed: state.isTyping ? null : _sendMessage,
                      icon: Icon(
                        state.isTyping ? Icons.hourglass_empty : Icons.send,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}