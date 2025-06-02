import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class DeleteAllConversationsUseCase {
  final ChatRepository repository;

  DeleteAllConversationsUseCase({required this.repository});

  Future<void> execute() {
    return repository.deleteAllConversations();
  }
}