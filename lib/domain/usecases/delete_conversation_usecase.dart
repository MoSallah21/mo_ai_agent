import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class DeleteConversationUseCase {
  final ChatRepository repository;

  DeleteConversationUseCase({required this.repository});

  Future<void> execute(String conversationId) async {
    return await repository.deleteConversation(conversationId);
  }
}