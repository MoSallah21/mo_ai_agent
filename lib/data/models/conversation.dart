
import '../../domain/entities/conversation_entity.dart';

class Conversation extends ConversationEntity {
  const Conversation({
    required super.id,
    required super.title,
    required super.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Conversation.fromEntity(ConversationEntity entity) {
    return Conversation(
      id: entity.id,
      title: entity.title,
      createdAt: entity.createdAt,
    );
  }
}