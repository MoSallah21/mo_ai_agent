import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, conversationId, content, isUser, timestamp];
}
