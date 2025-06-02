import 'package:get_it/get_it.dart';
import 'package:mo_ai_agent/domain/usecases/delete_all_conversations_usecase.dart';
import 'package:mo_ai_agent/domain/usecases/delete_conversation_usecase.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/datasources/lcoal/chat_local_datasource.dart';
import '../../data/datasources/remote/ai_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_conversation_history_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../presentation/blocs/chat/chat_cubit.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';
final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database
  final database = await openDatabase(
    join(await getDatabasesPath(), 'ai_assistant.db'),
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE conversations(id TEXT PRIMARY KEY, title TEXT, created_at INTEGER)',
      );
      await db.execute(
        'CREATE TABLE chat_messages(id TEXT PRIMARY KEY, conversation_id TEXT, content TEXT, is_user BOOLEAN, timestamp INTEGER, FOREIGN KEY(conversation_id) REFERENCES conversations(id))',
      );
    },
    version: 1,
  );

  // Data sources
  getIt.registerLazySingleton<ChatLocalDataSource>(
        () => ChatLocalDataSourceImpl(database: database),
  );
  getIt.registerLazySingleton<AIRemoteDataSource>(
        () => AIRemoteDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl(
      localDataSource: getIt<ChatLocalDataSource>(),
      remoteDataSource: getIt<AIRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
        () => GetConversationHistoryUseCase(repository: getIt<ChatRepository>()),
  );
  getIt.registerLazySingleton(
        () => SendMessageUseCase(repository: getIt<ChatRepository>()),
  );
  getIt.registerLazySingleton(
        () => DeleteAllConversationsUseCase(repository: getIt<ChatRepository>()),
  );
  getIt.registerLazySingleton(
        () => DeleteConversationUseCase(repository: getIt<ChatRepository>()),
  );

  // Cubits
  getIt.registerLazySingleton(
        () => ThemeCubit(),
  );
  getIt.registerLazySingleton(
        () => ChatCubit(
      getConversationHistoryUseCase: getIt<GetConversationHistoryUseCase>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      deleteAllConversationsUseCase: getIt<DeleteAllConversationsUseCase>(),
      deleteConversationUseCase: getIt<DeleteConversationUseCase>(),
    ),
  );
}