import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationHistoryUseCase {
  final ChatRepository repository;

  GetConversationHistoryUseCase({required this.repository});

  Future<List<ChatMessageEntity>> execute(String conversationId) {
    return repository.getConversationMessages(conversationId);
  }
}