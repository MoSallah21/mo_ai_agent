import '../../domain/entities/chat_message_entity.dart';

class ChatMessage extends ChatMessageEntity {
  const ChatMessage({
    required super.id,
    required super.conversationId,
    required super.content,
    required super.isUser,
    required super.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      content: json['content'],
      isUser: json['is_user'] == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'content': content,
      'is_user': isUser ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromEntity(ChatMessageEntity entity) {
    return ChatMessage(
      id: entity.id,
      conversationId: entity.conversationId,
      content: entity.content,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
    );
  }
}