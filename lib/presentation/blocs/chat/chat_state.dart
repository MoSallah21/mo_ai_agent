part of 'chat_cubit.dart';


enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final List<ConversationEntity> conversations;
  final String? currentConversationId;
  final List<ChatMessageEntity> messages;
  final bool isTyping;
  final ChatStatus status;
  final String? errorMessage;

  const ChatState({
    this.conversations = const [],
    this.currentConversationId,
    this.messages = const [],
    this.isTyping = false,
    this.status = ChatStatus.initial,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ConversationEntity>? conversations,
    String? currentConversationId,
    List<ChatMessageEntity>? messages,
    bool? isTyping,
    ChatStatus? status,
    String? errorMessage,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    conversations,
    currentConversationId,
    messages,
    isTyping,
    status,
    errorMessage,
  ];
}
