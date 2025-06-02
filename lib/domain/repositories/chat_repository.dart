import '../entities/chat_message_entity.dart';
import '../entities/conversation_entity.dart';

abstract class ChatRepository {
  Future<List<ConversationEntity>> getConversations();
  Future<ConversationEntity> createConversation(String title);
  Future<void> deleteAllConversations();
  Future<List<ChatMessageEntity>> getConversationMessages(String conversationId);
  Future<ChatMessageEntity> sendMessage(String conversationId, String content);
  Future<void> deleteConversation(String conversationId);

}