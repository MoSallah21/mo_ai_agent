import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mo_ai_agent/presentation/pages/settings_page.dart';

import '../../core/constants/app_constants.dart';
import '../blocs/chat/chat_cubit.dart';
import '../widgets/conversation_item.dart';
import 'chat_page.dart';


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (previous, current) =>
            previous.conversations.length != current.conversations.length,
            builder: (context, state) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.conversations.isNotEmpty)
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'delete_all') {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete All Conversations'),
                              content: const Text(
                                'Are you sure you want to delete all conversations? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true && mounted) {
                            context.read<ChatCubit>().deleteAllConversations();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("All conversations deleted"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'delete_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever),
                              SizedBox(width: 8),
                              Text('Delete All Conversations'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (previous, current) =>
        previous.status != current.status ||
            previous.conversations.length != current.conversations.length,
        builder: (context, state) {
          if (state.status == ChatStatus.loading && state.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ChatStatus.failure && state.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load conversations',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ChatCubit>().loadConversations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: state.conversations.isEmpty
                    ? _buildEmptyState(context)
                    : _buildConversationsList(context, state),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _startNewChat(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Start New Chat'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No conversations yet'),
          SizedBox(height: 8),
          Text('Start a new chat to begin', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildConversationsList(BuildContext context, ChatState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: state.conversations.length,
      cacheExtent: 500, // Optimize scrolling performance
      itemBuilder: (context, index) {
        final conversation = state.conversations[index];
        return Dismissible(
          key: ValueKey(conversation.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Delete Conversation"),
                  content: const Text("Are you sure you want to delete this conversation?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Delete"),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            final conversationTitle = conversation.title;
            context.read<ChatCubit>().deleteConversation(conversation.id);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$conversationTitle deleted"),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: ConversationItem(
            key: ValueKey(conversation.id),
            conversation: conversation,
            isSelected: conversation.id == state.currentConversationId,
            onTap: () {
              context.read<ChatCubit>().selectConversation(conversation.id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
            },
          ),
        );
      },
    );
  }

  void _startNewChat(BuildContext context) async {
    await context.read<ChatCubit>().createConversation('New conversation');

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatPage()),
      );
    }
  }
}