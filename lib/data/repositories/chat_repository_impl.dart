import '../../core/errors/exceptions.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/lcoal/chat_local_datasource.dart';
import '../datasources/remote/ai_remote_datasource.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;
  final AIRemoteDataSource remoteDataSource;
  final Uuid _uuid = const Uuid();

  ChatRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<ConversationEntity>> getConversations() async {
    final conversations = await localDataSource.getConversations();
    return conversations;
  }

  @override
  Future<ConversationEntity> createConversation(String title) async {
    final conversation = Conversation(
      id: _uuid.v4(),
      title: title,
      createdAt: DateTime.now(),
    );

    return await localDataSource.createConversation(conversation);
  }

  @override
  Future<List<ChatMessageEntity>> getConversationMessages(String conversationId) async {
    final messages = await localDataSource.getConversationMessages(conversationId);
    return messages;
  }

  @override
  Future<ChatMessageEntity> sendMessage(String conversationId, String content) async {
    // Save user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    await localDataSource.saveMessage(userMessage);

    // Get conversation history for context
    final messagesHistory = await localDataSource.getConversationMessages(conversationId);

    // Format messages for OpenAI API
    final formattedMessages = messagesHistory.map((message) {
      return {
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.content,
      };
    }).toList();

    // Get AI response
    final responseContent = await remoteDataSource.generateResponse(formattedMessages);

    // Save AI response
    final aiResponse = ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      content: responseContent,
      isUser: false,
      timestamp: DateTime.now(),
    );

    await localDataSource.saveMessage(aiResponse);

    return aiResponse;
  }

  @override
  Future<void> deleteAllConversations() async {
    try {
      await localDataSource.deleteAllConversations();
    } catch (e) {
      throw CacheException(message: 'Failed to delete conversations: $e');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await localDataSource.deleteConversation(conversationId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete conversation: $e');
    }
  }
}
