import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase({required this.repository});

  Future<ChatMessageEntity> execute(String conversationId, String content) {
    return repository.sendMessage(conversationId, content);
  }
}