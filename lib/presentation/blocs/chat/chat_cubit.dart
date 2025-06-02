import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mo_ai_agent/domain/usecases/delete_all_conversations_usecase.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/chat_message_entity.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/usecases/delete_conversation_usecase.dart';
import '../../../domain/usecases/get_conversation_history_usecase.dart';
import '../../../domain/usecases/send_message_usecase.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetConversationHistoryUseCase getConversationHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final DeleteAllConversationsUseCase deleteAllConversationsUseCase;
  final DeleteConversationUseCase deleteConversationUseCase;

  // Cache for messages to avoid repeated API calls
  final Map<String, List<ChatMessageEntity>> _messagesCache = {};

  // Debounce timer for preventing rapid successive calls
  Timer? _debounceTimer;

  ChatCubit({
    required this.getConversationHistoryUseCase,
    required this.sendMessageUseCase,
    required this.deleteAllConversationsUseCase,
    required this.deleteConversationUseCase,
  }) : super(const ChatState());

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> loadConversations() async {
    if (state.status == ChatStatus.loading) return; // Prevent duplicate calls

    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final repository = GetIt.instance<ChatRepository>();
      final conversations = await repository.getConversations();

      emit(state.copyWith(
        conversations: conversations,
        status: ChatStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> selectConversation(String conversationId) async {
    if (state.currentConversationId == conversationId) return; // Already selected

    emit(state.copyWith(
      currentConversationId: conversationId,
      status: ChatStatus.loading,
    ));

    try {
      List<ChatMessageEntity> messages;

      // Check cache first
      if (_messagesCache.containsKey(conversationId)) {
        messages = _messagesCache[conversationId]!;
      } else {
        messages = await getConversationHistoryUseCase.execute(conversationId);
        _messagesCache[conversationId] = messages;
      }

      emit(state.copyWith(
        messages: messages,
        status: ChatStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> createConversation(String title) async {
    if (state.status == ChatStatus.loading) return;

    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final repository = GetIt.instance<ChatRepository>();
      final conversation = await repository.createConversation(title);

      // Use spread operator for better performance than List.from
      final updatedConversations = [conversation, ...state.conversations];

      emit(state.copyWith(
        conversations: updatedConversations,
        currentConversationId: conversation.id,
        messages: const [],
        status: ChatStatus.success,
      ));

      // Initialize cache for new conversation
      _messagesCache[conversation.id] = const [];
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> sendMessage(String content) async {
    // Debounce rapid message sending
    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {});

    if (state.currentConversationId == null) {
      await createConversation(content.length > 20 ? '${content.substring(0, 20)}...' : content);
    }

    if (state.isTyping) return; // Prevent multiple simultaneous sends

    emit(state.copyWith(isTyping: true));

    try {
      await sendMessageUseCase.execute(
        state.currentConversationId!,
        content,
      );

      // Reload messages and update cache
      final messages = await getConversationHistoryUseCase.execute(state.currentConversationId!);
      _messagesCache[state.currentConversationId!] = messages;

      emit(state.copyWith(
        messages: messages,
        isTyping: false,
        status: ChatStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        isTyping: false,
        status: ChatStatus.failure,
        errorMessage: e is ServerException ? e.message : e.toString(),
      ));
    }
  }

  Future<void> deleteAllConversations() async {
    if (state.status == ChatStatus.loading) return;

    emit(state.copyWith(status: ChatStatus.loading));

    try {
      await deleteAllConversationsUseCase.execute();

      // Clear cache
      _messagesCache.clear();

      final repository = GetIt.instance<ChatRepository>();
      final newConversation = await repository.createConversation('New Conversation');

      emit(state.copyWith(
        status: ChatStatus.success,
        conversations: [newConversation],
        currentConversationId: newConversation.id,
        messages: const [],
      ));

      // Initialize cache for new conversation
      _messagesCache[newConversation.id] = const [];
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e is ServerException ? e.message : e.toString(),
      ));
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    if (state.status == ChatStatus.loading) return;

    emit(state.copyWith(status: ChatStatus.loading));

    try {
      await deleteConversationUseCase.execute(conversationId);

      // Remove from cache
      _messagesCache.remove(conversationId);

      // Use where().toList() more efficiently
      final updatedConversations = state.conversations
          .where((conversation) => conversation.id != conversationId)
          .toList(growable: false); // Fixed length for better performance

      String? newSelectedId = state.currentConversationId;
      List<ChatMessageEntity> messages = state.messages;

      if (conversationId == state.currentConversationId) {
        if (updatedConversations.isNotEmpty) {
          newSelectedId = updatedConversations.first.id;
          // Use cached messages if available
          if (_messagesCache.containsKey(newSelectedId)) {
            messages = _messagesCache[newSelectedId]!;
          } else {
            messages = await getConversationHistoryUseCase.execute(newSelectedId);
            _messagesCache[newSelectedId] = messages;
          }
        } else {
          final repository = GetIt.instance<ChatRepository>();
          final newConversation = await repository.createConversation('New Conversation');
          updatedConversations.add(newConversation);
          newSelectedId = newConversation.id;
          messages = const [];
          _messagesCache[newConversation.id] = messages;
        }
      }

      emit(state.copyWith(
        status: ChatStatus.success,
        conversations: updatedConversations,
        currentConversationId: newSelectedId,
        messages: messages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e is ServerException ? e.message : e.toString(),
      ));
    }
  }
}