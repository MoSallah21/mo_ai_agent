import '../../../core/errors/exceptions.dart';
import '../../models/chat_message.dart';
import '../../models/conversation.dart';
import 'package:sqflite/sqflite.dart';

abstract class ChatLocalDataSource {
  Future<List<Conversation>> getConversations();
  Future<Conversation> createConversation(Conversation conversation);
  Future<List<ChatMessage>> getConversationMessages(String conversationId);
  Future<void> saveMessage(ChatMessage message);
  Future<void> deleteAllConversations();
  Future<void> deleteConversation(String conversationId);

}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Database database;

  ChatLocalDataSourceImpl({required this.database});

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'conversations',
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return Conversation.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to get conversations: $e');
    }
  }

  @override
  Future<Conversation> createConversation(Conversation conversation) async {
    try {
      await database.insert(
        'conversations',
        conversation.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return conversation;
    } catch (e) {
      throw CacheException(message: 'Failed to create conversation: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getConversationMessages(String conversationId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'chat_messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
        orderBy: 'timestamp ASC',
      );

      return List.generate(maps.length, (i) {
        return ChatMessage.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to get conversation messages: $e');
    }
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    try {
      await database.insert(
        'chat_messages',
        message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save message: $e');
    }
  }

  @override
  Future<void> deleteAllConversations() async {
    try {
      // Begin a transaction for atomicity
      await database.transaction((txn) async {
        // Delete all chat messages first (due to foreign key constraints)
        await txn.delete('chat_messages');

        // Then delete all conversations
        await txn.delete('conversations');
      });
    } catch (e) {
      throw CacheException(message: 'Failed to delete conversations: $e');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Begin a transaction for atomicity
      await database.transaction((txn) async {
        await txn.delete(
          'chat_messages',
          where: 'conversation_id = ?',
          whereArgs: [conversationId],
        );

        // Then delete the specific conversation
        await txn.delete(
          'conversations',
          where: 'id = ?',
          whereArgs: [conversationId],
        );
      });
    } catch (e) {
      throw CacheException(message: 'Failed to delete conversation: $e');
    }
  }

}